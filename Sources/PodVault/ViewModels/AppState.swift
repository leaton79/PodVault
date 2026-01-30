import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var podcasts: [Podcast] = []
    @Published var selectedPodcast: Podcast?
    @Published var selectedEpisode: Episode?
    @Published var showAddFeedSheet = false
    @Published var showActivityLog = false
    @Published var showImportOPML = false
    @Published var showExportOPML = false
    @Published var showExportJSON = false
    @Published var showDownloadsSheet = false
    @Published var isSyncing = false
    @Published var isDownloading = false
    @Published var downloadProgress: Double = 0
    @Published var pendingDownloadCount = 0
    @Published var errorMessage: String?
    
    let playbackManager = PlaybackManager.shared
    
    init() {
        Task {
            await loadPodcasts()
        }
    }
    
    func loadPodcasts() async {
        do {
            let repo = PodcastRepository()
            podcasts = try await repo.getAllPodcasts()
        } catch {
            print("Failed to load podcasts: \(error)")
        }
    }
    
    func syncAllFeeds() async {
        // Placeholder
    }
    
    func search(query: String) async {
        // Placeholder
    }
}
