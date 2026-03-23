import Foundation

struct PodcastRefreshResult {
    let podcast: Podcast
    let newEpisodeCount: Int
}

actor LibraryService {
    private let feedService: FeedService
    private let repository: PodcastRepository

    init(
        feedService: FeedService = FeedService(),
        repository: PodcastRepository = PodcastRepository()
    ) {
        self.feedService = feedService
        self.repository = repository
    }

    func addPodcast(feedURL: String) async throws -> Podcast {
        let podcast = try await feedService.subscribe(feedURL: feedURL)
        return podcast
    }

    func refreshPodcast(_ podcast: Podcast) async throws -> PodcastRefreshResult {
        let result = try await feedService.fetchFeed(url: podcast.feedURL)
        let existingEpisodes = try await repository.getEpisodes(forPodcast: podcast.id)
        let existingIds = Set(existingEpisodes.map(\.id))
        let newEpisodeCount = result.episodes.filter { !existingIds.contains($0.id) }.count

        var refreshedPodcast = result.podcast
        refreshedPodcast.id = podcast.id
        refreshedPodcast.lastSyncAt = Date()

        try await repository.savePodcast(refreshedPodcast)
        try await repository.saveEpisodes(result.episodes)

        return PodcastRefreshResult(podcast: refreshedPodcast, newEpisodeCount: newEpisodeCount)
    }

    func deletePodcast(id: String) async throws {
        try await repository.deletePodcast(id: id)
    }

    func loadFavorites(legacyFavoritesURL: URL) async throws -> (podcastIDs: Set<String>, episodes: [Episode]) {
        if FileManager.default.fileExists(atPath: legacyFavoritesURL.path) {
            try await migrateLegacyFavoritesIfNeeded(from: legacyFavoritesURL)
        }

        async let podcasts = repository.getFavoritePodcasts()
        async let episodes = repository.getFavoriteEpisodes()
        let (favoritePodcasts, favoriteEpisodes) = try await (podcasts, episodes)
        return (Set(favoritePodcasts.map(\.id)), favoriteEpisodes)
    }

    func setPodcastFavorite(id: String, isFavorite: Bool) async throws {
        try await repository.setPodcastFavorite(id: id, isFavorite: isFavorite)
    }

    func setEpisodeFavorite(id: String, isFavorite: Bool) async throws {
        try await repository.setEpisodeFavorite(id: id, isFavorite: isFavorite)
    }

    func markEpisodePlayed(id: String, played: Bool, playbackPosition: Int = 0) async {
        do {
            try await repository.markAsPlayed(episodeId: id, played: played)
            try await repository.updatePlaybackPosition(episodeId: id, position: playbackPosition)
        } catch {
            print("Error: \(error)")
        }
    }

    func clearEpisodeDownload(_ episode: Episode) async {
        var updatedEpisode = episode
        updatedEpisode.downloadStatus = .none
        updatedEpisode.downloadPath = nil
        try? await repository.saveEpisode(updatedEpisode)
    }

    func validateDownloadedEpisodes() async {
        guard let downloadedEpisodes = try? await repository.getDownloadedEpisodes() else {
            return
        }

        for var episode in downloadedEpisodes {
            guard let path = episode.downloadPath,
                  FileManager.default.fileExists(atPath: path) else {
                episode.downloadStatus = .none
                episode.downloadPath = nil
                try? await repository.saveEpisode(episode)
                continue
            }
        }
    }

    private func migrateLegacyFavoritesIfNeeded(from legacyFavoritesURL: URL) async throws {
        guard let data = try? Data(contentsOf: legacyFavoritesURL),
              let favorites = try? JSONDecoder().decode(FavoritesData.self, from: data) else {
            return
        }

        for podcastId in favorites.podcastIds {
            try? await repository.setPodcastFavorite(id: podcastId, isFavorite: true)
        }

        for episodeId in favorites.episodeIds {
            try? await repository.setEpisodeFavorite(id: episodeId, isFavorite: true)
        }

        try? FileManager.default.removeItem(at: legacyFavoritesURL)
    }
}
