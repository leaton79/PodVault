import Foundation
import GRDB

/// A tag that can be applied to episodes
struct Tag: Codable, Identifiable, Hashable {
    var id: Int64?
    var name: String
    var color: String?  // Optional hex color like "#FF5733"
    var createdAt: Date
    
    init(name: String, color: String? = nil) {
        self.name = name.lowercased().trimmingCharacters(in: .whitespaces)
        self.color = color
        self.createdAt = Date()
    }
    
    /// Display name (capitalized)
    var displayName: String {
        name.capitalized
    }
}

// MARK: - GRDB Conformance

extension Tag: FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "tags"
    
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

/// Junction record for episode-tag relationship
struct EpisodeTag: Codable {
    var episodeId: String
    var tagId: Int64
    var addedAt: Date
    
    init(episodeId: String, tagId: Int64) {
        self.episodeId = episodeId
        self.tagId = tagId
        self.addedAt = Date()
    }
}

extension EpisodeTag: FetchableRecord, PersistableRecord {
    static let databaseTableName = "episode_tags"
}

/// Episode notes storage
struct EpisodeNote: Codable {
    var episodeId: String
    var notes: String
    var updatedAt: Date
    
    init(episodeId: String, notes: String = "") {
        self.episodeId = episodeId
        self.notes = notes
        self.updatedAt = Date()
    }
}

extension EpisodeNote: FetchableRecord, PersistableRecord {
    static let databaseTableName = "episode_notes"
}
