import Foundation
import Combine
import SwiftUI

/// Manages automatic background feed synchronization
///
/// The scheduler runs on a configurable interval (stored in UserDefaults via @AppStorage).
/// It coordinates with the FeedService to fetch new episodes and logs all activity.
///
/// Intervals:
/// - 0 = Manual only (scheduler disabled)
/// - 15/30/60/120/360 = Minutes between syncs
@MainActor
final class SyncScheduler: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = SyncScheduler()
    
    // MARK: - Published State
    
    /// Whether a sync is currently in progress
    @Published private(set) var isSyncing: Bool = false
    
    /// Last successful sync completion time
    @Published private(set) var lastSyncTime: Date?
    
    /// Next scheduled sync time (nil if manual only)
    @Published private(set) var nextSyncTime: Date?
    
    /// Results from the most recent sync
    @Published private(set) var lastSyncResult: SyncResult?
    
    // MARK: - Configuration
    
    /// Sync interval in minutes (0 = manual only)
    /// This mirrors the @AppStorage value in Settings
    var syncIntervalMinutes: Int = 60 {
        didSet {
            if oldValue != syncIntervalMinutes {
                print("📅 Sync interval changed: \(oldValue) → \(syncIntervalMinutes) minutes")
                reschedule()
            }
        }
    }
    
    // MARK: - Private Properties
    
    private var timer: Timer?
    private lazy var feedService = FeedService()
    private lazy var repository = PodcastRepository()
    private var cancellables = Set<AnyCancellable>()
    
    /// Lock to prevent concurrent syncs
    private var syncLock = false
    
    // MARK: - Types
    
    struct SyncResult {
        let startTime: Date
        let endTime: Date
        let podcastsSynced: Int
        let newEpisodesFound: Int
        let errors: [SyncError]
        
        var duration: TimeInterval {
            endTime.timeIntervalSince(startTime)
        }
        
        var isSuccess: Bool {
            errors.isEmpty
        }
        
        var summary: String {
            if errors.isEmpty {
                return "Synced \(podcastsSynced) feeds, found \(newEpisodesFound) new episodes"
            } else {
                return "Synced with \(errors.count) error(s), found \(newEpisodesFound) new episodes"
            }
        }
    }
    
    struct SyncError: Identifiable {
        let id = UUID()
        let podcastId: String
        let podcastTitle: String
        let error: Error
        
        var localizedDescription: String {
            "\(podcastTitle): \(error.localizedDescription)"
        }
    }
    
    // MARK: - Initialization
    
    private init() {
        // Load initial interval from UserDefaults
        syncIntervalMinutes = UserDefaults.standard.integer(forKey: "syncInterval")
        if syncIntervalMinutes == 0 {
            // Default to 60 minutes if not set (0 could mean "not set" or "manual")
            // Check if key exists to distinguish
            if UserDefaults.standard.object(forKey: "syncInterval") == nil {
                syncIntervalMinutes = 60
            }
        }
        
        // Observe changes to sync interval in UserDefaults
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                let newInterval = UserDefaults.standard.integer(forKey: "syncInterval")
                if self?.syncIntervalMinutes != newInterval {
                    self?.syncIntervalMinutes = newInterval
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /// Start the background sync scheduler
    func start() {
        print("🚀 SyncScheduler starting with interval: \(syncIntervalMinutes) minutes")
        
        // Perform initial sync after a short delay (let app finish launching)
        if syncIntervalMinutes > 0 {
            Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
                await syncAllFeeds()
            }
        }
        
        scheduleNextSync()
    }
    
    /// Stop the background sync scheduler
    func stop() {
        print("🛑 SyncScheduler stopped")
        timer?.invalidate()
        timer = nil
        nextSyncTime = nil
    }
    
    /// Manually trigger a sync (respects sync lock)
    func syncNow() async {
        await syncAllFeeds()
    }
    
    /// Sync a single podcast
    func syncPodcast(_ podcast: Podcast) async -> Int {
        guard !syncLock else {
            print("⚠️ Sync already in progress, skipping single podcast sync")
            return 0
        }
        
        do {
            let newCount = try await feedService.syncPodcast(podcast)
            return newCount
        } catch {
            print("❌ Failed to sync \(podcast.title): \(error)")
            return 0
        }
    }
    
    // MARK: - Private Methods
    
    private func scheduleNextSync() {
        timer?.invalidate()
        timer = nil
        
        guard syncIntervalMinutes > 0 else {
            print("📅 Manual sync mode - no automatic sync scheduled")
            nextSyncTime = nil
            return
        }
        
        let interval = TimeInterval(syncIntervalMinutes * 60)
        nextSyncTime = Date().addingTimeInterval(interval)
        
        print("📅 Next sync scheduled for: \(nextSyncTime!.formatted(date: .omitted, time: .shortened))")
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.syncAllFeeds()
            }
        }
        
        // Make sure timer runs even when UI is tracking
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func reschedule() {
        scheduleNextSync()
    }
    
    private func syncAllFeeds() async {
        // Prevent concurrent syncs
        guard !syncLock else {
            print("⚠️ Sync already in progress, skipping")
            return
        }
        
        syncLock = true
        isSyncing = true
        
        let startTime = Date()
        var totalNewEpisodes = 0
        var errors: [SyncError] = []
        var podcastsSynced = 0
        
        // Log sync start
        try? await repository.logActivity(ActivityLog(
            action: .sync,
            targetType: .library,
            targetName: "All Feeds",
            status: .started
        ))
        
        do {
            let podcasts = try await repository.getAllPodcasts()
            
            for podcast in podcasts {
                do {
                    let newCount = try await feedService.syncPodcast(podcast)
                    totalNewEpisodes += newCount
                    podcastsSynced += 1
                } catch {
                    print("⚠️ Failed to sync \(podcast.title): \(error)")
                    errors.append(SyncError(
                        podcastId: podcast.id,
                        podcastTitle: podcast.title,
                        error: error
                    ))
                }
            }
            
            let endTime = Date()
            let result = SyncResult(
                startTime: startTime,
                endTime: endTime,
                podcastsSynced: podcastsSynced,
                newEpisodesFound: totalNewEpisodes,
                errors: errors
            )
            
            lastSyncResult = result
            lastSyncTime = endTime
            
            // Log sync completion
            let details = """
            {"podcasts_synced": \(podcastsSynced), "new_episodes": \(totalNewEpisodes), "errors": \(errors.count), "duration_seconds": \(Int(result.duration))}
            """
            
            try? await repository.logActivity(ActivityLog(
                action: .sync,
                targetType: .library,
                targetName: "All Feeds",
                details: details,
                status: errors.isEmpty ? .success : .success, // Still success if some worked
                errorMessage: errors.isEmpty ? nil : "\(errors.count) feed(s) failed"
            ))
            
            print("✅ Sync complete: \(result.summary)")
            
            // Post notification for new episodes
            if totalNewEpisodes > 0 {
                postNewEpisodesNotification(count: totalNewEpisodes)
            }
            
        } catch {
            print("❌ Sync failed: \(error)")
            
            try? await repository.logActivity(ActivityLog(
                action: .sync,
                targetType: .library,
                targetName: "All Feeds",
                status: .failed,
                errorMessage: error.localizedDescription
            ))
        }
        
        isSyncing = false
        syncLock = false
        
        // Reschedule next sync
        if syncIntervalMinutes > 0 {
            nextSyncTime = Date().addingTimeInterval(TimeInterval(syncIntervalMinutes * 60))
        }
    }
    
    private func postNewEpisodesNotification(count: Int) {
        // Post to NotificationCenter for AppState to observe
        NotificationCenter.default.post(
            name: .newEpisodesFound,
            object: nil,
            userInfo: ["count": count]
        )
        
        // Also post a system notification if app is in background
        Task {
            await sendSystemNotification(count: count)
        }
    }
    
    private func sendSystemNotification(count: Int) async {
        let center = UNUserNotificationCenter.current()
        
        // Request permission if needed
        let settings = await center.notificationSettings()
        if settings.authorizationStatus != .authorized {
            // Request permission
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                guard granted else { return }
            } catch {
                print("⚠️ Notification permission denied: \(error)")
                return
            }
        }
        
        let content = UNMutableNotificationContent()
        content.title = "New Episodes Available"
        content.body = count == 1 
            ? "1 new episode found" 
            : "\(count) new episodes found"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "new-episodes-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil // Deliver immediately
        )
        
        do {
            try await center.add(request)
        } catch {
            print("⚠️ Failed to send notification: \(error)")
        }
    }
    
    // MARK: - Formatted Properties
    
    var formattedLastSyncTime: String {
        guard let lastSyncTime else { return "Never" }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastSyncTime, relativeTo: Date())
    }
    
    var formattedNextSyncTime: String {
        guard syncIntervalMinutes > 0 else { return "Manual only" }
        guard let nextSyncTime else { return "Not scheduled" }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return "in " + formatter.localizedString(for: nextSyncTime, relativeTo: Date())
    }
    
    var syncIntervalDescription: String {
        switch syncIntervalMinutes {
        case 0: return "Manual only"
        case 15: return "Every 15 minutes"
        case 30: return "Every 30 minutes"
        case 60: return "Every hour"
        case 120: return "Every 2 hours"
        case 360: return "Every 6 hours"
        default: return "Every \(syncIntervalMinutes) minutes"
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let newEpisodesFound = Notification.Name("PodVault.newEpisodesFound")
    static let syncCompleted = Notification.Name("PodVault.syncCompleted")
}

// MARK: - UserNotifications Import

import UserNotifications
