import Foundation
import GRDB

/// Type of action logged
enum ActivityAction: String, Codable {
    case sync
    case download
    case save
    case delete
    case export
    case importOPML = "import_opml"
    case error
}

/// Status of the action
enum ActivityStatus: String, Codable {
    case started
    case success
    case failed
    case cancelled
}

/// Target type for the action
enum ActivityTargetType: String, Codable {
    case podcast
    case episode
    case library
}

/// Represents a logged activity/action
struct ActivityLog: Identifiable, Codable {
    var id: Int64?
    var timestamp: Date
    var action: ActivityAction
    var targetType: ActivityTargetType?
    var targetId: String?
    var targetName: String?  // Human-readable name for display
    var details: String?  // JSON blob for additional info
    var status: ActivityStatus
    var errorMessage: String?
    
    init(
        id: Int64? = nil,
        timestamp: Date = Date(),
        action: ActivityAction,
        targetType: ActivityTargetType? = nil,
        targetId: String? = nil,
        targetName: String? = nil,
        details: String? = nil,
        status: ActivityStatus = .started,
        errorMessage: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.action = action
        self.targetType = targetType
        self.targetId = targetId
        self.targetName = targetName
        self.details = details
        self.status = status
        self.errorMessage = errorMessage
    }
}

// MARK: - GRDB TableRecord & FetchableRecord
extension ActivityLog: TableRecord, FetchableRecord, PersistableRecord {
    static var databaseTableName: String { "activity_log" }
    
    enum Columns: String, ColumnExpression {
        case id, timestamp, action, targetType, targetId, targetName
        case details, status, errorMessage
    }
    
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

// MARK: - Computed Properties
extension ActivityLog {
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter.string(from: timestamp)
    }
    
    var displayMessage: String {
        let actionVerb: String
        switch action {
        case .sync: actionVerb = "Synced"
        case .download: actionVerb = "Downloaded"
        case .save: actionVerb = "Saved"
        case .delete: actionVerb = "Deleted"
        case .export: actionVerb = "Exported"
        case .importOPML: actionVerb = "Imported"
        case .error: actionVerb = "Error"
        }
        
        let target = targetName ?? targetId ?? "item"
        let statusEmoji: String
        switch status {
        case .started: statusEmoji = "⏳"
        case .success: statusEmoji = "✅"
        case .failed: statusEmoji = "❌"
        case .cancelled: statusEmoji = "⏹️"
        }
        
        return "\(statusEmoji) \(actionVerb) \(target)"
    }
}
