import Foundation
import Combine

/// Manages the saved MP3 library with sidecar files
///
/// Features:
/// - Transcode episodes to MP3 (192kbps CBR) using FFmpeg
/// - Store in user-visible folder (configurable)
/// - Create/sync sidecar files (.json metadata, .md notes)
/// - Track save progress
@MainActor
final class SavedLibraryManager: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = SavedLibraryManager()
    
    // MARK: - Published State
    
    /// Currently saving episodes
    @Published private(set) var savingEpisodes: [String: SaveTask] = [:]
    
    /// Whether any save operations are in progress
    var isSaving: Bool {
        !savingEpisodes.isEmpty
    }
    
    /// Saved library location
    @Published var libraryPath: URL {
        didSet {
            UserDefaults.standard.set(libraryPath.path, forKey: "savedLibraryPath")
        }
    }
    
    // MARK: - Types
    
    struct SaveTask: Identifiable {
        let id: String  // Episode ID
        let episodeTitle: String
        let podcastTitle: String
        var progress: Double = 0
        var status: SaveStatus = .preparing
        var startTime: Date = Date()
        
        enum SaveStatus: String {
            case preparing
            case downloading
            case transcoding
            case writingSidecars
            case complete
            case failed
        }
        
        var statusDescription: String {
            switch status {
            case .preparing: return "Preparing..."
            case .downloading: return "Downloading..."
            case .transcoding: return "Converting to MP3..."
            case .writingSidecars: return "Writing metadata..."
            case .complete: return "Complete"
            case .failed: return "Failed"
            }
        }
    }
    
    /// Metadata structure for JSON sidecar
    struct EpisodeMetadata: Codable {
        let version: Int
        let episode: EpisodeInfo
        var tags: [String]
        let savedAt: Date
        let sourceApp: String
        
        struct EpisodeInfo: Codable {
            let title: String
            let podcast: String
            let guid: String
            let pubDate: Date?
            let durationSeconds: Int?
            let originalURL: String?
        }
    }
    
    // MARK: - Private Properties
    
    private let repository = PodcastRepository()
    private let fileManager = FileManager.default
    
    /// Path to bundled or system FFmpeg
    private var ffmpegPath: String? {
        // Check common locations
        let paths = [
            "/opt/homebrew/bin/ffmpeg",  // Homebrew on Apple Silicon
            "/usr/local/bin/ffmpeg",     // Homebrew on Intel
            "/usr/bin/ffmpeg",           // System
            Bundle.main.path(forResource: "ffmpeg", ofType: nil)  // Bundled
        ].compactMap { $0 }
        
        return paths.first { fileManager.fileExists(atPath: $0) }
    }
    
    // MARK: - Initialization
    
    private init() {
        // Load saved library path or use default
        if let savedPath = UserDefaults.standard.string(forKey: "savedLibraryPath") {
            libraryPath = URL(fileURLWithPath: savedPath)
        } else {
            libraryPath = DatabaseManager.savedLibraryDirectory
        }
        
        // Ensure directory exists
        try? fileManager.createDirectory(at: libraryPath, withIntermediateDirectories: true)
    }
    
    // MARK: - Public Methods
    
    /// Save an episode to the library (transcode to MP3 + create sidecars)
    func saveEpisode(_ episode: Episode, podcast: Podcast) async throws {
        // Check if already saving
        guard savingEpisodes[episode.id] == nil else {
            print("⚠️ Episode already being saved: \(episode.title)")
            return
        }
        
        // Check if already saved
        if episode.isSaved, let savedPath = episode.savedPath {
            let savedURL = URL(fileURLWithPath: savedPath)
            if fileManager.fileExists(atPath: savedURL.path) {
                print("⚠️ Episode already saved: \(episode.title)")
                return
            }
        }
        
        // Create save task
        var task = SaveTask(
            id: episode.id,
            episodeTitle: episode.title,
            podcastTitle: podcast.title
        )
        savingEpisodes[episode.id] = task
        
        // Log activity
        try? await repository.logActivity(ActivityLog(
            action: .save,
            targetType: .episode,
            targetId: episode.id,
            targetName: episode.title,
            status: .started
        ))
        
        do {
            // Step 1: Get source audio
            task.status = .downloading
            task.progress = 0.1
            savingEpisodes[episode.id] = task
            
            let sourceURL = try await resolveSourceAudio(for: episode)
            
            // Step 2: Create destination paths
            let podcastFolder = libraryPath.appendingPathComponent(
                sanitizeFilename(podcast.title),
                isDirectory: true
            )
            try fileManager.createDirectory(at: podcastFolder, withIntermediateDirectories: true)
            
            let baseName = sanitizeFilename(episode.title)
            let mp3Path = podcastFolder.appendingPathComponent("\(baseName).mp3")
            let jsonPath = podcastFolder.appendingPathComponent("\(baseName).json")
            let mdPath = podcastFolder.appendingPathComponent("\(baseName).md")
            
            // Step 3: Transcode to MP3
            task.status = .transcoding
            task.progress = 0.3
            savingEpisodes[episode.id] = task
            
            try await transcodeToMP3(source: sourceURL, destination: mp3Path) { progress in
                Task { @MainActor in
                    var updatedTask = self.savingEpisodes[episode.id]
                    updatedTask?.progress = 0.3 + (progress * 0.5)
                    self.savingEpisodes[episode.id] = updatedTask
                }
            }
            
            // Step 4: Write sidecar files
            task.status = .writingSidecars
            task.progress = 0.85
            savingEpisodes[episode.id] = task
            
            try writeSidecarFiles(
                episode: episode,
                podcast: podcast,
                jsonPath: jsonPath,
                mdPath: mdPath
            )
            
            // Step 5: Update database
            task.status = .complete
            task.progress = 1.0
            savingEpisodes[episode.id] = task
            
            var updatedEpisode = episode
            updatedEpisode.isSaved = true
            updatedEpisode.savedPath = mp3Path.path
            try await repository.saveEpisode(updatedEpisode)
            
            // Log success
            let fileSize = (try? fileManager.attributesOfItem(atPath: mp3Path.path)[.size] as? Int64) ?? 0
            try? await repository.logActivity(ActivityLog(
                action: .save,
                targetType: .episode,
                targetId: episode.id,
                targetName: episode.title,
                details: "{\"file_size\": \(fileSize), \"path\": \"\(mp3Path.path)\"}",
                status: .success
            ))
            
            print("✅ Saved episode: \(episode.title) → \(mp3Path.path)")
            
            // Notify
            NotificationCenter.default.post(
                name: .episodeSaved,
                object: nil,
                userInfo: ["episodeId": episode.id]
            )
            
            // Remove from saving list after brief delay
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            savingEpisodes.removeValue(forKey: episode.id)
            
        } catch {
            print("❌ Failed to save episode: \(error)")
            
            task.status = .failed
            savingEpisodes[episode.id] = task
            
            try? await repository.logActivity(ActivityLog(
                action: .save,
                targetType: .episode,
                targetId: episode.id,
                targetName: episode.title,
                status: .failed,
                errorMessage: error.localizedDescription
            ))
            
            // Remove from saving list after delay
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            savingEpisodes.removeValue(forKey: episode.id)
            
            throw error
        }
    }
    
    /// Remove an episode from the saved library
    func unsaveEpisode(_ episode: Episode) async throws {
        guard episode.isSaved, let savedPath = episode.savedPath else {
            return
        }
        
        let mp3URL = URL(fileURLWithPath: savedPath)
        let baseName = mp3URL.deletingPathExtension().lastPathComponent
        let folder = mp3URL.deletingLastPathComponent()
        
        let jsonPath = folder.appendingPathComponent("\(baseName).json")
        let mdPath = folder.appendingPathComponent("\(baseName).md")
        
        // Delete files
        try? fileManager.removeItem(at: mp3URL)
        try? fileManager.removeItem(at: jsonPath)
        try? fileManager.removeItem(at: mdPath)
        
        // Update database
        var updatedEpisode = episode
        updatedEpisode.isSaved = false
        updatedEpisode.savedPath = nil
        try await repository.saveEpisode(updatedEpisode)
        
        try? await repository.logActivity(ActivityLog(
            action: .delete,
            targetType: .episode,
            targetId: episode.id,
            targetName: episode.title,
            details: "{\"source\": \"saved_library\"}",
            status: .success
        ))
        
        print("🗑️ Removed from saved library: \(episode.title)")
    }
    
    /// Update the notes for a saved episode (syncs to sidecar)
    func updateNotes(for episode: Episode, notes: String, tags: [String] = []) async throws {
        guard episode.isSaved, let savedPath = episode.savedPath else {
            throw SaveError.notSaved
        }
        
        let mp3URL = URL(fileURLWithPath: savedPath)
        let baseName = mp3URL.deletingPathExtension().lastPathComponent
        let folder = mp3URL.deletingLastPathComponent()
        let jsonPath = folder.appendingPathComponent("\(baseName).json")
        let mdPath = folder.appendingPathComponent("\(baseName).md")
        
        // Update JSON sidecar with tags if provided
        if !tags.isEmpty {
            if let data = try? Data(contentsOf: jsonPath),
               var metadata = try? JSONDecoder().decode(EpisodeMetadata.self, from: data) {
                metadata.tags = tags
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                encoder.dateEncodingStrategy = .iso8601
                let updatedData = try encoder.encode(metadata)
                try updatedData.write(to: jsonPath)
            }
        }
        
        // Get podcast info
        let podcast = try await repository.getPodcast(id: episode.podcastId)
        
        // Determine which tags to use
        var tagsToUse = tags
        if tagsToUse.isEmpty {
            // Read existing tags from JSON
            if let data = try? Data(contentsOf: jsonPath),
               let metadata = try? JSONDecoder().decode(EpisodeMetadata.self, from: data) {
                tagsToUse = metadata.tags
            }
        }
        
        // Rewrite markdown sidecar
        let mdContent = generateMarkdownSidecar(
            episode: episode,
            podcast: podcast,
            notes: notes,
            tags: tagsToUse
        )
        try mdContent.write(to: mdPath, atomically: true, encoding: .utf8)
        
        print("📝 Updated notes for: \(episode.title)")
    }
    
    /// Update tags for a saved episode
    func updateTags(for episode: Episode, tags: [String]) async throws {
        guard episode.isSaved, let savedPath = episode.savedPath else {
            throw SaveError.notSaved
        }
        
        let mp3URL = URL(fileURLWithPath: savedPath)
        let baseName = mp3URL.deletingPathExtension().lastPathComponent
        let folder = mp3URL.deletingLastPathComponent()
        let jsonPath = folder.appendingPathComponent("\(baseName).json")
        
        // Read existing metadata
        guard let data = try? Data(contentsOf: jsonPath),
              var metadata = try? JSONDecoder().decode(EpisodeMetadata.self, from: data) else {
            throw SaveError.sidecarMissing
        }
        
        // Update tags
        metadata.tags = tags
        
        // Write back
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let updatedData = try encoder.encode(metadata)
        try updatedData.write(to: jsonPath)
        
        // Also update markdown
        let mdPath = folder.appendingPathComponent("\(baseName).md")
        if fileManager.fileExists(atPath: mdPath.path) {
            let podcast = try await repository.getPodcast(id: episode.podcastId)
            
            // Read existing notes from markdown
            var existingNotes = ""
            if let mdContent = try? String(contentsOf: mdPath, encoding: .utf8) {
                // Extract notes section
                if let notesRange = mdContent.range(of: "## Notes\n\n") {
                    let afterNotes = mdContent[notesRange.upperBound...]
                    if let endRange = afterNotes.range(of: "\n---\n") {
                        existingNotes = String(afterNotes[..<endRange.lowerBound])
                    } else {
                        existingNotes = String(afterNotes)
                    }
                }
            }
            
            let mdContent = generateMarkdownSidecar(
                episode: episode,
                podcast: podcast,
                notes: existingNotes,
                tags: tags
            )
            try mdContent.write(to: mdPath, atomically: true, encoding: .utf8)
        }
        
        print("🏷️ Updated tags for: \(episode.title)")
    }
    
    /// Open the saved library folder in Finder
    func openInFinder() {
        NSWorkspace.shared.open(libraryPath)
    }
    
    /// Open a specific saved episode's folder in Finder
    func openInFinder(episode: Episode) {
        guard let savedPath = episode.savedPath else { return }
        let url = URL(fileURLWithPath: savedPath)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    /// Check if episode is currently being saved
    func isSaving(episodeId: String) -> Bool {
        savingEpisodes[episodeId] != nil
    }
    
    /// Get save progress for an episode
    func saveProgress(for episodeId: String) -> Double? {
        savingEpisodes[episodeId]?.progress
    }
    
    // MARK: - Private Methods
    
    private func resolveSourceAudio(for episode: Episode) async throws -> URL {
        // Prefer downloaded file
        if episode.downloadStatus == .downloaded,
           let downloadPath = episode.downloadPath {
            let localURL = URL(fileURLWithPath: downloadPath)
            if fileManager.fileExists(atPath: localURL.path) {
                return localURL
            }
        }
        
        // Download to temp location
        guard let audioURLString = episode.audioURL,
              let remoteURL = URL(string: audioURLString) else {
            throw SaveError.noAudioSource
        }
        
        let tempDir = fileManager.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent(UUID().uuidString + ".audio")
        
        let (data, _) = try await URLSession.shared.data(from: remoteURL)
        try data.write(to: tempFile)
        
        return tempFile
    }
    
    private func transcodeToMP3(
        source: URL,
        destination: URL,
        progressHandler: @escaping (Double) -> Void
    ) async throws {
        guard let ffmpeg = ffmpegPath else {
            throw SaveError.ffmpegNotFound
        }
        
        // Remove destination if exists
        try? fileManager.removeItem(at: destination)
        
        // Build FFmpeg command
        // -y: overwrite
        // -i: input
        // -codec:a libmp3lame: use MP3 encoder
        // -b:a 192k: 192kbps bitrate
        // -ar 44100: 44.1kHz sample rate
        // -ac 2: stereo
        let process = Process()
        process.executableURL = URL(fileURLWithPath: ffmpeg)
        process.arguments = [
            "-y",
            "-i", source.path,
            "-codec:a", "libmp3lame",
            "-b:a", "192k",
            "-ar", "44100",
            "-ac", "2",
            destination.path
        ]
        
        let pipe = Pipe()
        process.standardError = pipe  // FFmpeg outputs progress to stderr
        
        // Run process
        try process.run()
        
        // Monitor progress (simplified - FFmpeg progress parsing is complex)
        var progressValue = 0.0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if process.isRunning {
                progressValue = min(progressValue + 0.1, 0.9)
                progressHandler(progressValue)
            }
        }
        
        process.waitUntilExit()
        timer.invalidate()
        
        guard process.terminationStatus == 0 else {
            throw SaveError.transcodeFailed(process.terminationStatus)
        }
        
        progressHandler(1.0)
    }
    
    private func writeSidecarFiles(
        episode: Episode,
        podcast: Podcast,
        jsonPath: URL,
        mdPath: URL
    ) throws {
        // JSON sidecar
        let metadata = EpisodeMetadata(
            version: 1,
            episode: EpisodeMetadata.EpisodeInfo(
                title: episode.title,
                podcast: podcast.title,
                guid: episode.guid,
                pubDate: episode.pubDate,
                durationSeconds: episode.duration,
                originalURL: episode.audioURL
            ),
            tags: [],
            savedAt: Date(),
            sourceApp: "PodVault 1.0"
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let jsonData = try encoder.encode(metadata)
        try jsonData.write(to: jsonPath)
        
        // Markdown sidecar
        let mdContent = generateMarkdownSidecar(
            episode: episode,
            podcast: podcast,
            notes: "",
            tags: []
        )
        try mdContent.write(to: mdPath, atomically: true, encoding: .utf8)
    }
    
    private func generateMarkdownSidecar(
        episode: Episode,
        podcast: Podcast?,
        notes: String,
        tags: [String]
    ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        let pubDateStr = episode.pubDate.map { dateFormatter.string(from: $0) } ?? "Unknown"
        let tagsStr = tags.isEmpty ? "" : tags.map { "#\($0)" }.joined(separator: " ")
        
        let exportDateStr = dateFormatter.string(from: Date())
        
        return """
        # \(episode.title)
        
        **Podcast:** \(podcast?.title ?? "Unknown")
        **Date:** \(pubDateStr)
        \(tagsStr.isEmpty ? "" : "**Tags:** \(tagsStr)\n")
        ---
        
        ## Notes
        
        \(notes.isEmpty ? "_No notes yet._" : notes)
        
        ---
        
        *Exported from PodVault on \(exportDateStr)*
        """
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
}

// MARK: - Errors

enum SaveError: LocalizedError {
    case noAudioSource
    case ffmpegNotFound
    case transcodeFailed(Int32)
    case notSaved
    case sidecarMissing
    
    var errorDescription: String? {
        switch self {
        case .noAudioSource:
            return "No audio source available for this episode"
        case .ffmpegNotFound:
            return "FFmpeg not found. Please install FFmpeg to save episodes as MP3."
        case .transcodeFailed(let code):
            return "Audio conversion failed (exit code: \(code))"
        case .notSaved:
            return "Episode is not in the saved library"
        case .sidecarMissing:
            return "Sidecar metadata file is missing"
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let episodeSaved = Notification.Name("PodVault.episodeSaved")
    static let episodeUnsaved = Notification.Name("PodVault.episodeUnsaved")
}

// MARK: - AppKit Import

import AppKit
