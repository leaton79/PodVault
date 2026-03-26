import XCTest
@testable import PodVault

final class PodVaultTests: XCTestCase {
    private var testDatabasePath: String {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("podvault-tests-\(UUID().uuidString).sqlite")
            .path
    }
    
    func testPodcastCreation() {
        let podcast = Podcast(
            feedURL: "https://example.com/feed.xml",
            title: "Test Podcast"
        )
        
        XCTAssertFalse(podcast.id.isEmpty)
        XCTAssertEqual(podcast.feedURL, "https://example.com/feed.xml")
        XCTAssertEqual(podcast.title, "Test Podcast")
        XCTAssertTrue(podcast.autoDownload)
        XCTAssertFalse(podcast.isFavorite)
    }
    
    func testEpisodeCreation() {
        let episode = Episode(
            podcastId: "test-podcast-id",
            guid: "episode-123",
            title: "Test Episode",
            duration: 3600
        )
        
        XCTAssertFalse(episode.id.isEmpty)
        XCTAssertEqual(episode.guid, "episode-123")
        XCTAssertEqual(episode.duration, 3600)
        XCTAssertEqual(episode.formattedDuration, "1:00:00")
        XCTAssertEqual(episode.downloadStatus, .none)
        XCTAssertFalse(episode.isFavorite)
    }
    
    func testEpisodeDurationFormatting() {
        let shortEpisode = Episode(
            podcastId: "test",
            guid: "1",
            duration: 125  // 2:05
        )
        XCTAssertEqual(shortEpisode.formattedDuration, "2:05")
        
        let longEpisode = Episode(
            podcastId: "test",
            guid: "2",
            duration: 7325  // 2:02:05
        )
        XCTAssertEqual(longEpisode.formattedDuration, "2:02:05")
        
        let noData = Episode(
            podcastId: "test",
            guid: "3"
        )
        XCTAssertEqual(noData.formattedDuration, "--:--")
    }
    
    func testActivityLogDisplay() {
        let log = ActivityLog(
            action: .sync,
            targetType: .podcast,
            targetName: "My Podcast",
            status: .success
        )
        
        XCTAssertTrue(log.displayMessage.contains("Synced"))
        XCTAssertTrue(log.displayMessage.contains("My Podcast"))
        XCTAssertTrue(log.displayMessage.contains("✅"))
    }

    func testLibraryViewModelSelectionStateResetsCorrectly() async {
        await MainActor.run {
            let viewModel = LibraryViewModel()
            let podcast = Podcast(id: "pod-1", feedURL: "https://example.com/feed.xml", title: "Architecture Weekly")

            viewModel.podcasts = [podcast]
            viewModel.selectedPodcastId = podcast.id
            viewModel.selectedEpisodeId = "ep-1"
            viewModel.searchText = "swift"

            viewModel.selectHistory()
            XCTAssertEqual(viewModel.currentView, .history)
            XCTAssertNil(viewModel.selectedPodcastId)
            XCTAssertNil(viewModel.selectedEpisodeId)
            XCTAssertEqual(viewModel.searchText, "")

            viewModel.selectedPodcastId = podcast.id
            viewModel.selectedEpisodeId = "ep-2"
            viewModel.searchText = "feeds"
            viewModel.selectCategory("News")

            XCTAssertEqual(viewModel.currentView, .category("News"))
            XCTAssertNil(viewModel.selectedPodcastId)
            XCTAssertNil(viewModel.selectedEpisodeId)
            XCTAssertEqual(viewModel.searchText, "")
            XCTAssertEqual(viewModel.listTitle, "News")
        }
    }

    func testLibraryViewModelAppliesFavoriteAndDownloadState() async {
        await MainActor.run {
            let viewModel = LibraryViewModel()
            let favoriteEpisode = makeEpisode(id: "ep-fav", podcastId: "pod-1", title: "Favorite Episode")
            let downloadedEpisode = makeEpisode(id: "ep-downloaded", podcastId: "pod-1", title: "Downloaded Episode")

            viewModel.applyFavorites(podcastIds: ["pod-1"], episodes: [favoriteEpisode])
            viewModel.downloadedEpisodesList = [downloadedEpisode]
            viewModel.setDownloadedEpisodeIds(["ep-downloaded"])

            XCTAssertEqual(viewModel.favoritePodcastIds, Set(["pod-1"]))
            XCTAssertEqual(viewModel.favoriteEpisodeIds, Set(["ep-fav"]))
            XCTAssertEqual(viewModel.favoriteEpisodesList.map(\.id), ["ep-fav"])
            XCTAssertEqual(viewModel.downloadedEpisodeIds, Set(["ep-downloaded"]))

            viewModel.removeDownloadedEpisode(id: "ep-downloaded")
            XCTAssertTrue(viewModel.downloadedEpisodeIds.isEmpty)
            XCTAssertTrue(viewModel.downloadedEpisodesList.isEmpty)
        }
    }

    func testLibraryViewModelContinueListeningUsesInProgressEpisodes() async {
        await MainActor.run {
            let viewModel = LibraryViewModel()
            let inProgress = makeEpisode(id: "ep-progress", podcastId: "pod-1", title: "Resume Me", duration: 300)

            viewModel.inProgressEpisodesList = [inProgress]
            viewModel.currentView = .continueListening

            XCTAssertEqual(viewModel.listTitle, "Continue Listening")
            XCTAssertTrue(viewModel.shouldShowEpisodeList)
            XCTAssertEqual(viewModel.displayedEpisodes().map(\.id), ["ep-progress"])
            XCTAssertEqual(viewModel.sidebarSelectionKey, "continueListening")
        }
    }

    func testLibraryViewModelFiltersAndSortsEpisodes() async {
        await MainActor.run {
            let viewModel = LibraryViewModel()
            let first = makeEpisode(id: "ep-1", podcastId: "pod-1", title: "Alpha Swift", duration: 120, pubDate: Date(timeIntervalSince1970: 1_000))
            let second = makeEpisode(id: "ep-2", podcastId: "pod-1", title: "Bravo Databases", duration: 360, pubDate: Date(timeIntervalSince1970: 2_000))
            let third = makeEpisode(id: "ep-3", podcastId: "pod-1", title: "Charlie Playback", duration: 240, pubDate: Date(timeIntervalSince1970: 3_000))

            viewModel.episodes = [first, second, third]
            viewModel.searchText = "a"
            viewModel.episodeFilter = .favorites
            viewModel.episodeSort = .longestFirst

            let filtered = viewModel.filteredAndSortedEpisodes(
                isPlayed: { $0.id == "ep-3" },
                resumePosition: { $0.id == "ep-2" ? 45 : 0 },
                downloadedEpisodeIds: ["ep-1", "ep-3"],
                favoriteEpisodeIds: ["ep-1", "ep-2"]
            )

            XCTAssertEqual(filtered.map(\.id), ["ep-2", "ep-1"])

            viewModel.episodeFilter = .inProgress
            let inProgress = viewModel.filteredAndSortedEpisodes(
                isPlayed: { _ in false },
                resumePosition: { $0.id == "ep-2" ? 45 : 0 },
                downloadedEpisodeIds: [],
                favoriteEpisodeIds: []
            )

            XCTAssertEqual(inProgress.map(\.id), ["ep-2"])
        }
    }

    func testLibraryViewModelSearchUsesMatchedEpisodeIdsWhenAvailable() async {
        await MainActor.run {
            let viewModel = LibraryViewModel()
            let first = makeEpisode(id: "ep-1", podcastId: "pod-1", title: "Alpha Swift")
            let second = makeEpisode(id: "ep-2", podcastId: "pod-1", title: "Bravo Databases")

            viewModel.episodes = [first, second]
            viewModel.searchText = "swift"
            viewModel.searchMatchedEpisodeIds = Set(["ep-2"])

            let filtered = viewModel.filteredAndSortedEpisodes(
                isPlayed: { _ in false },
                resumePosition: { _ in 0 },
                downloadedEpisodeIds: [],
                favoriteEpisodeIds: []
            )

            XCTAssertEqual(filtered.map(\.id), ["ep-2"])
        }
    }

    func testRepositoryPersistsPlaybackProgressAndPlayedState() async throws {
        let db = try DatabaseManager.makeTestDatabase(path: testDatabasePath)
        let repo = PodcastRepository(db: db)

        let podcast = Podcast(id: "pod-1", feedURL: "https://example.com/feed.xml", title: "Test Podcast")
        let episode = Episode(id: "ep-1", podcastId: podcast.id, guid: "guid-1", title: "Episode One")

        try await repo.savePodcast(podcast)
        try await repo.saveEpisode(episode)
        try await repo.updatePlaybackPosition(episodeId: episode.id, position: 142)
        try await repo.markAsPlayed(episodeId: episode.id, played: true)

        let stored = try await repo.getEpisode(id: episode.id)
        XCTAssertEqual(stored?.playbackPosition, 142)
        XCTAssertEqual(stored?.isPlayed, true)
    }

    func testRepositorySearchEpisodesUsesFTSIndex() async throws {
        let db = try DatabaseManager.makeTestDatabase(path: testDatabasePath)
        let repo = PodcastRepository(db: db)

        let podcast = Podcast(id: "pod-1", feedURL: "https://example.com/feed.xml", title: "Search Podcast")
        let matching = Episode(
            id: "ep-fts-1",
            podcastId: podcast.id,
            guid: "guid-fts-1",
            title: "Swift Concurrency Deep Dive",
            episodeDescription: "Actors, async await, and structured concurrency"
        )
        let other = Episode(
            id: "ep-fts-2",
            podcastId: podcast.id,
            guid: "guid-fts-2",
            title: "Gardening Basics",
            episodeDescription: "Soil and watering"
        )

        try await repo.savePodcast(podcast)
        try await repo.saveEpisodes([matching, other])

        let results = try await repo.searchEpisodes(query: "concurr")
        XCTAssertEqual(results.map(\.id), ["ep-fts-1"])
    }

    func testFeedInputParserDeduplicatesAndSplitsBatchInput() {
        let urls = FeedInputParser.urls(from: """
        https://example.com/one.xml
        https://example.com/two.xml, https://example.com/one.xml;
        https://example.com/three.xml
        """)

        XCTAssertEqual(
            urls,
            [
                "https://example.com/one.xml",
                "https://example.com/two.xml",
                "https://example.com/three.xml"
            ]
        )
    }

    func testRepositoryCleanupArchivesDownloadedEpisodesAndHidesPodcast() async throws {
        let db = try DatabaseManager.makeTestDatabase(path: testDatabasePath)
        let repo = PodcastRepository(db: db)

        let stalePodcast = Podcast(
            id: "stale-podcast",
            feedURL: "https://example.com/stale.xml",
            title: "Stale Feed",
            lastSyncAt: Date(timeIntervalSince1970: 0)
        )
        let downloadedEpisode = Episode(
            id: "downloaded-ep",
            podcastId: stalePodcast.id,
            guid: "downloaded-guid",
            title: "Downloaded Episode",
            pubDate: Date(timeIntervalSince1970: 1000),
            downloadStatus: .downloaded,
            downloadPath: "/tmp/downloaded.mp3"
        )
        let streamingEpisode = Episode(
            id: "streaming-ep",
            podcastId: stalePodcast.id,
            guid: "streaming-guid",
            title: "Stream Only",
            pubDate: Date(timeIntervalSince1970: 1000)
        )

        try await repo.savePodcast(stalePodcast)
        try await repo.saveEpisodes([downloadedEpisode, streamingEpisode])

        let inactive = try await repo.getInactivePodcasts(olderThan: Date())
        XCTAssertEqual(inactive.map(\.id), [stalePodcast.id])

        let preservedCount = try await repo.archivePodcastDownloadsAndRemoveSubscription(id: stalePodcast.id)
        XCTAssertEqual(preservedCount, 1)

        let visiblePodcasts = try await repo.getAllPodcasts()
        XCTAssertTrue(visiblePodcasts.isEmpty)

        let archivedPodcast = try await repo.getPodcast(id: stalePodcast.id)
        XCTAssertEqual(archivedPodcast?.feedURL, "podvault://archived/\(stalePodcast.id)")
        XCTAssertEqual(archivedPodcast?.autoDownload, false)

        let archivedEpisodes = try await repo.getEpisodes(forPodcast: stalePodcast.id)
        XCTAssertEqual(archivedEpisodes.map(\.id), ["downloaded-ep"])
        XCTAssertEqual(archivedEpisodes.first?.downloadPath, "/tmp/downloaded.mp3")
    }

    func testRefreshSummaryIncludesFailuresInSubtitle() {
        let summary = RefreshSummary.libraryRefresh(
            refreshedFeedCount: 2,
            newEpisodeCount: 5,
            failedFeeds: ["Broken Feed"]
        )

        XCTAssertEqual(summary.title, "Refresh finished with issues")
        XCTAssertEqual(summary.subtitle, "2 feeds, 5 new episodes, 1 failed")
        XCTAssertEqual(summary.failedFeeds, ["Broken Feed"])
    }

    func testOPMLServiceParsesNestedFeedsFromOPMLData() async throws {
        let data = Data(
            """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <head>
                <title>Subscriptions</title>
              </head>
              <body>
                <outline text="Tech">
                  <outline type="rss" text="Swift Talk" xmlUrl="https://example.com/swift.xml" htmlUrl="https://example.com/swift"/>
                </outline>
              </body>
            </opml>
            """.utf8
        )

        let document = try await OPMLService().parseOPML(from: data)

        XCTAssertEqual(document.title, "Subscriptions")
        XCTAssertEqual(document.feeds.count, 1)
        XCTAssertEqual(document.feeds.first?.title, "Swift Talk")
        XCTAssertEqual(document.feeds.first?.feedURL, "https://example.com/swift.xml")
        XCTAssertEqual(document.feeds.first?.htmlURL, "https://example.com/swift")
    }

    private func makeEpisode(
        id: String,
        podcastId: String,
        title: String,
        duration: Int? = nil,
        pubDate: Date? = nil
    ) -> Episode {
        Episode(
            id: id,
            podcastId: podcastId,
            guid: id,
            title: title,
            pubDate: pubDate,
            duration: duration
        )
    }
}
