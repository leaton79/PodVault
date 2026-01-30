import Foundation

/// Service for importing and exporting OPML files
///
/// OPML (Outline Processor Markup Language) is the standard format
/// for exchanging podcast subscriptions between apps.
actor OPMLService {
    
    // MARK: - Types
    
    struct OPMLFeed {
        let title: String
        let feedURL: String
        let htmlURL: String?
    }
    
    struct OPMLDocument {
        let title: String
        let dateCreated: Date?
        let feeds: [OPMLFeed]
    }
    
    struct ImportResult {
        let totalFeeds: Int
        let successfulImports: Int
        let failedImports: Int
        let skippedDuplicates: Int
        let errors: [(feedURL: String, error: String)]
    }
    
    // MARK: - Import
    
    /// Parse an OPML file and return the feeds
    func parseOPML(from url: URL) throws -> OPMLDocument {
        let data = try Data(contentsOf: url)
        return try parseOPML(from: data)
    }
    
    /// Parse OPML data
    func parseOPML(from data: Data) throws -> OPMLDocument {
        let parser = OPMLParser()
        return try parser.parse(data: data)
    }
    
    /// Import feeds from an OPML file
    func importFeeds(
        from url: URL,
        feedService: FeedService,
        repository: PodcastRepository,
        progressHandler: @escaping (Int, Int) -> Void
    ) async throws -> ImportResult {
        let document = try parseOPML(from: url)
        
        var successCount = 0
        var failedCount = 0
        var skippedCount = 0
        var errors: [(String, String)] = []
        
        for (index, feed) in document.feeds.enumerated() {
            progressHandler(index + 1, document.feeds.count)
            
            // Check if already subscribed
            if let _ = try? await repository.getPodcast(feedURL: feed.feedURL) {
                skippedCount += 1
                continue
            }
            
            do {
                _ = try await feedService.subscribe(feedURL: feed.feedURL)
                successCount += 1
            } catch {
                failedCount += 1
                errors.append((feed.feedURL, error.localizedDescription))
            }
            
            // Small delay to avoid hammering servers
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        }
        
        return ImportResult(
            totalFeeds: document.feeds.count,
            successfulImports: successCount,
            failedImports: failedCount,
            skippedDuplicates: skippedCount,
            errors: errors
        )
    }
    
    // MARK: - Export
    
    /// Export podcasts to OPML format
    func exportOPML(podcasts: [Podcast], title: String = "PodVault Subscriptions") -> String {
        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from: Date())
        
        var opml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <opml version="2.0">
          <head>
            <title>\(escapeXML(title))</title>
            <dateCreated>\(dateString)</dateCreated>
            <ownerName>PodVault</ownerName>
          </head>
          <body>
            <outline text="feeds">
        
        """
        
        for podcast in podcasts {
            let title = escapeXML(podcast.title)
            let feedURL = escapeXML(podcast.feedURL)
            let htmlURL = podcast.link.map { escapeXML($0) } ?? ""
            
            opml += """
                  <outline type="rss" text="\(title)" title="\(title)" xmlUrl="\(feedURL)" htmlUrl="\(htmlURL)"/>
            
            """
        }
        
        opml += """
            </outline>
          </body>
        </opml>
        """
        
        return opml
    }
    
    /// Export podcasts to OPML file
    func exportOPML(podcasts: [Podcast], to url: URL, title: String = "PodVault Subscriptions") throws {
        let opmlString = exportOPML(podcasts: podcasts, title: title)
        try opmlString.write(to: url, atomically: true, encoding: .utf8)
    }
    
    // MARK: - Helpers
    
    private func escapeXML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
}

// MARK: - OPML Parser

private class OPMLParser: NSObject, XMLParserDelegate {
    private var title: String = ""
    private var dateCreated: Date?
    private var feeds: [OPMLService.OPMLFeed] = []
    private var currentElement: String = ""
    private var currentText: String = ""
    private var parseError: Error?
    
    func parse(data: Data) throws -> OPMLService.OPMLDocument {
        let parser = XMLParser(data: data)
        parser.delegate = self
        
        if parser.parse() {
            return OPMLService.OPMLDocument(
                title: title,
                dateCreated: dateCreated,
                feeds: feeds
            )
        } else if let error = parseError ?? parser.parserError {
            throw error
        } else {
            throw OPMLError.parseFailed
        }
    }
    
    // MARK: - XMLParserDelegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        currentText = ""
        
        if elementName == "outline" {
            // Check if this is an RSS feed outline
            let type = attributeDict["type"]?.lowercased()
            
            if let xmlUrl = attributeDict["xmlUrl"], !xmlUrl.isEmpty {
                // This is a feed
                let title = attributeDict["title"] ?? attributeDict["text"] ?? "Untitled"
                let htmlUrl = attributeDict["htmlUrl"]
                
                feeds.append(OPMLService.OPMLFeed(
                    title: title,
                    feedURL: xmlUrl,
                    htmlURL: htmlUrl
                ))
            } else if type == "rss" || type == "atom" {
                // Type indicates feed but no URL - might be in nested outline
                // We'll catch it if there's an xmlUrl
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let trimmedText = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch elementName {
        case "title":
            if title.isEmpty {
                title = trimmedText
            }
        case "dateCreated":
            let formatter = ISO8601DateFormatter()
            dateCreated = formatter.date(from: trimmedText)
        default:
            break
        }
        
        currentElement = ""
        currentText = ""
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.parseError = parseError
    }
}

// MARK: - Errors

enum OPMLError: LocalizedError {
    case parseFailed
    case noFeedsFound
    case exportFailed
    
    var errorDescription: String? {
        switch self {
        case .parseFailed:
            return "Failed to parse OPML file"
        case .noFeedsFound:
            return "No podcast feeds found in OPML file"
        case .exportFailed:
            return "Failed to export OPML file"
        }
    }
}
