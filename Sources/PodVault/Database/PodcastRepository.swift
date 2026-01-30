import Foundation
import GRDB

/// Repository for podcast and episode database operations
actor PodcastRepository {
    private let db: DatabasePool
    
    init(db: DatabasePool = DatabaseManager.shared.database) {
        self.db = db
    }
    
    // MARK: - Podcasts
    
    func getAllPodcasts() async throws -> [Podcast] {
        try await db.read { db in
            try Podcast.order(Podcast.Columns.title).fetchAll(db)
        }
    }
    
    func getPodcast(id: String) async throws -> Podcast? {
        try await db.read { db in
            try Podcast.fetchOne(db, key: id)
        }
    }
    
    func getPodcast(feedURL: String) async throws -> Podcast? {
        try await db.read { db in
            try Podcast.filter(Podcast.Columns.feedURL == feedURL).fetchOne(db)
        }
    }
    
    func savePodcast(_ podcast: Podcast) async throws {
        var podcast = podcast
        podcast.updatedAt = Date()
        try await db.write { db in
            try podcast.save(db)
        }
    }
    
    func deletePodcast(id: String) async throws {
        _ = try await db.write { db in
            try Podcast.deleteOne(db, key: id)
        }
    }
    
    // MARK: - Episodes
    
    func getEpisodes(forPodcast podcastId: String, limit: Int? = nil, offset: Int? = nil) async throws -> [Episode] {
        try await db.read { db in
            var request = Episode
                .filter(Episode.Columns.podcastId == podcastId)
                .order(Episode.Columns.pubDate.desc)
            
            if let limit = limit {
                request = request.limit(limit, offset: offset)
            }
            
            return try request.fetchAll(db)
        }
    }
    
    func getEpisode(id: String) async throws -> Episode? {
        try await db.read { db in
            try Episode.fetchOne(db, key: id)
        }
    }
    
    func getEpisode(podcastId: String, guid: String) async throws -> Episode? {
        try await db.read { db in
            try Episode
                .filter(Episode.Columns.podcastId == podcastId)
                .filter(Episode.Columns.guid == guid)
                .fetchOne(db)
        }
    }
    
    func saveEpisode(_ episode: Episode) async throws {
        var episode = episode
        episode.updatedAt = Date()
        try await db.write { db in
            try episode.save(db)
        }
    }
    
    func saveEpisodes(_ episodes: [Episode]) async throws {
        try await db.write { db in
            for var episode in episodes {
                episode.updatedAt = Date()
                try episode.save(db)
            }
        }
    }
    
    func deleteEpisode(id: String) async throws {
        _ = try await db.write { db in
            try Episode.deleteOne(db, key: id)
        }
    }
    
    func updatePlaybackPosition(episodeId: String, position: Int) async throws {
        try await db.write { db in
            try db.execute(
                sql: "UPDATE episodes SET playbackPosition = ?, updatedAt = ? WHERE id = ?",
                arguments: [position, Date(), episodeId]
            )
        }
    }
    
    func markAsPlayed(episodeId: String, played: Bool) async throws {
        try await db.write { db in
            try db.execute(
                sql: "UPDATE episodes SET isPlayed = ?, updatedAt = ? WHERE id = ?",
                arguments: [played, Date(), episodeId]
            )
        }
    }
    
    // MARK: - Saved Episodes
    
    func getSavedEpisodes() async throws -> [Episode] {
        try await db.read { db in
            try Episode
                .filter(Episode.Columns.isSaved == true)
                .order(Episode.Columns.updatedAt.desc)
                .fetchAll(db)
        }
    }
    
    // MARK: - New Episodes (In Progress)
    
    func getInProgressEpisodes() async throws -> [Episode] {
        try await db.read { db in
            try Episode
                .filter(Episode.Columns.playbackPosition > 0)
                .filter(Episode.Columns.isPlayed == false)
                .order(Episode.Columns.updatedAt.desc)
                .fetchAll(db)
        }
    }
    
    func getNewEpisodes(limit: Int = 50) async throws -> [Episode] {
        try await db.read { db in
            try Episode
                .filter(Episode.Columns.isPlayed == false)
                .filter(Episode.Columns.playbackPosition == 0)
                .order(Episode.Columns.pubDate.desc)
                .limit(limit)
                .fetchAll(db)
        }
    }
    
    // MARK: - Search
    
    func searchEpisodes(query: String) async throws -> [Episode] {
        try await db.read { db in
            let pattern = FTS5Pattern(matchingAllPrefixesIn: query)
            let sql = """
                SELECT episodes.*
                FROM episodes
                JOIN episodes_fts ON episodes.rowid = episodes_fts.rowid
                WHERE episodes_fts MATCH ?
                ORDER BY bm25(episodes_fts)
                LIMIT 100
                """
            return try Episode.fetchAll(db, sql: sql, arguments: [pattern?.rawPattern ?? query])
        }
    }
    
    // MARK: - Statistics
    
    func getEpisodeCount(forPodcast podcastId: String) async throws -> Int {
        try await db.read { db in
            try Episode
                .filter(Episode.Columns.podcastId == podcastId)
                .fetchCount(db)
        }
    }
    
    func getTotalEpisodeCount() async throws -> Int {
        try await db.read { db in
            try Episode.fetchCount(db)
        }
    }
}

// MARK: - Activity Log

extension PodcastRepository {
    func logActivity(_ log: ActivityLog) async throws {
        var log = log
        try await db.write { db in
            try log.insert(db)
        }
    }
    
    func getRecentActivity(limit: Int = 50) async throws -> [ActivityLog] {
        try await db.read { db in
            try ActivityLog
                .order(ActivityLog.Columns.timestamp.desc)
                .limit(limit)
                .fetchAll(db)
        }
    }
    
    func updateActivityStatus(id: Int64, status: ActivityStatus, errorMessage: String? = nil) async throws {
        try await db.write { db in
            try db.execute(
                sql: "UPDATE activity_log SET status = ?, errorMessage = ? WHERE id = ?",
                arguments: [status.rawValue, errorMessage, id]
            )
        }
    }
    
    func pruneOldActivity(olderThan days: Int = 90) async throws {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        try await db.write { db in
            try db.execute(
                sql: "DELETE FROM activity_log WHERE timestamp < ?",
                arguments: [cutoff]
            )
        }
    }
}

// MARK: - Notes

extension PodcastRepository {
    /// Get notes for an episode
    func getNote(forEpisode episodeId: String) async throws -> EpisodeNote? {
        try await db.read { db in
            try EpisodeNote.fetchOne(db, key: episodeId)
        }
    }
    
    /// Save notes for an episode
    func saveNote(episodeId: String, notes: String) async throws {
        var note = EpisodeNote(episodeId: episodeId, notes: notes)
        note.updatedAt = Date()
        
        try await db.write { db in
            // Use INSERT OR REPLACE for upsert
            try note.save(db)
        }
    }
    
    /// Delete notes for an episode
    func deleteNote(episodeId: String) async throws {
        _ = try await db.write { db in
            try EpisodeNote.deleteOne(db, key: episodeId)
        }
    }
    
    /// Search notes using FTS
    func searchNotes(query: String) async throws -> [Episode] {
        try await db.read { db in
            let pattern = FTS5Pattern(matchingAllPrefixesIn: query)
            let sql = """
                SELECT episodes.*
                FROM episodes
                JOIN episode_notes ON episodes.id = episode_notes.episodeId
                JOIN notes_fts ON episode_notes.rowid = notes_fts.rowid
                WHERE notes_fts MATCH ?
                ORDER BY bm25(notes_fts)
                LIMIT 100
                """
            return try Episode.fetchAll(db, sql: sql, arguments: [pattern?.rawPattern ?? query])
        }
    }
    
    /// Get all episodes with notes
    func getEpisodesWithNotes() async throws -> [Episode] {
        try await db.read { db in
            let sql = """
                SELECT episodes.*
                FROM episodes
                JOIN episode_notes ON episodes.id = episode_notes.episodeId
                WHERE episode_notes.notes != ''
                ORDER BY episode_notes.updatedAt DESC
                """
            return try Episode.fetchAll(db, sql: sql)
        }
    }
}

// MARK: - Tags

extension PodcastRepository {
    /// Get all tags
    func getAllTags() async throws -> [Tag] {
        try await db.read { db in
            try Tag.order(Column("name")).fetchAll(db)
        }
    }
    
    /// Get or create a tag by name
    func getOrCreateTag(name: String) async throws -> Tag {
        let normalizedName = name.lowercased().trimmingCharacters(in: .whitespaces)
        
        return try await db.write { db in
            // Check if exists
            if let existing = try Tag.filter(Column("name") == normalizedName).fetchOne(db) {
                return existing
            }
            
            // Create new
            var tag = Tag(name: normalizedName)
            try tag.insert(db)
            return tag
        }
    }
    
    /// Create a new tag
    func createTag(name: String, color: String? = nil) async throws -> Tag {
        var tag = Tag(name: name, color: color)
        try await db.write { db in
            try tag.insert(db)
        }
        return tag
    }
    
    /// Delete a tag (also removes from all episodes)
    func deleteTag(id: Int64) async throws {
        _ = try await db.write { db in
            try Tag.deleteOne(db, key: id)
        }
    }
    
    /// Get tags for an episode
    func getTags(forEpisode episodeId: String) async throws -> [Tag] {
        try await db.read { db in
            let sql = """
                SELECT tags.*
                FROM tags
                JOIN episode_tags ON tags.id = episode_tags.tagId
                WHERE episode_tags.episodeId = ?
                ORDER BY tags.name
                """
            return try Tag.fetchAll(db, sql: sql, arguments: [episodeId])
        }
    }
    
    /// Add a tag to an episode
    func addTag(tagId: Int64, toEpisode episodeId: String) async throws {
        let episodeTag = EpisodeTag(episodeId: episodeId, tagId: tagId)
        try await db.write { db in
            // Ignore if already exists (primary key constraint)
            try? episodeTag.insert(db)
        }
    }
    
    /// Add tag by name (creates if doesn't exist)
    func addTag(name: String, toEpisode episodeId: String) async throws {
        let tag = try await getOrCreateTag(name: name)
        if let tagId = tag.id {
            try await addTag(tagId: tagId, toEpisode: episodeId)
        }
    }
    
    /// Remove a tag from an episode
    func removeTag(tagId: Int64, fromEpisode episodeId: String) async throws {
        try await db.write { db in
            try db.execute(
                sql: "DELETE FROM episode_tags WHERE episodeId = ? AND tagId = ?",
                arguments: [episodeId, tagId]
            )
        }
    }
    
    /// Set tags for an episode (replaces existing)
    func setTags(tagNames: [String], forEpisode episodeId: String) async throws {
        try await db.write { db in
            // Remove existing tags
            try db.execute(
                sql: "DELETE FROM episode_tags WHERE episodeId = ?",
                arguments: [episodeId]
            )
            
            // Add new tags
            for name in tagNames {
                let normalizedName = name.lowercased().trimmingCharacters(in: .whitespaces)
                guard !normalizedName.isEmpty else { continue }
                
                // Get or create tag
                var tag: Tag
                if let existing = try Tag.filter(Column("name") == normalizedName).fetchOne(db) {
                    tag = existing
                } else {
                    tag = Tag(name: normalizedName)
                    try tag.insert(db)
                }
                
                // Add to episode
                if let tagId = tag.id {
                    let episodeTag = EpisodeTag(episodeId: episodeId, tagId: tagId)
                    try episodeTag.insert(db)
                }
            }
        }
    }
    
    /// Get episodes by tag
    func getEpisodes(withTag tagId: Int64) async throws -> [Episode] {
        try await db.read { db in
            let sql = """
                SELECT episodes.*
                FROM episodes
                JOIN episode_tags ON episodes.id = episode_tags.episodeId
                WHERE episode_tags.tagId = ?
                ORDER BY episodes.pubDate DESC
                """
            return try Episode.fetchAll(db, sql: sql, arguments: [tagId])
        }
    }
    
    /// Get episodes by tag name
    func getEpisodes(withTagName name: String) async throws -> [Episode] {
        try await db.read { db in
            let normalizedName = name.lowercased().trimmingCharacters(in: .whitespaces)
            let sql = """
                SELECT episodes.*
                FROM episodes
                JOIN episode_tags ON episodes.id = episode_tags.episodeId
                JOIN tags ON episode_tags.tagId = tags.id
                WHERE tags.name = ?
                ORDER BY episodes.pubDate DESC
                """
            return try Episode.fetchAll(db, sql: sql, arguments: [normalizedName])
        }
    }
    
    /// Get episode count per tag
    func getTagCounts() async throws -> [(Tag, Int)] {
        try await db.read { db in
            let sql = """
                SELECT tags.*, COUNT(episode_tags.episodeId) as count
                FROM tags
                LEFT JOIN episode_tags ON tags.id = episode_tags.tagId
                GROUP BY tags.id
                ORDER BY tags.name
                """
            let rows = try Row.fetchAll(db, sql: sql)
            return rows.compactMap { row -> (Tag, Int)? in
                guard let tag = try? Tag(row: row) else { return nil }
                let count = row["count"] as? Int ?? 0
                return (tag, count)
            }
        }
    }
}
