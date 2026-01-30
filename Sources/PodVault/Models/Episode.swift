import Foundation
import GRDB

/// Download state for an episode
enum DownloadStatus: String, Codable {
    case none
    case queued
    case downloading
    case downloaded
    case failed
}

/// Represents a single podcast episode
struct Episode: Identifiable, Codable, Equatable {
    var id: String
    var podcastId: String
    var guid: String
    var title: String
    var episodeDescription: String?
    var pubDate: Date?
    var duration: Int?  // seconds
    var audioURL: String?
    var fileSize: Int?
    
    // Local state
    var downloadStatus: DownloadStatus
    var downloadPath: String?
    var downloadProgress: Double  // 0.0 to 1.0, not persisted
    var playbackPosition: Int  // seconds
    var isPlayed: Bool
    
    // Saved MP3 state
    var isSaved: Bool
    var savedPath: String?
    
    // Content
    var showNotes: String?
    var transcript: String?
    var transcriptURL: String?
    
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        podcastId: String,
        guid: String,
        title: String = "",
        episodeDescription: String? = nil,
        pubDate: Date? = nil,
        duration: Int? = nil,
        audioURL: String? = nil,
        fileSize: Int? = nil,
        downloadStatus: DownloadStatus = .none,
        downloadPath: String? = nil,
        downloadProgress: Double = 0,
        playbackPosition: Int = 0,
        isPlayed: Bool = false,
        isSaved: Bool = false,
        savedPath: String? = nil,
        showNotes: String? = nil,
        transcript: String? = nil,
        transcriptURL: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.podcastId = podcastId
        self.guid = guid
        self.title = title
        self.episodeDescription = episodeDescription
        self.pubDate = pubDate
        self.duration = duration
        self.audioURL = audioURL
        self.fileSize = fileSize
        self.downloadStatus = downloadStatus
        self.downloadPath = downloadPath
        self.downloadProgress = downloadProgress
        self.playbackPosition = playbackPosition
        self.isPlayed = isPlayed
        self.isSaved = isSaved
        self.savedPath = savedPath
        self.showNotes = showNotes
        self.transcript = transcript
        self.transcriptURL = transcriptURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - GRDB TableRecord & FetchableRecord
extension Episode: TableRecord, FetchableRecord, PersistableRecord {
    static var databaseTableName: String { "episodes" }
    
    // Exclude downloadProgress from persistence
    static var persistenceConflictPolicy: PersistenceConflictPolicy {
        PersistenceConflictPolicy(insert: .replace, update: .replace)
    }
    
    enum Columns: String, ColumnExpression {
        case id, podcastId, guid, title, episodeDescription, pubDate
        case duration, audioURL, fileSize, downloadStatus, downloadPath
        case playbackPosition, isPlayed, isSaved, savedPath
        case showNotes, transcript, transcriptURL, createdAt, updatedAt
    }
    
    // Custom encoding to exclude transient properties
    func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["podcastId"] = podcastId
        container["guid"] = guid
        container["title"] = title
        container["episodeDescription"] = episodeDescription
        container["pubDate"] = pubDate
        container["duration"] = duration
        container["audioURL"] = audioURL
        container["fileSize"] = fileSize
        container["downloadStatus"] = downloadStatus.rawValue
        container["downloadPath"] = downloadPath
        container["playbackPosition"] = playbackPosition
        container["isPlayed"] = isPlayed
        container["isSaved"] = isSaved
        container["savedPath"] = savedPath
        container["showNotes"] = showNotes
        container["transcript"] = transcript
        container["transcriptURL"] = transcriptURL
        container["createdAt"] = createdAt
        container["updatedAt"] = updatedAt
    }
    
    init(row: Row) throws {
        id = row["id"]
        podcastId = row["podcastId"]
        guid = row["guid"]
        title = row["title"]
        episodeDescription = row["episodeDescription"]
        pubDate = row["pubDate"]
        duration = row["duration"]
        audioURL = row["audioURL"]
        fileSize = row["fileSize"]
        downloadStatus = DownloadStatus(rawValue: row["downloadStatus"] ?? "none") ?? .none
        downloadPath = row["downloadPath"]
        downloadProgress = 0  // Transient, not stored
        playbackPosition = row["playbackPosition"] ?? 0
        isPlayed = row["isPlayed"] ?? false
        isSaved = row["isSaved"] ?? false
        savedPath = row["savedPath"]
        showNotes = row["showNotes"]
        transcript = row["transcript"]
        transcriptURL = row["transcriptURL"]
        createdAt = row["createdAt"] ?? Date()
        updatedAt = row["updatedAt"] ?? Date()
    }
}

// MARK: - Computed Properties
extension Episode {
    var displayTitle: String {
        title.isEmpty ? "Untitled Episode" : title
    }
    
    var formattedDuration: String {
        guard let duration = duration else { return "--:--" }
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let seconds = duration % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    var formattedPubDate: String {
        guard let pubDate = pubDate else { return "Unknown date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: pubDate)
    }
    
    var isDownloaded: Bool {
        downloadStatus == .downloaded && downloadPath != nil
    }
    
    var progressPercent: Int {
        guard let duration = duration, duration > 0 else { return 0 }
        return Int((Double(playbackPosition) / Double(duration)) * 100)
    }
}
