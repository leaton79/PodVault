import Foundation
import GRDB

/// Represents a podcast subscription
struct Podcast: Identifiable, Codable, Equatable {
    var id: String
    var feedURL: String
    var title: String
    var author: String?
    var description: String?
    var artworkURL: String?
    var link: String?
    var lastSyncAt: Date?
    var autoDownload: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        feedURL: String,
        title: String = "",
        author: String? = nil,
        description: String? = nil,
        artworkURL: String? = nil,
        link: String? = nil,
        lastSyncAt: Date? = nil,
        autoDownload: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.feedURL = feedURL
        self.title = title
        self.author = author
        self.description = description
        self.artworkURL = artworkURL
        self.link = link
        self.lastSyncAt = lastSyncAt
        self.autoDownload = autoDownload
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - GRDB TableRecord & FetchableRecord
extension Podcast: TableRecord, FetchableRecord, PersistableRecord {
    static var databaseTableName: String { "podcasts" }
    
    enum Columns: String, ColumnExpression {
        case id, feedURL, title, author, description, artworkURL, link
        case lastSyncAt, autoDownload, createdAt, updatedAt
    }
}

// MARK: - Computed Properties
extension Podcast {
    var displayTitle: String {
        title.isEmpty ? "Untitled Podcast" : title
    }
}
