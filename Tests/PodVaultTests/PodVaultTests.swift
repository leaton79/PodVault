import XCTest
@testable import PodVault

final class PodVaultTests: XCTestCase {
    
    func testPodcastCreation() {
        let podcast = Podcast(
            feedURL: "https://example.com/feed.xml",
            title: "Test Podcast"
        )
        
        XCTAssertFalse(podcast.id.isEmpty)
        XCTAssertEqual(podcast.feedURL, "https://example.com/feed.xml")
        XCTAssertEqual(podcast.title, "Test Podcast")
        XCTAssertTrue(podcast.autoDownload)
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
}
