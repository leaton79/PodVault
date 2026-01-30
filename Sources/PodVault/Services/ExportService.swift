import Foundation

/// Service for exporting library data to JSON and Markdown formats
actor ExportService {
    
    // MARK: - Types
    
    struct ExportOptions {
        var includeEpisodes: Bool = true
        var includeNotes: Bool = true
        var includeTags: Bool = true
        var includePlaybackProgress: Bool = true
        var includeDownloadStatus: Bool = true
        var onlyFavorites: Bool = false  // Only saved episodes
        var format: ExportFormat = .json
        
        enum ExportFormat {
            case json
            case markdown
        }
    }
    
    struct LibraryExport: Codable {
        let exportDate: Date
        let appVersion: String
        let podcasts: [PodcastExport]
        let tags: [String]
        let statistics: Statistics
        
        struct Statistics: Codable {
            let totalPodcasts: Int
            let totalEpisodes: Int
            let savedEpisodes: Int
            let playedEpisodes: Int
            let totalPlaytimeSeconds: Int
        }
    }
    
    struct PodcastExport: Codable {
        let title: String
        let author: String?
        let feedURL: String
        let description: String?
        let artworkURL: String?
        let websiteURL: String?
        let episodeCount: Int
        let episodes: [EpisodeExport]?
    }
    
    struct EpisodeExport: Codable {
        let title: String
        let guid: String
        let pubDate: Date?
        let durationSeconds: Int?
        let audioURL: String?
        let isPlayed: Bool
        let isSaved: Bool
        let playbackPositionSeconds: Int
        let notes: String?
        let tags: [String]
    }
    
    // MARK: - Dependencies
    
    private let repository: PodcastRepository
    
    init(repository: PodcastRepository = PodcastRepository()) {
        self.repository = repository
    }
    
    // MARK: - Export to JSON
    
    /// Export library to JSON format
    func exportToJSON(options: ExportOptions = ExportOptions()) async throws -> Data {
        let export = try await buildLibraryExport(options: options)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        return try encoder.encode(export)
    }
    
    /// Export library to JSON file
    func exportToJSON(to url: URL, options: ExportOptions = ExportOptions()) async throws {
        let data = try await exportToJSON(options: options)
        try data.write(to: url)
    }
    
    // MARK: - Export to Markdown
    
    /// Export library to Markdown format
    func exportToMarkdown(options: ExportOptions = ExportOptions()) async throws -> String {
        let export = try await buildLibraryExport(options: options)
        return generateMarkdown(from: export, options: options)
    }
    
    /// Export library to Markdown file
    func exportToMarkdown(to url: URL, options: ExportOptions = ExportOptions()) async throws {
        let markdown = try await exportToMarkdown(options: options)
        try markdown.write(to: url, atomically: true, encoding: .utf8)
    }
    
    // MARK: - Private Methods
    
    private func buildLibraryExport(options: ExportOptions) async throws -> LibraryExport {
        let podcasts = try await repository.getAllPodcasts()
        let allTags = try await repository.getAllTags()
        
        var podcastExports: [PodcastExport] = []
        var totalEpisodes = 0
        var savedEpisodes = 0
        var playedEpisodes = 0
        var totalPlaytime = 0
        
        for podcast in podcasts {
            let episodes = try await repository.getEpisodes(forPodcast: podcast.id)
            
            var episodeExports: [EpisodeExport]? = nil
            
            if options.includeEpisodes {
                var exports: [EpisodeExport] = []
                
                for episode in episodes {
                    // Skip non-saved if onlyFavorites
                    if options.onlyFavorites && !episode.isSaved {
                        continue
                    }
                    
                    // Get notes if requested
                    var notes: String? = nil
                    if options.includeNotes {
                        notes = try await repository.getNote(forEpisode: episode.id)?.notes
                        if notes?.isEmpty == true { notes = nil }
                    }
                    
                    // Get tags if requested
                    var tags: [String] = []
                    if options.includeTags {
                        tags = try await repository.getTags(forEpisode: episode.id).map { $0.name }
                    }
                    
                    let episodeExport = EpisodeExport(
                        title: episode.title,
                        guid: episode.guid,
                        pubDate: episode.pubDate,
                        durationSeconds: episode.duration,
                        audioURL: episode.audioURL,
                        isPlayed: episode.isPlayed,
                        isSaved: episode.isSaved,
                        playbackPositionSeconds: options.includePlaybackProgress ? episode.playbackPosition : 0,
                        notes: notes,
                        tags: tags
                    )
                    
                    exports.append(episodeExport)
                    
                    // Statistics
                    if episode.isSaved { savedEpisodes += 1 }
                    if episode.isPlayed { playedEpisodes += 1 }
                    totalPlaytime += episode.duration ?? 0
                }
                
                episodeExports = exports
                totalEpisodes += exports.count
            } else {
                totalEpisodes += episodes.count
                savedEpisodes += episodes.filter { $0.isSaved }.count
                playedEpisodes += episodes.filter { $0.isPlayed }.count
                totalPlaytime += episodes.compactMap { $0.duration }.reduce(0, +)
            }
            
            let podcastExport = PodcastExport(
                title: podcast.title ?? "Untitled",
                author: podcast.author,
                feedURL: podcast.feedURL,
                description: podcast.description,
                artworkURL: podcast.artworkURL,
                websiteURL: podcast.link,
                episodeCount: episodes.count,
                episodes: episodeExports
            )
            
            podcastExports.append(podcastExport)
        }
        
        return LibraryExport(
            exportDate: Date(),
            appVersion: "1.0.0",
            podcasts: podcastExports,
            tags: allTags.map { $0.name },
            statistics: LibraryExport.Statistics(
                totalPodcasts: podcasts.count,
                totalEpisodes: totalEpisodes,
                savedEpisodes: savedEpisodes,
                playedEpisodes: playedEpisodes,
                totalPlaytimeSeconds: totalPlaytime
            )
        )
    }
    
    private func generateMarkdown(from export: LibraryExport, options: ExportOptions) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        
        let episodeDateFormatter = DateFormatter()
        episodeDateFormatter.dateStyle = .medium
        episodeDateFormatter.timeStyle = .none
        
        var md = """
        # PodVault Library Export
        
        **Exported:** \(dateFormatter.string(from: export.exportDate))
        **App Version:** \(export.appVersion)
        
        ## Statistics
        
        | Metric | Value |
        |--------|-------|
        | Total Podcasts | \(export.statistics.totalPodcasts) |
        | Total Episodes | \(export.statistics.totalEpisodes) |
        | Saved Episodes | \(export.statistics.savedEpisodes) |
        | Played Episodes | \(export.statistics.playedEpisodes) |
        | Total Playtime | \(formatDuration(export.statistics.totalPlaytimeSeconds)) |
        
        """
        
        if !export.tags.isEmpty {
            md += """
            
            ## Tags
            
            \(export.tags.map { "- \($0)" }.joined(separator: "\n"))
            
            """
        }
        
        md += """
        
        ## Podcasts
        
        """
        
        for (index, podcast) in export.podcasts.enumerated() {
            md += """
            
            ### \(index + 1). \(podcast.title)
            
            """
            
            if let author = podcast.author {
                md += "**Author:** \(author)\n"
            }
            
            md += "**Feed URL:** \(podcast.feedURL)\n"
            
            if let website = podcast.websiteURL {
                md += "**Website:** \(website)\n"
            }
            
            md += "**Episodes:** \(podcast.episodeCount)\n"
            
            if let description = podcast.description, !description.isEmpty {
                let cleanDescription = description
                    .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if !cleanDescription.isEmpty {
                    let truncated = cleanDescription.count > 300 
                        ? String(cleanDescription.prefix(300)) + "..." 
                        : cleanDescription
                    md += "\n> \(truncated)\n"
                }
            }
            
            if let episodes = podcast.episodes, !episodes.isEmpty {
                md += "\n#### Episodes\n\n"
                
                for episode in episodes {
                    let status = episode.isPlayed ? "✅" : (episode.isSaved ? "💾" : "○")
                    let dateStr = episode.pubDate.map { episodeDateFormatter.string(from: $0) } ?? ""
                    let durationStr = episode.durationSeconds.map { formatDuration($0) } ?? ""
                    
                    md += "- \(status) **\(episode.title)**"
                    if !dateStr.isEmpty {
                        md += " (\(dateStr))"
                    }
                    if !durationStr.isEmpty {
                        md += " - \(durationStr)"
                    }
                    md += "\n"
                    
                    if !episode.tags.isEmpty {
                        md += "  - Tags: \(episode.tags.joined(separator: ", "))\n"
                    }
                    
                    if let notes = episode.notes, !notes.isEmpty {
                        let truncatedNotes = notes.count > 200 
                            ? String(notes.prefix(200)) + "..." 
                            : notes
                        md += "  - Notes: \(truncatedNotes.replacingOccurrences(of: "\n", with: " "))\n"
                    }
                }
            }
        }
        
        md += """
        
        ---
        
        *Exported from PodVault*
        """
        
        return md
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
