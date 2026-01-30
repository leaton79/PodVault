import Foundation

struct FeedResult {
    let podcast: Podcast
    let episodes: [Episode]
}

class FeedService {
    private let repository = PodcastRepository()
    
    func fetchFeed(url: String) async throws -> FeedResult {
        guard let feedURL = URL(string: url) else {
            throw FeedError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: feedURL)
        
        // Check if we got HTML instead of XML (user pasted a webpage URL)
        if let htmlString = String(data: data, encoding: .utf8),
           (htmlString.contains("<!DOCTYPE html") || htmlString.contains("<html") || htmlString.contains("<!doctype html")) {
            // Try to find RSS feed URL in the HTML
            if let rssURL = extractRSSURL(from: htmlString, baseURL: feedURL) {
                // Recursively fetch the actual RSS feed
                return try await fetchFeed(url: rssURL)
            } else {
                throw FeedError.notAFeed(message: "Could not find RSS feed. Try finding the RSS/Subscribe link on the podcast page and paste that URL instead.")
            }
        }
        
        // Parse as XML feed
        let parser = FeedParser(data: data, feedURL: url)
        return try parser.parse()
    }
    
    /// Subscribe to a new podcast by URL
    func subscribe(feedURL: String) async throws -> Podcast {
        let result = try await fetchFeed(url: feedURL)
        try await repository.savePodcast(result.podcast)
        try await repository.saveEpisodes(result.episodes)
        return result.podcast
    }
    
    /// Sync a podcast and return the number of new episodes
    func syncPodcast(_ podcast: Podcast) async throws -> Int {
        let result = try await fetchFeed(url: podcast.feedURL)
        
        // Get existing episode IDs
        let existingEpisodes = try await repository.getEpisodes(forPodcast: podcast.id)
        let existingIds = Set(existingEpisodes.map { $0.id })
        
        // Find new episodes
        let newEpisodes = result.episodes.filter { !existingIds.contains($0.id) }
        
        // Save new episodes
        if !newEpisodes.isEmpty {
            try await repository.saveEpisodes(newEpisodes)
        }
        
        // Update podcast metadata
        var updatedPodcast = result.podcast
        updatedPodcast.id = podcast.id
        updatedPodcast.lastSyncAt = Date()
        try await repository.savePodcast(updatedPodcast)
        
        return newEpisodes.count
    }
    
    private func extractRSSURL(from html: String, baseURL: URL) -> String? {
        // Method 1: Standard RSS link tags
        let linkPatterns = [
            #"<link[^>]+type=[\"']application/rss\+xml[\"'][^>]+href=[\"']([^\"']+)[\"']"#,
            #"<link[^>]+href=[\"']([^\"']+)[\"'][^>]+type=[\"']application/rss\+xml[\"']"#,
            #"<link[^>]*rel=[\"']alternate[\"'][^>]*type=[\"']application/rss\+xml[\"'][^>]*href=[\"']([^\"']+)[\"']"#
        ]
        
        for pattern in linkPatterns {
            if let url = findURL(pattern: pattern, in: html, baseURL: baseURL) {
                return url
            }
        }
        
        // Method 2: Podbean specific patterns
        let podbeanPatterns = [
            #"https://feed\.podbean\.com/[a-zA-Z0-9_-]+/feed\.xml"#,
            #"https://feed\.podbean\.com/[^\"'\s<>]+"#,
            #"feedUrl[\"']\s*:\s*[\"']([^\"']+)[\"']"#,
            #"data-feed-url=[\"']([^\"']+)[\"']"#,
            #"rssFeedUrl[\"']\s*:\s*[\"']([^\"']+)[\"']"#
        ]
        
        for pattern in podbeanPatterns {
            if let url = findURL(pattern: pattern, in: html, baseURL: baseURL) {
                return url
            }
        }
        
        // Method 3: Spotify/Anchor pattern
        if let url = findURL(pattern: #"https://anchor\.fm/s/[a-zA-Z0-9]+/podcast/rss"#, in: html, baseURL: baseURL) {
            return url
        }
        
        // Method 4: Buzzsprout pattern
        if let url = findURL(pattern: #"https://feeds\.buzzsprout\.com/[0-9]+\.rss"#, in: html, baseURL: baseURL) {
            return url
        }
        
        // Method 5: Libsyn pattern
        if let url = findURL(pattern: #"https://[a-zA-Z0-9_-]+\.libsyn\.com/rss"#, in: html, baseURL: baseURL) {
            return url
        }
        
        // Method 6: Megaphone pattern
        if let url = findURL(pattern: #"https://feeds\.megaphone\.fm/[a-zA-Z0-9_-]+"#, in: html, baseURL: baseURL) {
            return url
        }
        
        // Method 7: Simplecast pattern
        if let url = findURL(pattern: #"https://feeds\.simplecast\.com/[a-zA-Z0-9_-]+"#, in: html, baseURL: baseURL) {
            return url
        }
        
        // Method 8: Generic RSS/feed URL in page
        let genericPatterns = [
            #"[\"']([^\"']*\.xml)[\"']"#,
            #"[\"']([^\"']*/rss/?)[\"']"#,
            #"[\"']([^\"']*/feed/?)[\"']"#,
            #"href=[\"']([^\"']+/rss[^\"']*)[\"']"#,
            #"href=[\"']([^\"']+feed[^\"']*\.xml)[\"']"#
        ]
        
        for pattern in genericPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
               let range = Range(match.range(at: 1), in: html) {
                let foundURL = String(html[range])
                if foundURL.contains("feed") || foundURL.contains("rss") {
                    if foundURL.hasPrefix("http") {
                        return foundURL
                    } else if foundURL.hasPrefix("/") {
                        return "\(baseURL.scheme ?? "https")://\(baseURL.host ?? "")\(foundURL)"
                    }
                }
            }
        }
        
        return nil
    }
    
    private func findURL(pattern: String, in html: String, baseURL: URL) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }
        
        if let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)) {
            // Try to get capture group 1 first, then fall back to entire match
            let captureRange = match.numberOfRanges > 1 ? match.range(at: 1) : match.range
            if let range = Range(captureRange, in: html) {
                let foundURL = String(html[range])
                if foundURL.hasPrefix("http") {
                    return foundURL
                } else if foundURL.hasPrefix("/") {
                    return "\(baseURL.scheme ?? "https")://\(baseURL.host ?? "")\(foundURL)"
                }
            }
        }
        return nil
    }
}

enum FeedError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case parseError(String)
    case notAFeed(message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .parseError(let message):
            return "Failed to parse feed: \(message)"
        case .notAFeed(let message):
            return message
        }
    }
}

class FeedParser: NSObject, XMLParserDelegate {
    private let data: Data
    private let feedURL: String
    private var episodes: [Episode] = []
    
    private var currentElement = ""
    private var currentText = ""
    private var currentEpisode: EpisodeBuilder?
    private var isInItem = false
    private var isInChannel = false
    private var isInImage = false
    
    // Podcast metadata
    private var podcastTitle = ""
    private var podcastDescription = ""
    private var podcastAuthor = ""
    private var podcastArtworkURL: String?
    
    init(data: Data, feedURL: String) {
        self.data = data
        self.feedURL = feedURL
    }
    
    func parse() throws -> FeedResult {
        let parser = XMLParser(data: data)
        parser.delegate = self
        
        if parser.parse() {
            let podcastId = feedURL.data(using: .utf8)?.base64EncodedString() ?? UUID().uuidString
            let podcast = Podcast(
                id: podcastId,
                feedURL: feedURL,
                title: podcastTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                author: podcastAuthor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : podcastAuthor.trimmingCharacters(in: .whitespacesAndNewlines),
                description: podcastDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : podcastDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                artworkURL: podcastArtworkURL
            )
            return FeedResult(podcast: podcast, episodes: episodes)
        } else if let error = parser.parserError {
            throw FeedError.parseError("Internal unresolved error: \(error.localizedDescription)")
        } else {
            throw FeedError.parseError("Unknown parsing error")
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        currentText = ""
        
        if elementName == "channel" {
            isInChannel = true
        } else if elementName == "item" {
            isInItem = true
            currentEpisode = EpisodeBuilder()
        } else if elementName == "image" && isInChannel && !isInItem {
            isInImage = true
        } else if elementName == "itunes:image" {
            if let href = attributeDict["href"] {
                if isInItem {
                    currentEpisode?.artworkURL = href
                } else if isInChannel {
                    podcastArtworkURL = href
                }
            }
        } else if elementName == "enclosure" {
            currentEpisode?.audioURL = attributeDict["url"]
            if let lengthStr = attributeDict["length"], let length = Int(lengthStr) {
                currentEpisode?.fileSize = length
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let trimmedText = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if elementName == "item" {
            if let builder = currentEpisode {
                let podcastId = feedURL.data(using: .utf8)?.base64EncodedString() ?? ""
                let episode = builder.build(podcastId: podcastId)
                episodes.append(episode)
            }
            currentEpisode = nil
            isInItem = false
        } else if elementName == "channel" {
            isInChannel = false
        } else if elementName == "image" {
            isInImage = false
        } else if isInItem {
            switch elementName {
            case "title":
                currentEpisode?.title = trimmedText
            case "description", "content:encoded":
                if currentEpisode?.episodeDescription == nil || trimmedText.count > (currentEpisode?.episodeDescription?.count ?? 0) {
                    currentEpisode?.episodeDescription = trimmedText
                }
            case "itunes:summary":
                if currentEpisode?.episodeDescription == nil {
                    currentEpisode?.episodeDescription = trimmedText
                }
            case "pubDate":
                currentEpisode?.pubDate = parseDate(trimmedText)
            case "itunes:duration":
                currentEpisode?.duration = parseDuration(trimmedText)
            case "guid":
                currentEpisode?.guid = trimmedText
            default:
                break
            }
        } else if isInChannel && !isInItem {
            switch elementName {
            case "title":
                if !isInImage {
                    podcastTitle = trimmedText
                }
            case "description", "itunes:summary":
                if podcastDescription.isEmpty {
                    podcastDescription = trimmedText
                }
            case "itunes:author", "author":
                if podcastAuthor.isEmpty {
                    podcastAuthor = trimmedText
                }
            case "url":
                if isInImage && podcastArtworkURL == nil {
                    podcastArtworkURL = trimmedText
                }
            default:
                break
            }
        }
    }
    
    private func parseDate(_ string: String) -> Date? {
        let formatters = [
            "EEE, dd MMM yyyy HH:mm:ss Z",
            "EEE, dd MMM yyyy HH:mm:ss zzz",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd"
        ]
        
        for format in formatters {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = format
            if let date = formatter.date(from: string) {
                return date
            }
        }
        return nil
    }
    
    private func parseDuration(_ string: String) -> Int? {
        let components = string.split(separator: ":")
        if components.count == 3 {
            let hours = Int(components[0]) ?? 0
            let minutes = Int(components[1]) ?? 0
            let seconds = Int(components[2]) ?? 0
            return hours * 3600 + minutes * 60 + seconds
        } else if components.count == 2 {
            let minutes = Int(components[0]) ?? 0
            let seconds = Int(components[1]) ?? 0
            return minutes * 60 + seconds
        } else if let seconds = Int(string) {
            return seconds
        }
        return nil
    }
}

private class EpisodeBuilder {
    var title: String?
    var episodeDescription: String?
    var audioURL: String?
    var fileSize: Int?
    var pubDate: Date?
    var duration: Int?
    var guid: String?
    var artworkURL: String?
    
    func build(podcastId: String) -> Episode {
        let episodeGuid = guid ?? audioURL ?? UUID().uuidString
        let episodeId = episodeGuid.data(using: .utf8)?.base64EncodedString() ?? UUID().uuidString
        
        return Episode(
            id: episodeId,
            podcastId: podcastId,
            guid: episodeGuid,
            title: title ?? "Untitled Episode",
            episodeDescription: episodeDescription,
            pubDate: pubDate,
            duration: duration,
            audioURL: audioURL,
            fileSize: fileSize
        )
    }
}
