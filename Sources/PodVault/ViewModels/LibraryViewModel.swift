import SwiftUI

@MainActor
final class LibraryViewModel: ObservableObject {
    @Published var podcasts: [Podcast] = []
    @Published var episodes: [Episode] = []
    @Published var allEpisodes: [Episode] = []
    @Published var inProgressEpisodesList: [Episode] = []
    @Published var downloadedEpisodesList: [Episode] = []
    @Published var favoriteEpisodesList: [Episode] = []
    @Published var favoritePodcastIds: Set<String> = []
    @Published var favoriteEpisodeIds: Set<String> = []
    @Published var downloadedEpisodeIds: Set<String> = []
    @Published var selectedPodcastId: String?
    @Published var selectedEpisodeId: String?
    @Published var currentView: LibraryView = .none
    @Published var searchText = ""
    @Published var podcastSearchText = ""
    @Published var isRefreshing = false
    @Published var episodeFilter: EpisodeFilter = .all
    @Published var episodeSort: EpisodeSort = .newestFirst
    @Published var searchMatchedEpisodeIds: Set<String>?
    
    private let repository: PodcastRepository?
    
    init(repository: PodcastRepository? = nil) {
        self.repository = repository
    }

    private var activeRepository: PodcastRepository {
        repository ?? PodcastRepository()
    }
    
    func loadPodcasts() async {
        do {
            podcasts = try await activeRepository.getAllPodcasts()
        } catch {
            print("Error: \(error)")
        }
    }
    
    func loadEpisodes(for podcast: Podcast) async {
        do {
            episodes = try await activeRepository.getEpisodes(forPodcast: podcast.id)
        } catch {
            print("Error: \(error)")
        }
    }
    
    func loadAllEpisodes() async {
        do {
            allEpisodes = try await activeRepository.getAllEpisodes()
        } catch {
            print("Error: \(error)")
        }
    }

    func loadInProgressEpisodesList() async -> Set<String> {
        do {
            let inProgress = try await activeRepository.getInProgressEpisodes()
            inProgressEpisodesList = inProgress
            return Set(inProgress.map(\.id))
        } catch {
            print("Error: \(error)")
            return []
        }
    }
    
    func loadDownloadedEpisodesList() async -> Set<String> {
        do {
            let downloaded = try await activeRepository.getDownloadedEpisodes()
            downloadedEpisodesList = downloaded
            downloadedEpisodeIds = Set(downloaded.map(\.id))
            return downloadedEpisodeIds
        } catch {
            print("Error: \(error)")
            return []
        }
    }
    
    func loadFavoriteEpisodesList() async -> Set<String> {
        do {
            let favorites = try await activeRepository.getFavoriteEpisodes()
            favoriteEpisodesList = favorites
            favoriteEpisodeIds = Set(favorites.map(\.id))
            return favoriteEpisodeIds
        } catch {
            print("Error: \(error)")
            return []
        }
    }

    func refreshSearchResults() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty, query.count >= 2 else {
            searchMatchedEpisodeIds = nil
            return
        }

        do {
            async let episodeMatches = activeRepository.searchEpisodes(query: query)
            async let noteMatches = activeRepository.searchNotes(query: query)
            let (episodes, notes) = try await (episodeMatches, noteMatches)
            searchMatchedEpisodeIds = Set(episodes.map(\.id)).union(notes.map(\.id))
        } catch {
            print("Error: \(error)")
            searchMatchedEpisodeIds = nil
        }
    }

    func applyFavorites(podcastIds: Set<String>, episodes: [Episode]) {
        favoritePodcastIds = podcastIds
        favoriteEpisodeIds = Set(episodes.map(\.id))
        favoriteEpisodesList = episodes
    }

    func setDownloadedEpisodeIds(_ ids: Set<String>) {
        downloadedEpisodeIds = ids
    }

    func removeDownloadedEpisode(id: String) {
        downloadedEpisodeIds.remove(id)
        downloadedEpisodesList.removeAll { $0.id == id }
    }

    func selectAllEpisodes() async {
        currentView = .allEpisodes
        selectedPodcastId = nil
        selectedEpisodeId = nil
        searchText = ""
        await loadAllEpisodes()
    }

    func selectHistory() {
        currentView = .history
        selectedPodcastId = nil
        selectedEpisodeId = nil
        searchText = ""
        searchMatchedEpisodeIds = nil
    }

    func selectContinueListening() async {
        currentView = .continueListening
        selectedPodcastId = nil
        selectedEpisodeId = nil
        searchText = ""
        searchMatchedEpisodeIds = nil
        _ = await loadInProgressEpisodesList()
    }

    func selectDownloads() async {
        currentView = .downloads
        selectedPodcastId = nil
        selectedEpisodeId = nil
        searchText = ""
        searchMatchedEpisodeIds = nil
        _ = await loadDownloadedEpisodesList()
    }

    func selectFavoritePodcasts() {
        currentView = .favoritePodcasts
        selectedPodcastId = nil
        selectedEpisodeId = nil
        searchText = ""
        searchMatchedEpisodeIds = nil
    }

    func selectFavoriteEpisodes() async {
        currentView = .favoriteEpisodes
        selectedPodcastId = nil
        selectedEpisodeId = nil
        searchText = ""
        searchMatchedEpisodeIds = nil
        _ = await loadFavoriteEpisodesList()
    }

    func selectCategory(_ category: String) {
        currentView = .category(category)
        selectedPodcastId = nil
        selectedEpisodeId = nil
        searchText = ""
        searchMatchedEpisodeIds = nil
    }

    func selectPodcast(_ podcast: Podcast) async {
        currentView = .none
        selectedPodcastId = podcast.id
        selectedEpisodeId = nil
        searchText = ""
        searchMatchedEpisodeIds = nil
        await loadEpisodes(for: podcast)
    }

    func handleDeletedPodcast(id: String) {
        favoritePodcastIds.remove(id)
        if selectedPodcastId == id {
            selectedPodcastId = nil
            selectedEpisodeId = nil
        }
    }

    func reloadVisibleContent(afterPodcastUpdate podcast: Podcast) async {
        if selectedPodcastId == podcast.id {
            await loadEpisodes(for: podcast)
        }
        if currentView == .allEpisodes {
            await loadAllEpisodes()
        }
    }

    func reloadVisibleContent(afterEpisodeUpdateInPodcastId podcastId: String) async {
        if currentView == .favoriteEpisodes {
            _ = await loadFavoriteEpisodesList()
        }
        if currentView == .continueListening {
            _ = await loadInProgressEpisodesList()
        }
        if selectedPodcastId == podcastId, let podcast = selectedPodcast {
            await loadEpisodes(for: podcast)
        }
    }

    func reloadVisibleContentAfterLibraryRefresh() async {
        if currentView == .continueListening {
            _ = await loadInProgressEpisodesList()
        }
        if let podcast = selectedPodcast {
            await loadEpisodes(for: podcast)
        }
        if currentView == .allEpisodes {
            await loadAllEpisodes()
        }
    }
    
    var selectedPodcast: Podcast? {
        podcasts.first { $0.id == selectedPodcastId }
    }
    
    var sidebarSelectionKey: String {
        switch currentView {
        case .none: return "none"
        case .continueListening: return "continueListening"
        case .downloads: return "downloads"
        case .favoritePodcasts: return "favoritePodcasts"
        case .favoriteEpisodes: return "favoriteEpisodes"
        case .allEpisodes: return "allEpisodes"
        case .history: return "history"
        case .category(let category): return "category:\(category)"
        }
    }
    
    var filteredPodcasts: [Podcast] {
        guard !podcastSearchText.isEmpty else { return podcasts }
        return podcasts.filter { $0.title.localizedCaseInsensitiveContains(podcastSearchText) }
    }
    
    var listTitle: String {
        switch currentView {
        case .continueListening: return "Continue Listening"
        case .downloads: return "Downloads"
        case .favoritePodcasts: return "Favorite Podcasts"
        case .favoriteEpisodes: return "Favorite Episodes"
        case .allEpisodes: return "All Episodes"
        case .history: return "History"
        case .category(let category): return category
        case .none: return selectedPodcast?.title ?? "Episodes"
        }
    }
    
    var shouldShowEpisodeList: Bool {
        currentView == .continueListening || currentView == .downloads || currentView == .favoriteEpisodes || currentView == .allEpisodes || selectedPodcast != nil
    }
    
    func selectedEpisode() -> Episode? {
        displayedEpisodes().first { $0.id == selectedEpisodeId }
    }
    
    func displayedEpisodes() -> [Episode] {
        switch currentView {
        case .continueListening: return inProgressEpisodesList
        case .downloads: return downloadedEpisodesList
        case .favoriteEpisodes: return favoriteEpisodesList
        case .allEpisodes: return allEpisodes
        default: return episodes
        }
    }
    
    func filteredAndSortedEpisodes(
        isPlayed: (Episode) -> Bool,
        resumePosition: (Episode) -> Double,
        downloadedEpisodeIds: Set<String>,
        favoriteEpisodeIds: Set<String>
    ) -> [Episode] {
        var result = displayedEpisodes()
        
        switch episodeFilter {
        case .all:
            break
        case .unplayed:
            result = result.filter { !isPlayed($0) && resumePosition($0) == 0 }
        case .inProgress:
            result = result.filter { resumePosition($0) > 0 && !isPlayed($0) }
        case .downloaded:
            result = result.filter { downloadedEpisodeIds.contains($0.id) }
        case .favorites:
            result = result.filter { favoriteEpisodeIds.contains($0.id) }
        }
        
        if !searchText.isEmpty {
            if let searchMatchedEpisodeIds {
                result = result.filter { searchMatchedEpisodeIds.contains($0.id) }
            } else {
                result = result.filter {
                    $0.title.localizedCaseInsensitiveContains(searchText) ||
                    ($0.episodeDescription?.localizedCaseInsensitiveContains(searchText) ?? false)
                }
            }
        }
        
        switch episodeSort {
        case .newestFirst:
            result.sort { ($0.pubDate ?? .distantPast) > ($1.pubDate ?? .distantPast) }
        case .oldestFirst:
            result.sort { ($0.pubDate ?? .distantPast) < ($1.pubDate ?? .distantPast) }
        case .longestFirst:
            result.sort { ($0.duration ?? 0) > ($1.duration ?? 0) }
        case .shortestFirst:
            result.sort { ($0.duration ?? 0) < ($1.duration ?? 0) }
        case .titleAZ:
            result.sort { $0.title.localizedCompare($1.title) == .orderedAscending }
        case .titleZA:
            result.sort { $0.title.localizedCompare($1.title) == .orderedDescending }
        }
        
        return result
    }
}
