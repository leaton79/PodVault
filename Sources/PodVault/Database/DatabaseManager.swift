import Foundation
import GRDB

/// Manages the SQLite database connection and migrations
final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private var dbPool: DatabasePool?
    private let setupLock = NSLock()
    
    var database: DatabasePool {
        setupLock.lock()
        defer { setupLock.unlock() }
        
        if dbPool == nil {
            do {
                try setup()
            } catch {
                fatalError("Database initialization failed: \(error)")
            }
        }
        return dbPool!
    }
    
    private init() {}
    
    // MARK: - Setup
    
    func setup() throws {
        // Already initialized
        if dbPool != nil { return }
        
        let fileManager = FileManager.default
        let appSupportURL = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        let podvaultDir = appSupportURL.appendingPathComponent("PodVault", isDirectory: true)
        try fileManager.createDirectory(at: podvaultDir, withIntermediateDirectories: true)
        
        let dbPath = podvaultDir.appendingPathComponent("podvault.sqlite")
        
        dbPool = try Self.makeDatabasePool(path: dbPath.path)
        
        print("✅ Database initialized at: \(dbPath.path)")
    }
    
    // MARK: - Migrations
    
    private func migrate() throws {
        try Self.migrate(database)
    }

    private static func migrate(_ database: DatabasePool) throws {
        var migrator = DatabaseMigrator()
        
        // Always run migrations in order
        #if DEBUG
        migrator.eraseDatabaseOnSchemaChange = false
        #endif
        
        // Migration 1: Initial schema
        migrator.registerMigration("v1_initial") { db in
            // Podcasts table
            try db.create(table: "podcasts") { t in
                t.column("id", .text).primaryKey()
                t.column("feedURL", .text).notNull().unique()
                t.column("title", .text)
                t.column("author", .text)
                t.column("description", .text)
                t.column("artworkURL", .text)
                t.column("link", .text)
                t.column("lastSyncAt", .datetime)
                t.column("autoDownload", .boolean).notNull().defaults(to: true)
                t.column("createdAt", .datetime).notNull()
                t.column("updatedAt", .datetime).notNull()
            }
            
            // Episodes table
            try db.create(table: "episodes") { t in
                t.column("id", .text).primaryKey()
                t.column("podcastId", .text).notNull()
                    .references("podcasts", onDelete: .cascade)
                t.column("guid", .text).notNull()
                t.column("title", .text)
                t.column("episodeDescription", .text)
                t.column("pubDate", .datetime)
                t.column("duration", .integer)
                t.column("audioURL", .text)
                t.column("fileSize", .integer)
                t.column("downloadStatus", .text).notNull().defaults(to: "none")
                t.column("downloadPath", .text)
                t.column("playbackPosition", .integer).notNull().defaults(to: 0)
                t.column("isPlayed", .boolean).notNull().defaults(to: false)
                t.column("isSaved", .boolean).notNull().defaults(to: false)
                t.column("savedPath", .text)
                t.column("showNotes", .text)
                t.column("transcript", .text)
                t.column("transcriptURL", .text)
                t.column("createdAt", .datetime).notNull()
                t.column("updatedAt", .datetime).notNull()
                
                t.uniqueKey(["podcastId", "guid"])
            }
            
            // Indexes for episodes
            try db.create(index: "idx_episodes_podcast", on: "episodes", columns: ["podcastId"])
            try db.create(index: "idx_episodes_pubDate", on: "episodes", columns: ["pubDate"])
            try db.create(
                index: "idx_episodes_saved",
                on: "episodes",
                columns: ["isSaved"],
                condition: Column("isSaved") == true
            )
            
            // Activity log table
            try db.create(table: "activity_log") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("timestamp", .datetime).notNull()
                t.column("action", .text).notNull()
                t.column("targetType", .text)
                t.column("targetId", .text)
                t.column("targetName", .text)
                t.column("details", .text)
                t.column("status", .text).notNull()
                t.column("errorMessage", .text)
            }
            
            try db.create(index: "idx_activity_timestamp", on: "activity_log", columns: ["timestamp"])
            
            // Full-text search for episodes (standalone FTS5)
            try db.create(virtualTable: "episodes_fts", using: FTS5()) { t in
                t.column("id")
                t.column("title")
                t.column("episodeDescription")
                t.column("showNotes")
                t.column("transcript")
                t.tokenizer = .porter()  // Better English stemming
            }
        }
        
        // Migration 2: Notes and tags
        migrator.registerMigration("v2_notes_tags") { db in
            // Episode notes table
            try db.create(table: "episode_notes") { t in
                t.column("episodeId", .text).primaryKey()
                    .references("episodes", onDelete: .cascade)
                t.column("notes", .text).notNull().defaults(to: "")
                t.column("updatedAt", .datetime).notNull()
            }
            
            // Tags table (master list)
            try db.create(table: "tags") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull().unique()
                t.column("color", .text)  // Optional hex color
                t.column("createdAt", .datetime).notNull()
            }
            
            // Episode-tag junction table
            try db.create(table: "episode_tags") { t in
                t.column("episodeId", .text).notNull()
                    .references("episodes", onDelete: .cascade)
                t.column("tagId", .integer).notNull()
                    .references("tags", onDelete: .cascade)
                t.column("addedAt", .datetime).notNull()
                
                t.primaryKey(["episodeId", "tagId"])
            }
            
            try db.create(index: "idx_episode_tags_tag", on: "episode_tags", columns: ["tagId"])
            
            // FTS for notes (standalone FTS5)
            try db.create(virtualTable: "notes_fts", using: FTS5()) { t in
                t.column("episodeId")
                t.column("notes")
                t.tokenizer = .porter()
            }
        }
        
        migrator.registerMigration("v3_favorites") { db in
            try db.alter(table: "podcasts") { t in
                t.add(column: "isFavorite", .boolean).notNull().defaults(to: false)
            }
            
            try db.alter(table: "episodes") { t in
                t.add(column: "isFavorite", .boolean).notNull().defaults(to: false)
            }
            
            try db.create(
                index: "idx_podcasts_favorite",
                on: "podcasts",
                columns: ["isFavorite"],
                condition: Column("isFavorite") == true
            )
            
            try db.create(
                index: "idx_episodes_favorite",
                on: "episodes",
                columns: ["isFavorite"],
                condition: Column("isFavorite") == true
            )
        }

        migrator.registerMigration("v4_fts_sync") { db in
            try db.execute(sql: """
                INSERT INTO episodes_fts(rowid, id, title, episodeDescription, showNotes, transcript)
                SELECT rowid, id, COALESCE(title, ''), COALESCE(episodeDescription, ''), COALESCE(showNotes, ''), COALESCE(transcript, '')
                FROM episodes
                """)

            try db.execute(sql: """
                CREATE TRIGGER episodes_ai AFTER INSERT ON episodes BEGIN
                    INSERT INTO episodes_fts(rowid, id, title, episodeDescription, showNotes, transcript)
                    VALUES (new.rowid, new.id, COALESCE(new.title, ''), COALESCE(new.episodeDescription, ''), COALESCE(new.showNotes, ''), COALESCE(new.transcript, ''));
                END
                """)

            try db.execute(sql: """
                CREATE TRIGGER episodes_au AFTER UPDATE ON episodes BEGIN
                    DELETE FROM episodes_fts WHERE rowid = old.rowid;
                    INSERT INTO episodes_fts(rowid, id, title, episodeDescription, showNotes, transcript)
                    VALUES (new.rowid, new.id, COALESCE(new.title, ''), COALESCE(new.episodeDescription, ''), COALESCE(new.showNotes, ''), COALESCE(new.transcript, ''));
                END
                """)

            try db.execute(sql: """
                CREATE TRIGGER episodes_ad AFTER DELETE ON episodes BEGIN
                    DELETE FROM episodes_fts WHERE rowid = old.rowid;
                END
                """)

            try db.execute(sql: """
                INSERT INTO notes_fts(rowid, episodeId, notes)
                SELECT rowid, episodeId, COALESCE(notes, '')
                FROM episode_notes
                """)

            try db.execute(sql: """
                CREATE TRIGGER episode_notes_ai AFTER INSERT ON episode_notes BEGIN
                    INSERT INTO notes_fts(rowid, episodeId, notes)
                    VALUES (new.rowid, new.episodeId, COALESCE(new.notes, ''));
                END
                """)

            try db.execute(sql: """
                CREATE TRIGGER episode_notes_au AFTER UPDATE ON episode_notes BEGIN
                    DELETE FROM notes_fts WHERE rowid = old.rowid;
                    INSERT INTO notes_fts(rowid, episodeId, notes)
                    VALUES (new.rowid, new.episodeId, COALESCE(new.notes, ''));
                END
                """)

            try db.execute(sql: """
                CREATE TRIGGER episode_notes_ad AFTER DELETE ON episode_notes BEGIN
                    DELETE FROM notes_fts WHERE rowid = old.rowid;
                END
                """)
        }
        
        try migrator.migrate(database)
    }

    static func makeTestDatabase(path: String) throws -> DatabasePool {
        let database = try makeDatabasePool(path: path)
        try migrate(database)
        return database
    }

    private static func makeDatabasePool(path: String) throws -> DatabasePool {
        var config = Configuration()
        config.prepareDatabase { db in
            try db.execute(sql: "PRAGMA journal_mode = WAL")
            try db.execute(sql: "PRAGMA foreign_keys = ON")
        }
        return try DatabasePool(path: path, configuration: config)
    }
    
    // MARK: - Directory Helpers
    
    static var appSupportDirectory: URL {
        let fileManager = FileManager.default
        let appSupport = try! fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return appSupport.appendingPathComponent("PodVault", isDirectory: true)
    }
    
    static var downloadsDirectory: URL {
        let dir = appSupportDirectory.appendingPathComponent("downloads", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
    
    static var artworkDirectory: URL {
        let dir = appSupportDirectory.appendingPathComponent("artwork", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
    
    static var savedLibraryDirectory: URL {
        // Default location in user's home directory
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let dir = homeDir.appendingPathComponent("PodVault Saved", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
}
