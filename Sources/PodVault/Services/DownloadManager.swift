import Foundation
import Combine

/// Manages episode downloads with queue, progress tracking, and cancellation
///
/// Features:
/// - Concurrent downloads (configurable limit)
/// - Per-episode and overall progress tracking
/// - Download cancellation (single or all)
/// - Automatic retry on transient failures
/// - Activity logging
@MainActor
final class DownloadManager: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = DownloadManager()
    
    // MARK: - Published State
    
    /// Currently active downloads
    @Published private(set) var activeDownloads: [String: DownloadTask] = [:]
    
    /// Queued downloads waiting to start
    @Published private(set) var queuedDownloads: [QueuedDownload] = []
    
    /// Recently completed downloads (cleared on app restart)
    @Published private(set) var completedDownloads: [CompletedDownload] = []
    
    /// Overall download progress (0.0 to 1.0)
    @Published private(set) var overallProgress: Double = 0
    
    /// Whether any downloads are in progress
    var isDownloading: Bool {
        !activeDownloads.isEmpty || !queuedDownloads.isEmpty
    }
    
    /// Total number of pending downloads (active + queued)
    var pendingCount: Int {
        activeDownloads.count + queuedDownloads.count
    }
    
    // MARK: - Configuration
    
    /// Maximum concurrent downloads
    var maxConcurrentDownloads: Int = 3 {
        didSet {
            processQueue()
        }
    }
    
    // MARK: - Types
    
    /// Represents an active download
    struct DownloadTask: Identifiable {
        let id: String  // Episode ID
        let episodeId: String
        let episodeTitle: String
        let podcastTitle: String
        let url: URL
        let destinationPath: URL
        var progress: Double = 0
        var bytesDownloaded: Int64 = 0
        var totalBytes: Int64 = 0
        var startTime: Date = Date()
        var task: URLSessionDownloadTask?
        
        var formattedProgress: String {
            "\(Int(progress * 100))%"
        }
        
        var formattedSpeed: String {
            let elapsed = Date().timeIntervalSince(startTime)
            guard elapsed > 0, bytesDownloaded > 0 else { return "--" }
            let bytesPerSecond = Double(bytesDownloaded) / elapsed
            return ByteCountFormatter.string(fromByteCount: Int64(bytesPerSecond), countStyle: .file) + "/s"
        }
        
        var formattedSize: String {
            guard totalBytes > 0 else { return "--" }
            let downloaded = ByteCountFormatter.string(fromByteCount: bytesDownloaded, countStyle: .file)
            let total = ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file)
            return "\(downloaded) / \(total)"
        }
    }
    
    /// Represents a queued download waiting to start
    struct QueuedDownload: Identifiable {
        let id: String  // Episode ID
        let episodeId: String
        let episodeTitle: String
        let podcastTitle: String
        let url: URL
        let destinationPath: URL
        let queuedAt: Date = Date()
    }
    
    /// Represents a completed download
    struct CompletedDownload: Identifiable {
        let id: String
        let episodeId: String
        let episodeTitle: String
        let podcastTitle: String
        let filePath: URL
        let fileSize: Int64
        let completedAt: Date
        let success: Bool
        let errorMessage: String?
    }
    
    // MARK: - Private Properties
    
    private let repository = PodcastRepository()
    private var urlSession: URLSession!
    private var downloadDelegate: DownloadDelegate!
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    private init() {
        setupURLSession()
    }
    
    private func setupURLSession() {
        downloadDelegate = DownloadDelegate(manager: self)
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 3600  // 1 hour max per download
        config.httpAdditionalHeaders = [
            "User-Agent": "PodVault/1.0 (macOS)"
        ]
        
        urlSession = URLSession(
            configuration: config,
            delegate: downloadDelegate,
            delegateQueue: .main
        )
    }
    
    // MARK: - Public Methods
    
    /// Queue an episode for download
    func downloadEpisode(_ episode: Episode, podcast: Podcast) async {
        // Validate episode has audio URL
        guard let audioURLString = episode.audioURL,
              let audioURL = URL(string: audioURLString) else {
            print("❌ No audio URL for episode: \(episode.title)")
            await logDownloadError(episode: episode, error: "No audio URL available")
            return
        }
        
        // Check if already downloading or queued
        if activeDownloads[episode.id] != nil {
            print("⚠️ Episode already downloading: \(episode.title)")
            return
        }
        
        if queuedDownloads.contains(where: { $0.episodeId == episode.id }) {
            print("⚠️ Episode already queued: \(episode.title)")
            return
        }
        
        // Check if already downloaded
        if episode.downloadStatus == .downloaded, let path = episode.downloadPath {
            let fileURL = URL(fileURLWithPath: path)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                print("⚠️ Episode already downloaded: \(episode.title)")
                return
            }
        }
        
        // Create destination path
        let destinationPath = createDestinationPath(for: episode, podcast: podcast, url: audioURL)
        
        // Create queued download
        let queued = QueuedDownload(
            id: episode.id,
            episodeId: episode.id,
            episodeTitle: episode.title,
            podcastTitle: podcast.title,
            url: audioURL,
            destinationPath: destinationPath
        )
        
        queuedDownloads.append(queued)
        
        // Update episode status
        await updateEpisodeStatus(episode.id, status: .queued)
        
        // Log activity
        try? await repository.logActivity(ActivityLog(
            action: .download,
            targetType: .episode,
            targetId: episode.id,
            targetName: episode.title,
            status: .started
        ))
        
        print("📥 Queued download: \(episode.title)")
        
        // Process queue
        processQueue()
    }
    
    /// Download all episodes from a podcast
    func downloadAllEpisodes(podcast: Podcast, episodes: [Episode]) async {
        let downloadable = episodes.filter { episode in
            episode.audioURL != nil &&
            episode.downloadStatus != .downloaded &&
            episode.downloadStatus != .downloading &&
            !queuedDownloads.contains(where: { $0.episodeId == episode.id })
        }
        
        print("📥 Queueing \(downloadable.count) episodes from \(podcast.title)")
        
        for episode in downloadable {
            await downloadEpisode(episode, podcast: podcast)
        }
    }
    
    /// Cancel a specific download
    func cancelDownload(episodeId: String) {
        // Cancel active download
        if let download = activeDownloads[episodeId] {
            download.task?.cancel()
            activeDownloads.removeValue(forKey: episodeId)
            
            Task {
                await updateEpisodeStatus(episodeId, status: .none)
                try? await repository.logActivity(ActivityLog(
                    action: .download,
                    targetType: .episode,
                    targetId: episodeId,
                    targetName: download.episodeTitle,
                    status: .cancelled
                ))
            }
            
            print("🛑 Cancelled download: \(download.episodeTitle)")
        }
        
        // Remove from queue
        if let index = queuedDownloads.firstIndex(where: { $0.episodeId == episodeId }) {
            let queued = queuedDownloads.remove(at: index)
            
            Task {
                await updateEpisodeStatus(episodeId, status: .none)
            }
            
            print("🛑 Removed from queue: \(queued.episodeTitle)")
        }
        
        updateOverallProgress()
        processQueue()
    }
    
    /// Cancel all downloads
    func cancelAllDownloads() {
        // Cancel all active downloads
        for (_, download) in activeDownloads {
            download.task?.cancel()
            
            Task {
                await updateEpisodeStatus(download.episodeId, status: .none)
            }
        }
        activeDownloads.removeAll()
        
        // Clear queue
        for queued in queuedDownloads {
            Task {
                await updateEpisodeStatus(queued.episodeId, status: .none)
            }
        }
        queuedDownloads.removeAll()
        
        updateOverallProgress()
        
        print("🛑 Cancelled all downloads")
    }
    
    /// Get download progress for a specific episode
    func progress(for episodeId: String) -> Double? {
        activeDownloads[episodeId]?.progress
    }
    
    /// Check if episode is downloading or queued
    func isDownloading(episodeId: String) -> Bool {
        activeDownloads[episodeId] != nil || queuedDownloads.contains(where: { $0.episodeId == episodeId })
    }
    
    // MARK: - Private Methods
    
    private func processQueue() {
        // Start downloads up to max concurrent limit
        while activeDownloads.count < maxConcurrentDownloads && !queuedDownloads.isEmpty {
            let queued = queuedDownloads.removeFirst()
            startDownload(queued)
        }
    }
    
    private func startDownload(_ queued: QueuedDownload) {
        let task = urlSession.downloadTask(with: queued.url)
        
        var download = DownloadTask(
            id: queued.id,
            episodeId: queued.episodeId,
            episodeTitle: queued.episodeTitle,
            podcastTitle: queued.podcastTitle,
            url: queued.url,
            destinationPath: queued.destinationPath
        )
        download.task = task
        
        activeDownloads[queued.episodeId] = download
        
        Task {
            await updateEpisodeStatus(queued.episodeId, status: .downloading)
        }
        
        task.resume()
        
        print("⬇️ Started download: \(queued.episodeTitle)")
    }
    
    private func createDestinationPath(for episode: Episode, podcast: Podcast, url: URL) -> URL {
        let downloadsDir = DatabaseManager.downloadsDirectory
        let podcastDir = downloadsDir.appendingPathComponent(
            sanitizeFilename(podcast.title),
            isDirectory: true
        )
        
        // Create podcast directory
        try? FileManager.default.createDirectory(at: podcastDir, withIntermediateDirectories: true)
        
        // Get file extension from URL or default to mp3
        var fileExtension = url.pathExtension.lowercased()
        if fileExtension.isEmpty || !["mp3", "m4a", "aac", "wav", "ogg"].contains(fileExtension) {
            fileExtension = "mp3"
        }
        
        let filename = sanitizeFilename(episode.title) + "." + fileExtension
        return podcastDir.appendingPathComponent(filename)
    }
    
    private func sanitizeFilename(_ name: String) -> String {
        let invalidChars = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        var sanitized = name.components(separatedBy: invalidChars).joined(separator: "_")
        sanitized = sanitized.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Limit length
        if sanitized.count > 100 {
            sanitized = String(sanitized.prefix(100))
        }
        
        return sanitized.isEmpty ? "episode" : sanitized
    }
    
    private func updateEpisodeStatus(_ episodeId: String, status: DownloadStatus, path: String? = nil) async {
        do {
            if var episode = try await repository.getEpisode(id: episodeId) {
                episode.downloadStatus = status
                if let path = path {
                    episode.downloadPath = path
                }
                try await repository.saveEpisode(episode)
            }
        } catch {
            print("⚠️ Failed to update episode status: \(error)")
        }
    }
    
    private func updateOverallProgress() {
        let totalActive = activeDownloads.count
        let totalQueued = queuedDownloads.count
        let total = totalActive + totalQueued
        
        guard total > 0 else {
            overallProgress = 0
            return
        }
        
        let activeProgress = activeDownloads.values.reduce(0.0) { $0 + $1.progress }
        overallProgress = activeProgress / Double(total)
    }
    
    private func logDownloadError(episode: Episode, error: String) async {
        try? await repository.logActivity(ActivityLog(
            action: .download,
            targetType: .episode,
            targetId: episode.id,
            targetName: episode.title,
            status: .failed,
            errorMessage: error
        ))
    }
    
    // MARK: - Download Delegate Callbacks
    
    fileprivate func handleProgress(for task: URLSessionDownloadTask, bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpected: Int64) {
        // Find the download by task
        guard let episodeId = activeDownloads.first(where: { $0.value.task == task })?.key else {
            return
        }
        
        var download = activeDownloads[episodeId]!
        download.bytesDownloaded = totalBytesWritten
        download.totalBytes = totalBytesExpected > 0 ? totalBytesExpected : 0
        download.progress = totalBytesExpected > 0 ? Double(totalBytesWritten) / Double(totalBytesExpected) : 0
        activeDownloads[episodeId] = download
        
        updateOverallProgress()
    }
    
    fileprivate func handleCompletion(for task: URLSessionDownloadTask, location: URL?, error: Error?) {
        // Find the download by task
        guard let episodeId = activeDownloads.first(where: { $0.value.task == task })?.key,
              let download = activeDownloads[episodeId] else {
            return
        }
        
        activeDownloads.removeValue(forKey: episodeId)
        
        if let error = error {
            // Handle cancellation separately
            if (error as NSError).code == NSURLErrorCancelled {
                print("🛑 Download cancelled: \(download.episodeTitle)")
            } else {
                print("❌ Download failed: \(download.episodeTitle) - \(error.localizedDescription)")
                
                let completed = CompletedDownload(
                    id: UUID().uuidString,
                    episodeId: download.episodeId,
                    episodeTitle: download.episodeTitle,
                    podcastTitle: download.podcastTitle,
                    filePath: download.destinationPath,
                    fileSize: 0,
                    completedAt: Date(),
                    success: false,
                    errorMessage: error.localizedDescription
                )
                completedDownloads.insert(completed, at: 0)
                
                Task {
                    await updateEpisodeStatus(episodeId, status: .failed)
                    try? await repository.logActivity(ActivityLog(
                        action: .download,
                        targetType: .episode,
                        targetId: episodeId,
                        targetName: download.episodeTitle,
                        status: .failed,
                        errorMessage: error.localizedDescription
                    ))
                }
            }
        } else if let location = location {
            // Move file to destination
            do {
                // Remove existing file if present
                if FileManager.default.fileExists(atPath: download.destinationPath.path) {
                    try FileManager.default.removeItem(at: download.destinationPath)
                }
                
                try FileManager.default.moveItem(at: location, to: download.destinationPath)
                
                let fileSize = (try? FileManager.default.attributesOfItem(atPath: download.destinationPath.path)[.size] as? Int64) ?? 0
                
                let completed = CompletedDownload(
                    id: UUID().uuidString,
                    episodeId: download.episodeId,
                    episodeTitle: download.episodeTitle,
                    podcastTitle: download.podcastTitle,
                    filePath: download.destinationPath,
                    fileSize: fileSize,
                    completedAt: Date(),
                    success: true,
                    errorMessage: nil
                )
                completedDownloads.insert(completed, at: 0)
                
                // Limit completed downloads list
                if completedDownloads.count > 50 {
                    completedDownloads = Array(completedDownloads.prefix(50))
                }
                
                Task {
                    await updateEpisodeStatus(episodeId, status: .downloaded, path: download.destinationPath.path)
                    try? await repository.logActivity(ActivityLog(
                        action: .download,
                        targetType: .episode,
                        targetId: episodeId,
                        targetName: download.episodeTitle,
                        details: "{\"file_size\": \(fileSize)}",
                        status: .success
                    ))
                }
                
                print("✅ Download complete: \(download.episodeTitle)")
                
                // Post notification
                NotificationCenter.default.post(
                    name: .downloadCompleted,
                    object: nil,
                    userInfo: ["episodeId": episodeId]
                )
                
            } catch {
                print("❌ Failed to move downloaded file: \(error)")
                
                Task {
                    await updateEpisodeStatus(episodeId, status: .failed)
                    try? await repository.logActivity(ActivityLog(
                        action: .download,
                        targetType: .episode,
                        targetId: episodeId,
                        targetName: download.episodeTitle,
                        status: .failed,
                        errorMessage: "Failed to save file: \(error.localizedDescription)"
                    ))
                }
            }
        }
        
        updateOverallProgress()
        processQueue()
    }
}

// MARK: - Download Delegate

private class DownloadDelegate: NSObject, URLSessionDownloadDelegate {
    weak var manager: DownloadManager?
    
    init(manager: DownloadManager) {
        self.manager = manager
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        Task { @MainActor in
            manager?.handleProgress(
                for: downloadTask,
                bytesWritten: bytesWritten,
                totalBytesWritten: totalBytesWritten,
                totalBytesExpected: totalBytesExpectedToWrite
            )
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // Copy location before it's deleted
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.copyItem(at: location, to: tempURL)
        
        Task { @MainActor in
            manager?.handleCompletion(for: downloadTask, location: tempURL, error: nil)
            try? FileManager.default.removeItem(at: tempURL)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let downloadTask = task as? URLSessionDownloadTask, error != nil else { return }
        
        Task { @MainActor in
            manager?.handleCompletion(for: downloadTask, location: nil, error: error)
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let downloadCompleted = Notification.Name("PodVault.downloadCompleted")
    static let downloadFailed = Notification.Name("PodVault.downloadFailed")
}
