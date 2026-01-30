import Foundation
import AVFoundation
import Combine
import MediaPlayer
import AppKit

/// Manages audio playback for podcast episodes
///
/// Features:
/// - Play/pause/stop
/// - Variable playback speed (0.5x to 2.0x)
/// - Skip forward/backward
/// - Seek to position
/// - Remember playback position per episode
/// - Now Playing integration (media keys)
@MainActor
final class PlaybackManager: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = PlaybackManager()
    
    // MARK: - Published State
    
    /// Currently playing episode (nil if nothing playing)
    @Published private(set) var currentEpisode: Episode?
    
    /// Associated podcast for current episode
    @Published private(set) var currentPodcast: Podcast?
    
    /// Whether audio is currently playing
    @Published private(set) var isPlaying: Bool = false
    
    /// Current playback position in seconds
    @Published private(set) var currentTime: Double = 0
    
    /// Total duration in seconds
    @Published private(set) var duration: Double = 0
    
    /// Current playback speed (1.0 = normal)
    @Published var playbackSpeed: Float = 1.0 {
        didSet {
            player?.rate = isPlaying ? playbackSpeed : 0
            UserDefaults.standard.set(playbackSpeed, forKey: "playbackSpeed")
        }
    }
    
    /// Whether the player is loading/buffering
    @Published private(set) var isLoading: Bool = false
    
    /// Error message if playback failed
    @Published var playbackError: String?
    
    // MARK: - Configuration
    
    /// Skip forward interval in seconds
    var skipForwardInterval: Double = 30 {
        didSet {
            UserDefaults.standard.set(skipForwardInterval, forKey: "skipForwardInterval")
            setupRemoteCommands()
        }
    }
    
    /// Skip backward interval in seconds
    var skipBackwardInterval: Double = 15 {
        didSet {
            UserDefaults.standard.set(skipBackwardInterval, forKey: "skipBackwardInterval")
            setupRemoteCommands()
        }
    }
    
    /// Available playback speeds
    static let availableSpeeds: [Float] = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
    
    // MARK: - Computed Properties
    
    /// Progress as 0.0 to 1.0
    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }
    
    /// Formatted current time (mm:ss or hh:mm:ss)
    var formattedCurrentTime: String {
        formatTime(currentTime)
    }
    
    /// Formatted duration
    var formattedDuration: String {
        formatTime(duration)
    }
    
    /// Formatted remaining time
    var formattedRemainingTime: String {
        "-" + formatTime(max(0, duration - currentTime))
    }
    
    /// Current speed as display string
    var speedDisplayString: String {
        if playbackSpeed == 1.0 {
            return "1×"
        } else if playbackSpeed == floor(playbackSpeed) {
            return "\(Int(playbackSpeed))×"
        } else {
            return String(format: "%.2g×", playbackSpeed)
        }
    }
    
    // MARK: - Private Properties
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    private let repository = PodcastRepository()
    
    /// Timer for periodic position saving
    private var positionSaveTimer: Timer?
    
    /// Last saved position (to avoid redundant saves)
    private var lastSavedPosition: Int = 0
    
    // MARK: - Initialization
    
    private init() {
        // Load saved preferences
        let savedSpeed = UserDefaults.standard.float(forKey: "playbackSpeed")
        if savedSpeed > 0 {
            playbackSpeed = savedSpeed
        }
        
        let savedSkipForward = UserDefaults.standard.double(forKey: "skipForwardInterval")
        if savedSkipForward > 0 {
            skipForwardInterval = savedSkipForward
        }
        
        let savedSkipBack = UserDefaults.standard.double(forKey: "skipBackwardInterval")
        if savedSkipBack > 0 {
            skipBackwardInterval = savedSkipBack
        }
        
        setupAudioSession()
        setupRemoteCommands()
    }
    
    // MARK: - Setup
    
    private func setupAudioSession() {
        // macOS doesn't require audio session setup like iOS
        // but we can configure for background audio if needed
    }
    
    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Play/Pause
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.play()
            }
            return .success
        }
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.pause()
            }
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.togglePlayPause()
            }
            return .success
        }
        
        // Skip forward/backward
        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(value: skipForwardInterval)]
        commandCenter.skipForwardCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.skipForward()
            }
            return .success
        }
        
        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(value: skipBackwardInterval)]
        commandCenter.skipBackwardCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.skipBackward()
            }
            return .success
        }
        
        // Seek
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let positionEvent = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            Task { @MainActor in
                self?.seek(to: positionEvent.positionTime)
            }
            return .success
        }
    }
    
    // MARK: - Playback Control
    
    /// Play an episode
    func play(episode: Episode, podcast: Podcast) async {
        // Stop current playback
        stop()
        
        // Determine audio source
        guard let audioSource = resolveAudioSource(for: episode) else {
            playbackError = "No audio source available for this episode"
            return
        }
        
        isLoading = true
        currentEpisode = episode
        currentPodcast = podcast
        
        // Create player item
        let asset = AVURLAsset(url: audioSource)
        playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        // Observe player item status
        playerItem?.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.handlePlayerItemStatus(status)
            }
            .store(in: &cancellables)
        
        // Observe when playback ends
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handlePlaybackEnded()
            }
            .store(in: &cancellables)
        
        // Set up time observer for progress updates
        setupTimeObserver()
        
        // Restore playback position if resuming
        if episode.playbackPosition > 0 {
            let position = CMTime(seconds: Double(episode.playbackPosition), preferredTimescale: 1)
            await player?.seek(to: position)
            currentTime = Double(episode.playbackPosition)
        }
        
        // Start position save timer
        startPositionSaveTimer()
        
        // Update Now Playing info
        updateNowPlayingInfo()
        
        print("▶️ Playing: \(episode.title)")
    }
    
    /// Play (resume) current episode
    func play() {
        guard let player = player else { return }
        player.rate = playbackSpeed
        isPlaying = true
        updateNowPlayingInfo()
    }
    
    /// Pause playback
    func pause() {
        player?.pause()
        isPlaying = false
        saveCurrentPosition()
        updateNowPlayingInfo()
    }
    
    /// Toggle play/pause
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    /// Stop playback completely
    func stop() {
        saveCurrentPosition()
        
        // Remove time observer
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        
        // Stop timer
        positionSaveTimer?.invalidate()
        positionSaveTimer = nil
        
        // Clear player
        player?.pause()
        player = nil
        playerItem = nil
        
        // Clear state
        currentEpisode = nil
        currentPodcast = nil
        isPlaying = false
        isLoading = false
        currentTime = 0
        duration = 0
        lastSavedPosition = 0
        
        // Clear subscriptions
        cancellables.removeAll()
        
        // Clear Now Playing
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    /// Skip forward by configured interval
    func skipForward() {
        seek(to: currentTime + skipForwardInterval)
    }
    
    /// Skip backward by configured interval
    func skipBackward() {
        seek(to: currentTime - skipBackwardInterval)
    }
    
    /// Seek to specific position in seconds
    func seek(to seconds: Double) {
        let clamped = max(0, min(seconds, duration))
        let time = CMTime(seconds: clamped, preferredTimescale: 1)
        
        player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            Task { @MainActor in
                self?.currentTime = clamped
                self?.updateNowPlayingInfo()
            }
        }
    }
    
    /// Seek to progress (0.0 to 1.0)
    func seek(toProgress progress: Double) {
        let seconds = progress * duration
        seek(to: seconds)
    }
    
    /// Cycle to next playback speed
    func cycleSpeed() {
        guard let currentIndex = Self.availableSpeeds.firstIndex(of: playbackSpeed) else {
            playbackSpeed = 1.0
            return
        }
        
        let nextIndex = (currentIndex + 1) % Self.availableSpeeds.count
        playbackSpeed = Self.availableSpeeds[nextIndex]
    }
    
    // MARK: - Private Methods
    
    private func resolveAudioSource(for episode: Episode) -> URL? {
        // Prefer local downloaded file
        if episode.downloadStatus == .downloaded,
           let downloadPath = episode.downloadPath {
            let localURL = URL(fileURLWithPath: downloadPath)
            if FileManager.default.fileExists(atPath: localURL.path) {
                return localURL
            }
        }
        
        // Fall back to remote URL
        if let audioURLString = episode.audioURL,
           let remoteURL = URL(string: audioURLString) {
            return remoteURL
        }
        
        return nil
    }
    
    private func handlePlayerItemStatus(_ status: AVPlayerItem.Status) {
        switch status {
        case .readyToPlay:
            isLoading = false
            if let duration = playerItem?.duration.seconds, duration.isFinite {
                self.duration = duration
            }
            play()
            
        case .failed:
            isLoading = false
            playbackError = playerItem?.error?.localizedDescription ?? "Failed to load audio"
            print("❌ Playback failed: \(playbackError ?? "unknown")")
            
        case .unknown:
            break
            
        @unknown default:
            break
        }
    }
    
    private func handlePlaybackEnded() {
        print("✅ Playback finished: \(currentEpisode?.title ?? "unknown")")
        
        // Mark as played
        if let episode = currentEpisode {
            Task {
                try? await repository.markAsPlayed(episodeId: episode.id, played: true)
                try? await repository.updatePlaybackPosition(episodeId: episode.id, position: 0)
            }
        }
        
        // Post notification
        NotificationCenter.default.post(name: .playbackEnded, object: nil)
        
        stop()
    }
    
    private func setupTimeObserver() {
        // Update every 0.5 seconds
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            
            let seconds = time.seconds
            if seconds.isFinite {
                self.currentTime = seconds
            }
            
            // Update duration if not yet set
            if self.duration == 0, let itemDuration = self.playerItem?.duration.seconds, itemDuration.isFinite {
                self.duration = itemDuration
            }
        }
    }
    
    private func startPositionSaveTimer() {
        positionSaveTimer?.invalidate()
        
        // Save position every 10 seconds
        positionSaveTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.saveCurrentPosition()
            }
        }
    }
    
    private func saveCurrentPosition() {
        guard let episode = currentEpisode else { return }
        
        let position = Int(currentTime)
        
        // Only save if position changed significantly (> 5 seconds)
        guard abs(position - lastSavedPosition) > 5 else { return }
        
        lastSavedPosition = position
        
        Task {
            try? await repository.updatePlaybackPosition(episodeId: episode.id, position: position)
        }
    }
    
    private func updateNowPlayingInfo() {
        guard let episode = currentEpisode else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }
        
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: episode.title,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? playbackSpeed : 0
        ]
        
        if let podcast = currentPodcast {
            info[MPMediaItemPropertyArtist] = podcast.title
            info[MPMediaItemPropertyAlbumTitle] = podcast.title
        }
        
        // Load artwork asynchronously
        if let artworkURLString = currentPodcast?.artworkURL,
           let artworkURL = URL(string: artworkURLString) {
            Task {
                if let (data, _) = try? await URLSession.shared.data(from: artworkURL),
                   let image = NSImage(data: data) {
                    let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                    var updatedInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
                    updatedInfo[MPMediaItemPropertyArtwork] = artwork
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = updatedInfo
                }
            }
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    // MARK: - Helpers
    
    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite && seconds >= 0 else { return "--:--" }
        
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let secs = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let playbackStarted = Notification.Name("PodVault.playbackStarted")
    static let playbackEnded = Notification.Name("PodVault.playbackEnded")
    static let playbackPositionChanged = Notification.Name("PodVault.playbackPositionChanged")
}
