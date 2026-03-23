import SwiftUI
import AppKit

// MARK: - Theme System

enum AppTheme: String, CaseIterable, Codable {
    case system = "System"
    case ocean = "Ocean Blue"
    case forest = "Forest Green"
    case sunset = "Sunset Orange"
    case purple = "Purple Night"
    case rose = "Rose Pink"
    case midnight = "Midnight"
    case monokai = "Monokai"
    
    var accentColor: Color {
        switch self {
        case .system: return .blue
        case .ocean: return Color(red: 0.3, green: 0.7, blue: 1.0)
        case .forest: return Color(red: 0.4, green: 0.8, blue: 0.5)
        case .sunset: return Color(red: 1.0, green: 0.6, blue: 0.3)
        case .purple: return Color(red: 0.7, green: 0.5, blue: 1.0)
        case .rose: return Color(red: 1.0, green: 0.5, blue: 0.6)
        case .midnight: return Color(red: 0.5, green: 0.6, blue: 0.9)
        case .monokai: return Color(red: 0.7, green: 0.9, blue: 0.3)
        }
    }
    
    var buttonBg: Color {
        switch self {
        case .system: return .blue
        case .ocean: return Color(red: 0.2, green: 0.5, blue: 0.8)
        case .forest: return Color(red: 0.2, green: 0.55, blue: 0.35)
        case .sunset: return Color(red: 0.85, green: 0.45, blue: 0.2)
        case .purple: return Color(red: 0.5, green: 0.35, blue: 0.75)
        case .rose: return Color(red: 0.8, green: 0.35, blue: 0.45)
        case .midnight: return Color(red: 0.35, green: 0.45, blue: 0.7)
        case .monokai: return Color(red: 0.5, green: 0.7, blue: 0.2)
        }
    }
    
    var buttonText: Color { .white }
    
    func sidebarBg(for colorScheme: ColorScheme) -> Color {
        if self == .system {
            return colorScheme == .dark ? Color(white: 0.15) : Color(NSColor.controlBackgroundColor)
        }
        return sidebarBgFixed
    }
    
    var sidebarBgFixed: Color {
        switch self {
        case .system: return Color(NSColor.controlBackgroundColor)
        case .ocean: return Color(red: 0.06, green: 0.12, blue: 0.2)
        case .forest: return Color(red: 0.06, green: 0.14, blue: 0.1)
        case .sunset: return Color(red: 0.18, green: 0.1, blue: 0.06)
        case .purple: return Color(red: 0.12, green: 0.08, blue: 0.18)
        case .rose: return Color(red: 0.18, green: 0.08, blue: 0.12)
        case .midnight: return Color(red: 0.08, green: 0.1, blue: 0.16)
        case .monokai: return Color(red: 0.15, green: 0.15, blue: 0.12)
        }
    }
    
    func mainBg(for colorScheme: ColorScheme) -> Color {
        if self == .system {
            return colorScheme == .dark ? Color(white: 0.18) : Color(NSColor.windowBackgroundColor)
        }
        return mainBgFixed
    }
    
    var mainBgFixed: Color {
        switch self {
        case .system: return Color(NSColor.windowBackgroundColor)
        case .ocean: return Color(red: 0.08, green: 0.16, blue: 0.26)
        case .forest: return Color(red: 0.08, green: 0.18, blue: 0.14)
        case .sunset: return Color(red: 0.22, green: 0.14, blue: 0.1)
        case .purple: return Color(red: 0.16, green: 0.12, blue: 0.24)
        case .rose: return Color(red: 0.22, green: 0.12, blue: 0.16)
        case .midnight: return Color(red: 0.1, green: 0.12, blue: 0.2)
        case .monokai: return Color(red: 0.18, green: 0.18, blue: 0.15)
        }
    }
    
    func detailBg(for colorScheme: ColorScheme) -> Color {
        if self == .system {
            return colorScheme == .dark ? Color(white: 0.2) : Color(NSColor.textBackgroundColor)
        }
        return detailBgFixed
    }
    
    var detailBgFixed: Color {
        switch self {
        case .system: return Color(NSColor.textBackgroundColor)
        case .ocean: return Color(red: 0.1, green: 0.2, blue: 0.32)
        case .forest: return Color(red: 0.1, green: 0.22, blue: 0.18)
        case .sunset: return Color(red: 0.26, green: 0.18, blue: 0.14)
        case .purple: return Color(red: 0.2, green: 0.16, blue: 0.3)
        case .rose: return Color(red: 0.26, green: 0.16, blue: 0.2)
        case .midnight: return Color(red: 0.12, green: 0.14, blue: 0.24)
        case .monokai: return Color(red: 0.22, green: 0.22, blue: 0.18)
        }
    }
    
    func queueBg(for colorScheme: ColorScheme) -> Color {
        if self == .system {
            return colorScheme == .dark ? Color(white: 0.12) : Color(NSColor.controlBackgroundColor)
        }
        return queueBgFixed
    }
    
    var queueBgFixed: Color {
        switch self {
        case .system: return Color(NSColor.controlBackgroundColor)
        case .ocean: return Color(red: 0.05, green: 0.1, blue: 0.18)
        case .forest: return Color(red: 0.05, green: 0.12, blue: 0.09)
        case .sunset: return Color(red: 0.16, green: 0.09, blue: 0.05)
        case .purple: return Color(red: 0.1, green: 0.07, blue: 0.15)
        case .rose: return Color(red: 0.16, green: 0.07, blue: 0.1)
        case .midnight: return Color(red: 0.07, green: 0.09, blue: 0.14)
        case .monokai: return Color(red: 0.13, green: 0.13, blue: 0.1)
        }
    }
    
    func dividerColor(for colorScheme: ColorScheme) -> Color {
        if self == .system {
            return colorScheme == .dark ? Color.white.opacity(0.15) : Color(NSColor.separatorColor)
        }
        return Color.white.opacity(0.15)
    }
    
    func textColor(for colorScheme: ColorScheme) -> Color {
        if self == .system {
            return colorScheme == .dark ? .white : Color(NSColor.labelColor)
        }
        return .white
    }
    
    func secondaryText(for colorScheme: ColorScheme) -> Color {
        if self == .system {
            return colorScheme == .dark ? Color.white.opacity(0.7) : Color(NSColor.secondaryLabelColor)
        }
        return Color.white.opacity(0.7)
    }
}

enum FontSize: String, CaseIterable, Codable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    case extraLarge = "Extra Large"
    
    var scale: CGFloat {
        switch self {
        case .small: return 0.85
        case .medium: return 1.0
        case .large: return 1.15
        case .extraLarge: return 1.3
        }
    }
}

enum EpisodeFilter: String, CaseIterable {
    case all = "All"
    case unplayed = "Unplayed"
    case inProgress = "In Progress"
    case downloaded = "Downloaded"
    case favorites = "Favorites"
}

enum EpisodeSort: String, CaseIterable {
    case newestFirst = "Newest First"
    case oldestFirst = "Oldest First"
    case longestFirst = "Longest First"
    case shortestFirst = "Shortest First"
    case titleAZ = "Title A-Z"
    case titleZA = "Title Z-A"
}

// MARK: - App Settings

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    @Published var theme: AppTheme = .system
    @Published var playbackSpeed: Float = 1.0
    @Published var fontSize: FontSize = .medium
    @Published var volumeBoost: Float = 1.0
    @Published var continuousPlayback: Bool = false
    @Published var playbackHistory: [PlayedItem] = []
    @Published var podcastCategories: [String: String] = [:]
    @Published var episodeNotes: [String: String] = [:]
    @Published var listeningStats: ListeningStats = ListeningStats()
    
    private var settingsURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let podvault = appSupport.appendingPathComponent("PodVault", isDirectory: true)
        try? FileManager.default.createDirectory(at: podvault, withIntermediateDirectories: true)
        return podvault.appendingPathComponent("settings.json")
    }
    
    init() { load() }
    
    func load() {
        if let data = try? Data(contentsOf: settingsURL),
           let decoded = try? JSONDecoder().decode(SettingsData.self, from: data) {
            theme = decoded.theme
            playbackSpeed = decoded.playbackSpeed
            fontSize = decoded.fontSize ?? .medium
            volumeBoost = decoded.volumeBoost ?? 1.0
            continuousPlayback = decoded.continuousPlayback ?? false
            playbackHistory = decoded.playbackHistory ?? []
            podcastCategories = decoded.podcastCategories ?? [:]
            episodeNotes = decoded.episodeNotes ?? [:]
            listeningStats = decoded.listeningStats ?? ListeningStats()
        }
    }
    
    func save() {
        let data = SettingsData(
            theme: theme, playbackSpeed: playbackSpeed, fontSize: fontSize,
            volumeBoost: volumeBoost, continuousPlayback: continuousPlayback,
            playbackHistory: playbackHistory, podcastCategories: podcastCategories,
            episodeNotes: episodeNotes, listeningStats: listeningStats
        )
        if let encoded = try? JSONEncoder().encode(data) {
            try? encoded.write(to: settingsURL)
        }
    }
    
    func addToHistory(_ episode: Episode, podcastTitle: String) {
        let item = PlayedItem(episodeId: episode.id, episodeTitle: episode.title, podcastTitle: podcastTitle, playedAt: Date())
        playbackHistory.insert(item, at: 0)
        if playbackHistory.count > 100 { playbackHistory = Array(playbackHistory.prefix(100)) }
        save()
    }
    
    func addListeningTime(_ seconds: Double) {
        listeningStats.totalSeconds += seconds
        let today = Calendar.current.startOfDay(for: Date())
        listeningStats.dailySeconds[today, default: 0] += seconds
        listeningStats.episodesPlayed += 1
        
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        if listeningStats.lastListenedDate == nil || listeningStats.lastListenedDate! < yesterday {
            listeningStats.currentStreak = 1
        } else if listeningStats.lastListenedDate == yesterday {
            listeningStats.currentStreak += 1
        }
        listeningStats.lastListenedDate = today
        listeningStats.longestStreak = max(listeningStats.longestStreak, listeningStats.currentStreak)
        save()
    }
    
    func setNote(for episodeId: String, note: String) {
        if note.isEmpty { episodeNotes.removeValue(forKey: episodeId) }
        else { episodeNotes[episodeId] = note }
        save()
    }
    
    func getNote(for episodeId: String) -> String { episodeNotes[episodeId] ?? "" }
    
    func setCategory(for podcastId: String, category: String) {
        if category.isEmpty { podcastCategories.removeValue(forKey: podcastId) }
        else { podcastCategories[podcastId] = category }
        save()
    }
    
    func getCategory(for podcastId: String) -> String { podcastCategories[podcastId] ?? "" }
    
    var allCategories: [String] { Array(Set(podcastCategories.values)).sorted() }
}

struct PlayedItem: Codable, Identifiable {
    var id: String { episodeId + playedAt.description }
    let episodeId: String
    let episodeTitle: String
    let podcastTitle: String
    let playedAt: Date
}

struct ListeningStats: Codable {
    var totalSeconds: Double = 0
    var episodesPlayed: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastListenedDate: Date?
    var dailySeconds: [Date: Double] = [:]
}

struct SettingsData: Codable {
    var theme: AppTheme
    var playbackSpeed: Float
    var fontSize: FontSize?
    var volumeBoost: Float?
    var continuousPlayback: Bool?
    var playbackHistory: [PlayedItem]?
    var podcastCategories: [String: String]?
    var episodeNotes: [String: String]?
    var listeningStats: ListeningStats?
}

// MARK: - Mini Player Window

class MiniPlayerWindow: NSWindow {
    init() {
        super.init(contentRect: NSRect(x: 0, y: 0, width: 300, height: 110),
                   styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
                   backing: .buffered, defer: false)
        self.isReleasedWhenClosed = false
        self.level = .floating
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden
        self.isMovableByWindowBackground = true
        self.center()
    }
}

// MARK: - App Main

@main
struct PodVaultApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var settings = AppSettings.shared
    @State private var showMiniPlayer = false
    @State private var showStats = false
    
    var body: some Scene {
        WindowGroup {
            ContentView(showMiniPlayer: $showMiniPlayer, showStats: $showStats)
                .environmentObject(settings)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Import OPML...") { NotificationCenter.default.post(name: .importOPML, object: nil) }
                    .keyboardShortcut("i", modifiers: [.command, .shift])
                Button("Export OPML...") { NotificationCenter.default.post(name: .exportOPML, object: nil) }
                    .keyboardShortcut("e", modifiers: [.command, .shift])
                Divider()
                Button("Export Listening History...") { NotificationCenter.default.post(name: .exportHistory, object: nil) }
            }
            
            CommandGroup(after: .windowArrangement) {
                Button("Mini Player") { showMiniPlayer.toggle() }
                    .keyboardShortcut("m", modifiers: [.command, .shift])
                Button("Statistics") { showStats.toggle() }
                    .keyboardShortcut("s", modifiers: [.command, .shift])
            }
            
            CommandMenu("Playback") {
                Button("Play/Pause") { NotificationCenter.default.post(name: .togglePlayback, object: nil) }
                    .keyboardShortcut(" ", modifiers: [])
                Button("Next Episode") { NotificationCenter.default.post(name: .playNext, object: nil) }
                    .keyboardShortcut("n", modifiers: [.command])
                Button("Skip Forward") { NotificationCenter.default.post(name: .skipForward, object: nil) }
                    .keyboardShortcut(.rightArrow, modifiers: [.command])
                Button("Skip Back") { NotificationCenter.default.post(name: .skipBack, object: nil) }
                    .keyboardShortcut(.leftArrow, modifiers: [.command])
                Divider()
                Button("Volume Up") { NotificationCenter.default.post(name: .volumeUp, object: nil) }
                    .keyboardShortcut(.upArrow, modifiers: [.command])
                Button("Volume Down") { NotificationCenter.default.post(name: .volumeDown, object: nil) }
                    .keyboardShortcut(.downArrow, modifiers: [.command])
                Divider()
                Toggle("Continuous Playback", isOn: Binding(
                    get: { settings.continuousPlayback },
                    set: { settings.continuousPlayback = $0; settings.save() }
                ))
            }
            
            CommandMenu("Theme") {
                ForEach(AppTheme.allCases, id: \.self) { theme in
                    Button {
                        settings.theme = theme
                        settings.save()
                    } label: {
                        if settings.theme == theme { Text("✓ " + theme.rawValue) }
                        else { Text("    " + theme.rawValue) }
                    }
                }
            }
            
            CommandMenu("Speed") {
                ForEach([0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0], id: \.self) { speed in
                    Button {
                        settings.playbackSpeed = Float(speed)
                        settings.save()
                        NotificationCenter.default.post(name: .speedChanged, object: nil)
                    } label: {
                        if settings.playbackSpeed == Float(speed) { Text("✓ \(speed, specifier: "%.2g")x") }
                        else { Text("    \(speed, specifier: "%.2g")x") }
                    }
                }
            }
            
            CommandMenu("Font Size") {
                ForEach(FontSize.allCases, id: \.self) { size in
                    Button {
                        settings.fontSize = size
                        settings.save()
                    } label: {
                        if settings.fontSize == size { Text("✓ " + size.rawValue) }
                        else { Text("    " + size.rawValue) }
                    }
                }
            }
        }
    }
}

extension Notification.Name {
    static let importOPML = Notification.Name("importOPML")
    static let exportOPML = Notification.Name("exportOPML")
    static let exportHistory = Notification.Name("exportHistory")
    static let togglePlayback = Notification.Name("togglePlayback")
    static let playNext = Notification.Name("playNext")
    static let skipForward = Notification.Name("skipForward")
    static let skipBack = Notification.Name("skipBack")
    static let volumeUp = Notification.Name("volumeUp")
    static let volumeDown = Notification.Name("volumeDown")
    static let speedChanged = Notification.Name("speedChanged")
}

enum LibraryView: Equatable {
    case none
    case continueListening
    case downloads
    case favoritePodcasts
    case favoriteEpisodes
    case allEpisodes
    case history
    case category(String)
}

struct RefreshSummary: Equatable {
    let title: String
    let subtitle: String
    let failedFeeds: [String]

    static func libraryRefresh(refreshedFeedCount: Int, newEpisodeCount: Int, failedFeeds: [String]) -> RefreshSummary {
        let title = failedFeeds.isEmpty ? "Refresh complete" : "Refresh finished with issues"
        let feedText = refreshedFeedCount == 1 ? "1 feed" : "\(refreshedFeedCount) feeds"
        let episodeText = newEpisodeCount == 1 ? "1 new episode" : "\(newEpisodeCount) new episodes"
        let subtitle: String
        if failedFeeds.isEmpty {
            subtitle = "\(feedText), \(episodeText)"
        } else {
            let failureText = failedFeeds.count == 1 ? "1 failed" : "\(failedFeeds.count) failed"
            subtitle = "\(feedText), \(episodeText), \(failureText)"
        }
        return RefreshSummary(title: title, subtitle: subtitle, failedFeeds: failedFeeds)
    }

    static func singlePodcastSuccess(title: String, newEpisodeCount: Int) -> RefreshSummary {
        let episodeText = newEpisodeCount == 1 ? "1 new episode" : "\(newEpisodeCount) new episodes"
        return RefreshSummary(
            title: "Podcast refreshed",
            subtitle: "\(title), \(episodeText)",
            failedFeeds: []
        )
    }

    static func singlePodcastFailure(title: String) -> RefreshSummary {
        RefreshSummary(
            title: "Podcast refresh failed",
            subtitle: title,
            failedFeeds: [title]
        )
    }
}

// MARK: - Content View

struct ContentView: View {
    @EnvironmentObject var settings: AppSettings
    @Environment(\.colorScheme) var colorScheme
    @Binding var showMiniPlayer: Bool
    @Binding var showStats: Bool
    @StateObject private var playbackManager = PlaybackManager.shared
    @StateObject private var downloadManager = DownloadManager.shared
    @StateObject private var library = LibraryViewModel()
    private let libraryService = LibraryService()
    
    @State private var showAddSheet = false
    @State private var feedURL = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var sidebarWidth: CGFloat = 220
    @State private var episodesWidth: CGFloat = 320
    @State private var playQueue: [Episode] = []
    @State private var showCategorySheet = false
    @State private var selectedPodcastForCategory: Podcast?
    @State private var newCategoryName = ""
    @State private var showNoteEditor = false
    @State private var currentNote = ""
    @State private var miniPlayerWindow: MiniPlayerWindow?
    @State private var refreshSummary: RefreshSummary?
    
    let playbackSpeeds: [Float] = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
    
    var theme: AppTheme { settings.theme }
    var scale: CGFloat { settings.fontSize.scale }
    
    var sidebarBg: Color { theme.sidebarBg(for: colorScheme) }
    var mainBg: Color { theme.mainBg(for: colorScheme) }
    var detailBg: Color { theme.detailBg(for: colorScheme) }
    var queueBg: Color { theme.queueBg(for: colorScheme) }
    var dividerColor: Color { theme.dividerColor(for: colorScheme) }
    var textColor: Color { theme.textColor(for: colorScheme) }
    var secondaryText: Color { theme.secondaryText(for: colorScheme) }
    var currentlyPlayingEpisode: Episode? { playbackManager.currentEpisode }
    var isPlaying: Bool { playbackManager.isPlaying }
    var currentTime: Double { playbackManager.currentTime }
    var duration: Double { playbackManager.duration }
    
    var selectedPodcast: Podcast? { library.selectedPodcast }
    var sidebarSelectionKey: String { library.sidebarSelectionKey }
    var filteredPodcasts: [Podcast] { library.filteredPodcasts }
    var selectedEpisode: Episode? { library.selectedEpisode() }
    var displayedEpisodes: [Episode] { library.displayedEpisodes() }
    var filteredAndSortedEpisodes: [Episode] {
        library.filteredAndSortedEpisodes(
            isPlayed: effectiveIsPlayed,
            resumePosition: effectiveResumePosition,
            downloadedEpisodeIds: library.downloadedEpisodeIds,
            favoriteEpisodeIds: library.favoriteEpisodeIds
        )
    }
    
    var favoritePodcasts: [Podcast] { library.podcasts.filter { library.favoritePodcastIds.contains($0.id) } }
    var listTitle: String { library.listTitle }
    var shouldShowEpisodeList: Bool { library.shouldShowEpisodeList }
    
    var hasNextEpisode: Bool {
        if !playQueue.isEmpty { return true }
        guard let current = currentlyPlayingEpisode else { return false }
        let feedEpisodes = library.episodes.sorted { ($0.pubDate ?? .distantPast) > ($1.pubDate ?? .distantPast) }
        if let index = feedEpisodes.firstIndex(where: { $0.id == current.id }) {
            return index + 1 < feedEpisodes.count
        }
        return false
    }

    func effectiveIsPlayed(_ episode: Episode) -> Bool {
        episode.isPlayed
    }

    func effectiveResumePosition(_ episode: Episode) -> Double {
        if currentlyPlayingEpisode?.id == episode.id {
            return max(currentTime, Double(episode.playbackPosition))
        }
        return Double(episode.playbackPosition)
    }
    
    var body: some View {
        contentBody
    }

    var rootLayout: AnyView {
        AnyView(
            GeometryReader { geometry in
                mainLayout(geometry: geometry)
            }
        )
    }

    var framedRootLayout: AnyView {
        AnyView(rootLayout.frame(minWidth: 1000, minHeight: 700))
    }

    var overlayRootLayout: AnyView {
        AnyView(
            framedRootLayout.overlay(alignment: .bottom) {
                if let episode = currentlyPlayingEpisode {
                    nowPlayingBar(episode: episode)
                }
            }
        )
    }

    var sheetRootLayout: AnyView {
        AnyView(
            overlayRootLayout
                .background(mainBg)
                .sheet(isPresented: $showAddSheet) { addPodcastSheet }
                .sheet(isPresented: $showCategorySheet) { categorySheet }
                .sheet(isPresented: $showNoteEditor) { noteEditorSheet }
                .sheet(isPresented: $showStats) { statsView }
        )
    }

    var lifecycleRootLayout: AnyView {
        AnyView(
            sheetRootLayout.task {
                await loadPodcasts()
                await libraryService.validateDownloadedEpisodes()
                await loadDownloadedEpisodesList()
                _ = await library.loadInProgressEpisodesList()
                await loadFavorites()
                playbackManager.playbackSpeed = settings.playbackSpeed
                playbackManager.setVolumeBoost(settings.volumeBoost)
            }
        )
    }

    var notificationRootLayout: AnyView {
        AnyView(
            lifecycleRootLayout
                .onReceive(NotificationCenter.default.publisher(for: .importOPML)) { _ in importOPML() }
                .onReceive(NotificationCenter.default.publisher(for: .exportOPML)) { _ in exportOPML() }
                .onReceive(NotificationCenter.default.publisher(for: .exportHistory)) { _ in exportHistory() }
                .onReceive(NotificationCenter.default.publisher(for: .togglePlayback)) { _ in togglePlayPause() }
                .onReceive(NotificationCenter.default.publisher(for: .playNext)) { _ in playNextEpisode() }
                .onReceive(NotificationCenter.default.publisher(for: .skipForward)) { _ in skipForward() }
                .onReceive(NotificationCenter.default.publisher(for: .skipBack)) { _ in skipBackward() }
                .onReceive(NotificationCenter.default.publisher(for: .volumeUp)) { _ in adjustVolume(by: 0.1) }
                .onReceive(NotificationCenter.default.publisher(for: .volumeDown)) { _ in adjustVolume(by: -0.1) }
                .onReceive(NotificationCenter.default.publisher(for: .speedChanged)) { _ in
                    playbackManager.playbackSpeed = settings.playbackSpeed
                }
                .onReceive(NotificationCenter.default.publisher(for: .playbackEnded)) { notification in
                    handlePlaybackEnded(notification)
                }
                .onReceive(NotificationCenter.default.publisher(for: .playbackPositionChanged)) { _ in
                    Task { _ = await library.loadInProgressEpisodesList() }
                }
                .onReceive(NotificationCenter.default.publisher(for: .downloadCompleted)) { notification in
                    handleDownloadCompleted(notification)
                }
        )
    }

    var contentBody: some View {
        notificationRootLayout
            .onChange(of: showMiniPlayer) { _, show in
                if show { openMiniPlayer() } else { closeMiniPlayer() }
            }
            .onChange(of: library.searchText) { _, _ in
                Task { await library.refreshSearchResults() }
            }
            .onChange(of: currentlyPlayingEpisode?.id) { _, _ in updateMiniPlayer() }
            .onChange(of: isPlaying) { _, _ in updateMiniPlayer() }
            .onChange(of: currentTime) { _, _ in updateMiniPlayer() }
    }

    func mainLayout(geometry: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            sidebarView.frame(width: sidebarWidth)

            Rectangle().fill(dividerColor).frame(width: 1)
                .contentShape(Rectangle().size(width: 8, height: geometry.size.height))
                .gesture(DragGesture().onChanged { v in sidebarWidth = max(180, min(350, sidebarWidth + v.translation.width)) })
                .onHover { h in if h { NSCursor.resizeLeftRight.push() } else { NSCursor.pop() } }

            episodesView.frame(width: episodesWidth)

            Rectangle().fill(dividerColor).frame(width: 1)
                .contentShape(Rectangle().size(width: 8, height: geometry.size.height))
                .gesture(DragGesture().onChanged { v in episodesWidth = max(250, min(500, episodesWidth + v.translation.width)) })
                .onHover { h in if h { NSCursor.resizeLeftRight.push() } else { NSCursor.pop() } }

            VStack(spacing: 0) {
                detailView
                Rectangle().fill(dividerColor).frame(height: 1)
                queueView
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Sidebar
    var sidebarView: some View {
        let categoryCounts = Dictionary(uniqueKeysWithValues: settings.allCategories.map { category in
            (category, library.podcasts.filter { settings.getCategory(for: $0.id) == category }.count)
        })
        
        return AnyView(
            LibrarySidebarView(
                podcastSearchText: Binding(
                    get: { library.podcastSearchText },
                    set: { library.podcastSearchText = $0 }
                ),
                isRefreshing: library.isRefreshing,
                syncSummaryTitle: refreshSummary?.title,
                syncSummarySubtitle: refreshSummary?.subtitle,
                syncSummaryFailures: refreshSummary?.failedFeeds ?? [],
                continueListeningCount: library.inProgressEpisodesList.count,
                historyCount: settings.playbackHistory.count,
                downloadedCount: library.downloadedEpisodeIds.count,
                favoritePodcastCount: library.favoritePodcastIds.count,
                favoriteEpisodeCount: library.favoriteEpisodeIds.count,
                categories: settings.allCategories,
                categoryCounts: categoryCounts,
                podcasts: filteredPodcasts,
                selectedPodcastId: library.selectedPodcastId,
                currentView: sidebarSelectionKey,
                scale: scale,
                accentColor: theme.accentColor,
                buttonBg: theme.buttonBg,
                buttonText: theme.buttonText,
                sidebarBg: sidebarBg,
                dividerColor: dividerColor,
                textColor: textColor,
                secondaryText: secondaryText,
                onRefreshAll: {
                    Task { await refreshAllFeeds() }
                },
                onSelectAllEpisodes: {
                    Task { await library.selectAllEpisodes() }
                },
                onSelectContinueListening: {
                    Task { await library.selectContinueListening() }
                },
                onSelectHistory: {
                    library.selectHistory()
                },
                onSelectDownloads: {
                    Task { await library.selectDownloads() }
                },
                onSelectFavoritePodcasts: {
                    library.selectFavoritePodcasts()
                },
                onSelectFavoriteEpisodes: {
                    Task { await library.selectFavoriteEpisodes() }
                },
                onSelectCategory: { category in
                    library.selectCategory(category)
                },
                onSelectPodcast: { podcast in
                    Task { await library.selectPodcast(podcast) }
                },
                onRefreshPodcast: { podcast in
                    Task { await refreshFeed(podcast) }
                },
                onToggleFavoritePodcast: toggleFavoritePodcast,
                onSetCategoryForPodcast: { podcast in
                    selectedPodcastForCategory = podcast
                    newCategoryName = settings.getCategory(for: podcast.id)
                    showCategorySheet = true
                },
                onDeletePodcast: { podcast in
                    Task { await deletePodcast(podcast) }
                },
                onShowAddPodcast: {
                    showAddSheet = true
                },
                onDismissSyncSummary: {
                    refreshSummary = nil
                }
            )
        )
    }
    
    // MARK: - Episodes View
    var episodesView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(listTitle).font(.system(size: 16 * scale, weight: .semibold)).foregroundColor(textColor).lineLimit(1)
                Spacer()
                if let podcast = selectedPodcast {
                    Button { Task { await refreshFeed(podcast) } } label: {
                        Image(systemName: "arrow.clockwise").font(.system(size: 12)).foregroundColor(theme.accentColor)
                    }.buttonStyle(.plain)
                }
            }
            .padding()
            
            if library.currentView == .history {
                Rectangle().fill(dividerColor).frame(height: 1)
                historyView
            } else if library.currentView == .favoritePodcasts {
                Rectangle().fill(dividerColor).frame(height: 1)
                favoritePodcastsView
            } else if case .category(let cat) = library.currentView {
                Rectangle().fill(dividerColor).frame(height: 1)
                categoryPodcastsView(category: cat)
            } else if shouldShowEpisodeList {
                EpisodeListContentView(
                    searchText: Binding(
                        get: { library.searchText },
                        set: { library.searchText = $0 }
                    ),
                    episodeFilter: library.episodeFilter,
                    episodeSort: library.episodeSort,
                    filteredEpisodes: filteredAndSortedEpisodes,
                    scale: scale,
                    accentColor: theme.accentColor,
                    dividerColor: dividerColor,
                    textColor: textColor,
                    secondaryText: secondaryText,
                    onSelectFilter: { library.episodeFilter = $0 },
                    onSelectSort: { library.episodeSort = $0 },
                    rowContent: { episode, _ in
                        AnyView(episodeRow(episode: episode))
                    }
                )
            } else {
                Rectangle().fill(dividerColor).frame(height: 1)
                VStack { Spacer(); Text("Select a podcast").font(.system(size: 14 * scale)).foregroundColor(secondaryText); Spacer() }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(mainBg)
    }
    
    var historyView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(settings.playbackHistory.enumerated()), id: \.element.id) { index, item in
                    VStack(spacing: 0) {
                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.episodeTitle)
                                    .font(.system(size: 14 * scale, weight: .medium))
                                    .foregroundColor(textColor).lineLimit(2)
                                HStack(spacing: 6) {
                                    Text(item.podcastTitle).font(.system(size: 11 * scale)).foregroundColor(secondaryText)
                                    Text("•").foregroundColor(secondaryText)
                                    Text(item.playedAt, style: .relative).font(.system(size: 11 * scale)).foregroundColor(secondaryText)
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 12).padding(.vertical, 10)
                        if index < settings.playbackHistory.count - 1 {
                            Rectangle().fill(dividerColor).frame(height: 1).padding(.leading, 12)
                        }
                    }
                }
            }
        }
    }
    
    var favoritePodcastsView: some View {
        if favoritePodcasts.isEmpty {
            return AnyView(VStack { Spacer(); Text("No favorite podcasts").font(.system(size: 14 * scale)).foregroundColor(secondaryText); Spacer() }
                .frame(maxWidth: .infinity, maxHeight: .infinity))
        }
        return AnyView(ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(favoritePodcasts.enumerated()), id: \.element.id) { index, podcast in
                    VStack(spacing: 0) {
                        Button {
                            library.currentView = .none; library.selectedPodcastId = podcast.id
                            Task { await library.selectPodcast(podcast) }
                        } label: {
                            HStack {
                                if let artworkURL = podcast.artworkURL, let url = URL(string: artworkURL) {
                                    AsyncImage(url: url) { image in image.resizable().aspectRatio(contentMode: .fill) }
                                    placeholder: { Image(systemName: "mic.fill").foregroundColor(theme.accentColor) }
                                        .frame(width: 36, height: 36).cornerRadius(4)
                                } else {
                                    Image(systemName: "mic.fill").foregroundColor(theme.accentColor).frame(width: 36, height: 36)
                                }
                                Text(podcast.title).font(.system(size: 14 * scale)).foregroundColor(textColor)
                                Spacer()
                                Image(systemName: "star.fill").foregroundColor(.yellow).font(.system(size: 12 * scale))
                            }
                            .padding(.horizontal, 12).padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)
                        if index < favoritePodcasts.count - 1 {
                            Rectangle().fill(dividerColor).frame(height: 1).padding(.leading, 12)
                        }
                    }
                }
            }
        })
    }
    
    func categoryPodcastsView(category: String) -> some View {
        let categoryPodcasts = library.podcasts.filter { settings.getCategory(for: $0.id) == category }
        if categoryPodcasts.isEmpty {
            return AnyView(VStack { Spacer(); Text("No podcasts in this category").font(.system(size: 14 * scale)).foregroundColor(secondaryText); Spacer() }
                .frame(maxWidth: .infinity, maxHeight: .infinity))
        }
        return AnyView(ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(categoryPodcasts.enumerated()), id: \.element.id) { index, podcast in
                    VStack(spacing: 0) {
                        Button {
                            Task { await library.selectPodcast(podcast) }
                        } label: {
                            HStack {
                                if let artworkURL = podcast.artworkURL, let url = URL(string: artworkURL) {
                                    AsyncImage(url: url) { image in image.resizable().aspectRatio(contentMode: .fill) }
                                    placeholder: { Image(systemName: "mic.fill").foregroundColor(theme.accentColor) }
                                        .frame(width: 36, height: 36).cornerRadius(4)
                                } else {
                                    Image(systemName: "mic.fill").foregroundColor(theme.accentColor).frame(width: 36, height: 36)
                                }
                                Text(podcast.title).font(.system(size: 14 * scale)).foregroundColor(textColor)
                                Spacer()
                            }
                            .padding(.horizontal, 12).padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)
                        if index < categoryPodcasts.count - 1 {
                            Rectangle().fill(dividerColor).frame(height: 1).padding(.leading, 12)
                        }
                    }
                }
            }
        })
    }
    
    func episodeRow(episode: Episode) -> some View {
        EpisodeRowView(
            episode: episode,
            isSelected: library.selectedEpisodeId == episode.id,
            isPlayed: effectiveIsPlayed(episode),
            resumePosition: effectiveResumePosition(episode),
            isCurrentlyPlaying: currentlyPlayingEpisode?.id == episode.id,
            isPlaying: isPlaying,
            isFavorite: library.favoriteEpisodeIds.contains(episode.id),
            isDownloaded: library.downloadedEpisodeIds.contains(episode.id),
            showDownloadedBadge: library.currentView != .downloads,
            isQueued: playQueue.contains(where: { $0.id == episode.id }),
            hasNote: !settings.getNote(for: episode.id).isEmpty,
            scale: scale,
            accentColor: theme.accentColor,
            textColor: textColor,
            secondaryText: secondaryText,
            selectionColor: theme.accentColor.opacity(0.3),
            formatDuration: formatDuration,
            onSelect: { library.selectedEpisodeId = episode.id },
            onAddToQueue: { addToQueue(episode) },
            onPlayNext: { playNext(episode) },
            onMarkPlayed: { markEpisodePlayed(episode) },
            onMarkUnplayed: { markEpisodeUnplayed(episode) },
            onToggleFavorite: { toggleFavoriteEpisode(episode) },
            onEditNote: {
                library.selectedEpisodeId = episode.id
                currentNote = settings.getNote(for: episode.id)
                showNoteEditor = true
            },
            onShowInFinder: library.currentView == .downloads ? { showInFinder(episode) } : nil
        )
    }
    
    // MARK: - Detail View
    var detailView: some View {
        EpisodeDetailPaneView(
            episode: selectedEpisode,
            podcast: selectedEpisode.flatMap { episode in library.podcasts.first(where: { $0.id == episode.podcastId }) },
            currentlyPlayingEpisodeID: currentlyPlayingEpisode?.id,
            isPlaying: isPlaying,
            isEpisodePlayed: selectedEpisode.map(effectiveIsPlayed) ?? false,
            resumePosition: selectedEpisode.map(effectiveResumePosition) ?? 0,
            isFavorite: selectedEpisode.map { library.favoriteEpisodeIds.contains($0.id) } ?? false,
            isQueued: selectedEpisode.map { episode in playQueue.contains { $0.id == episode.id } } ?? false,
            isDownloaded: selectedEpisode.map { library.downloadedEpisodeIds.contains($0.id) } ?? false,
            isDownloading: selectedEpisode.map { downloadManager.isDownloading(episodeId: $0.id) } ?? false,
            note: selectedEpisode.map { settings.getNote(for: $0.id) } ?? "",
            scale: scale,
            accentColor: theme.accentColor,
            buttonBg: theme.buttonBg,
            buttonText: theme.buttonText,
            detailBg: detailBg,
            dividerColor: dividerColor,
            textColor: textColor,
            secondaryText: secondaryText,
            onPlayPause: togglePlayPause,
            onPlayEpisode: { episode in
                Task {
                    await playEpisode(episode)
                }
            },
            onQueue: addToQueue,
            onToggleFavorite: toggleFavoriteEpisode,
            onShowInFinder: showInFinder,
            onDeleteDownload: deleteDownload,
            onDownload: { episode in
                Task {
                    await downloadEpisode(episode)
                }
            },
            onEditNote: {
                if let episode = selectedEpisode {
                    currentNote = settings.getNote(for: episode.id)
                    showNoteEditor = true
                }
            },
            onAddNote: {
                currentNote = ""
                showNoteEditor = true
            },
            formatDuration: formatDuration,
            formatTime: formatTime,
            stripHTML: stripHTML
        )
    }
    
    // MARK: - Queue View
    var queueView: some View {
        QueuePanelView(
            queue: playQueue,
            activeDownloads: downloadManager.activeDownloads.values.sorted { $0.startTime < $1.startTime },
            queuedDownloads: downloadManager.queuedDownloads,
            overallDownloadProgress: downloadManager.overallProgress,
            accentColor: theme.accentColor,
            textColor: textColor,
            secondaryText: secondaryText,
            dividerColor: dividerColor,
            backgroundColor: queueBg,
            scale: scale,
            formatDuration: formatDuration,
            onClear: { playQueue.removeAll() },
            onRemove: { playQueue.remove(at: $0) },
            onSelect: playFromQueue(at:),
            onCancelDownload: { downloadManager.cancelDownload(episodeId: $0) },
            onCancelAllDownloads: { downloadManager.cancelAllDownloads() }
        )
    }
    
    // MARK: - Now Playing Bar
    func nowPlayingBar(episode: Episode) -> some View {
        NowPlayingBarView(
            episode: episode,
            isPlaying: isPlaying,
            currentTime: currentTime,
            duration: duration,
            hasNextEpisode: hasNextEpisode,
            scale: scale,
            accentColor: theme.accentColor,
            buttonBg: theme.buttonBg,
            buttonText: theme.buttonText,
            sidebarBg: sidebarBg,
            dividerColor: dividerColor,
            textColor: textColor,
            secondaryText: secondaryText,
            volumeBoost: settings.volumeBoost,
            selectedSpeed: settings.playbackSpeed,
            playbackSpeeds: playbackSpeeds,
            formatTime: formatTime,
            formatSpeed: formatSpeed,
            onSkipBackward: skipBackward,
            onPlayPause: togglePlayPause,
            onSkipForward: skipForward,
            onNext: playNextEpisode,
            onSeek: { playbackManager.seek(to: $0) },
            onSetSpeed: setPlaybackSpeed,
            onStop: stopPlayback
        )
    }
    
    // MARK: - Sheets
    
    var addPodcastSheet: some View {
        VStack(spacing: 20) {
            Text("Add Podcast").font(.system(size: 18 * scale, weight: .semibold))
            TextField("Feed URL", text: $feedURL).font(.system(size: 14 * scale)).frame(width: 350)
            if isLoading { ProgressView("Adding podcast...") }
            if let error = errorMessage { Text(error).foregroundStyle(.red).font(.system(size: 12 * scale)) }
            HStack {
                Button("Cancel") { showAddSheet = false; feedURL = ""; errorMessage = nil }
                Button("Add") { Task { await addPodcast(url: feedURL) } }
                    .buttonStyle(.borderedProminent).tint(theme.buttonBg)
                    .disabled(feedURL.isEmpty || isLoading)
            }
        }
        .padding(30)
    }
    
    var categorySheet: some View {
        VStack(spacing: 20) {
            Text("Set Category").font(.system(size: 18 * scale, weight: .semibold))
            if let podcast = selectedPodcastForCategory {
                Text(podcast.title).foregroundColor(.secondary)
            }
            TextField("Category name", text: $newCategoryName).frame(width: 250)
            if !settings.allCategories.isEmpty {
                Text("Existing categories:").font(.caption).foregroundColor(.secondary)
                HStack {
                    ForEach(settings.allCategories, id: \.self) { cat in
                        Button(cat) { newCategoryName = cat }.buttonStyle(.bordered)
                    }
                }
            }
            HStack {
                Button("Cancel") { showCategorySheet = false }
                Button("Save") {
                    if let podcast = selectedPodcastForCategory {
                        settings.setCategory(for: podcast.id, category: newCategoryName)
                    }
                    showCategorySheet = false
                }
                .buttonStyle(.borderedProminent).tint(theme.buttonBg)
            }
        }
        .padding(30)
    }
    
    var noteEditorSheet: some View {
        VStack(spacing: 20) {
            Text("Episode Note").font(.system(size: 18 * scale, weight: .semibold))
            if let episode = selectedEpisode {
                Text(episode.title).font(.caption).foregroundColor(.secondary).lineLimit(2)
            }
            TextEditor(text: $currentNote)
                .frame(width: 350, height: 150)
                .font(.system(size: 14))
            HStack {
                Button("Cancel") { showNoteEditor = false }
                if !currentNote.isEmpty {
                    Button("Delete") {
                        if let episode = selectedEpisode { settings.setNote(for: episode.id, note: "") }
                        showNoteEditor = false
                    }
                    .foregroundColor(.red)
                }
                Button("Save") {
                    if let episode = selectedEpisode { settings.setNote(for: episode.id, note: currentNote) }
                    showNoteEditor = false
                }
                .buttonStyle(.borderedProminent).tint(theme.buttonBg)
            }
        }
        .padding(30)
    }
    
    var statsView: some View {
        VStack(spacing: 24) {
            Text("Listening Statistics").font(.system(size: 20, weight: .bold))
            
            HStack(spacing: 40) {
                statBox(title: "Total Time", value: formatTotalTime(settings.listeningStats.totalSeconds))
                statBox(title: "Episodes", value: "\(settings.listeningStats.episodesPlayed)")
                statBox(title: "Current Streak", value: "\(settings.listeningStats.currentStreak) days")
                statBox(title: "Longest Streak", value: "\(settings.listeningStats.longestStreak) days")
            }
            
            Divider()
            
            Text("Last 7 Days").font(.headline)
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<7, id: \.self) { i in
                    let date = Calendar.current.date(byAdding: .day, value: -6 + i, to: Calendar.current.startOfDay(for: Date()))!
                    let seconds = settings.listeningStats.dailySeconds[date] ?? 0
                    let maxSeconds = settings.listeningStats.dailySeconds.values.max() ?? 1
                    let height = max(4, CGFloat(seconds / max(maxSeconds, 1)) * 80)
                    VStack {
                        Rectangle().fill(theme.accentColor).frame(width: 30, height: height).cornerRadius(4)
                        Text(dayAbbrev(date)).font(.system(size: 10)).foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 120)
            
            Button("Close") { showStats = false }
                .buttonStyle(.borderedProminent).tint(theme.buttonBg)
        }
        .padding(40)
        .frame(width: 500)
    }
    
    func statBox(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 24, weight: .bold)).foregroundColor(theme.accentColor)
            Text(title).font(.caption).foregroundColor(.secondary)
        }
    }
    
    func dayAbbrev(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    func formatTotalTime(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let mins = (Int(seconds) % 3600) / 60
        if hours > 0 { return "\(hours)h \(mins)m" }
        return "\(mins)m"
    }
    
    // MARK: - Mini Player
    
    func openMiniPlayer() {
        if miniPlayerWindow == nil {
            miniPlayerWindow = MiniPlayerWindow()
        }
        updateMiniPlayer()
        miniPlayerWindow?.makeKeyAndOrderFront(nil)
    }
    
    func updateMiniPlayer() {
        guard showMiniPlayer, let window = miniPlayerWindow else { return }
        let hostingView = NSHostingView(rootView: MiniPlayerView(
            episode: currentlyPlayingEpisode,
            isPlaying: isPlaying,
            currentTime: currentTime,
            duration: duration,
            theme: theme,
            hasNext: hasNextEpisode,
            onPlayPause: { togglePlayPause() },
            onSkipBack: { skipBackward() },
            onSkipForward: { skipForward() },
            onNext: { playNextEpisode() },
            onClose: { showMiniPlayer = false }
        ).environmentObject(settings))
        window.contentView = hostingView
    }
    
    func closeMiniPlayer() {
        miniPlayerWindow?.close()
    }
    
    // MARK: - Queue Functions
    
    func addToQueue(_ episode: Episode) {
        if !playQueue.contains(where: { $0.id == episode.id }) {
            playQueue.append(episode)
        }
    }
    
    func playNext(_ episode: Episode) {
        playQueue.removeAll { $0.id == episode.id }
        playQueue.insert(episode, at: 0)
    }
    
    func playFromQueue(at index: Int) {
        guard index < playQueue.count else { return }
        let episode = playQueue[index]
        playQueue.remove(at: index)
        
        Task {
            await playEpisode(episode)
        }
    }
    
    func playNextInQueue() {
        guard !playQueue.isEmpty else { return }
        let episode = playQueue.removeFirst()
        
        Task {
            await playEpisode(episode)
        }
    }
    
    // MARK: - Playback
    
    func playEpisode(_ episode: Episode) async {
        guard let podcast = library.podcasts.first(where: { $0.id == episode.podcastId }) else { return }
        playbackManager.playbackSpeed = settings.playbackSpeed
        playbackManager.setVolumeBoost(settings.volumeBoost)
        await playbackManager.play(episode: episode, podcast: podcast)
    }
    
    func playNextEpisode() {
        if !playQueue.isEmpty {
            playNextInQueue()
        } else {
            playNextEpisodeInFeed()
        }
    }
    
    func playNextEpisodeInFeed() {
        guard let current = currentlyPlayingEpisode else { return }
        let feedEpisodes = library.episodes.sorted { ($0.pubDate ?? .distantPast) > ($1.pubDate ?? .distantPast) }
        if let index = feedEpisodes.firstIndex(where: { $0.id == current.id }), index + 1 < feedEpisodes.count {
            let next = feedEpisodes[index + 1]
            Task {
                await playEpisode(next)
            }
        } else {
            stopPlayback()
        }
    }
    
    func togglePlayPause() {
        playbackManager.togglePlayPause()
    }
    
    func stopPlayback() {
        playbackManager.stop()
    }
    
    func seek(to time: Double) { playbackManager.seek(to: time) }
    func skipForward() { playbackManager.skipForward() }
    func skipBackward() { playbackManager.skipBackward() }
    
    func setPlaybackSpeed(_ speed: Float) {
        settings.playbackSpeed = speed
        settings.save()
        playbackManager.playbackSpeed = speed
    }
    
    func adjustVolume(by delta: Float) {
        settings.volumeBoost = max(0.5, min(2.0, settings.volumeBoost + delta))
        playbackManager.setVolumeBoost(settings.volumeBoost)
        settings.save()
    }
    
    func handlePlaybackEnded(_ notification: Notification) {
        if let episode = notification.userInfo?["episode"] as? Episode,
           let podcastTitle = notification.userInfo?["podcastTitle"] as? String {
            settings.addToHistory(episode, podcastTitle: podcastTitle)
        }
        
        if let playbackDuration = notification.userInfo?["playbackDuration"] as? Double,
           playbackDuration > 0 {
            settings.addListeningTime(playbackDuration)
        }
        
        if !playQueue.isEmpty {
            playNextInQueue()
        } else if settings.continuousPlayback {
            playNextEpisodeInFeed()
        }

        Task {
            _ = await library.loadInProgressEpisodesList()
        }
    }

    func handleDownloadCompleted(_ notification: Notification) {
        Task {
            await loadDownloadedEpisodesList()
        }
    }
    
    // MARK: - Data Operations
    
    func loadPodcasts() async {
        await library.loadPodcasts()
    }
    
    func loadEpisodes(for podcast: Podcast) async {
        await library.loadEpisodes(for: podcast)
    }
    
    func loadAllEpisodes() async {
        await library.loadAllEpisodes()
    }
    
    func loadDownloadedEpisodesList() async {
        _ = await library.loadDownloadedEpisodesList()
    }
    
    func loadFavoriteEpisodesList() async {
        _ = await library.loadFavoriteEpisodesList()
    }
    
    func addPodcast(url: String) async {
        await MainActor.run { isLoading = true; errorMessage = nil }
        do {
            let podcast = try await libraryService.addPodcast(feedURL: url)
            await loadPodcasts()
            await library.selectPodcast(podcast)
            await MainActor.run { isLoading = false; showAddSheet = false; feedURL = "" }
        } catch {
            await MainActor.run { isLoading = false; errorMessage = "Failed: \(error.localizedDescription)" }
        }
    }
    
    func deletePodcast(_ podcast: Podcast) async {
        do {
            try await libraryService.deletePodcast(id: podcast.id)
            await loadPodcasts()
            library.handleDeletedPodcast(id: podcast.id)
            settings.podcastCategories.removeValue(forKey: podcast.id)
            settings.save()
        } catch { print("Error: \(error)") }
    }
    
    func refreshFeed(_ podcast: Podcast, reloadLibraryState: Bool = true) async -> PodcastRefreshResult? {
        do {
            let result = try await libraryService.refreshPodcast(podcast)
            guard reloadLibraryState else { return result }
            await loadPodcasts()
            await library.reloadVisibleContent(afterPodcastUpdate: podcast)
            await MainActor.run {
                refreshSummary = .singlePodcastSuccess(title: podcast.title, newEpisodeCount: result.newEpisodeCount)
            }
            return result
        } catch {
            print("Error: \(error)")
            if reloadLibraryState {
                await MainActor.run {
                    refreshSummary = .singlePodcastFailure(title: podcast.title)
                }
            }
            return nil
        }
    }
    
    func refreshAllFeeds() async {
        await MainActor.run {
            library.isRefreshing = true
            refreshSummary = nil
        }
        let podcastsToRefresh = library.podcasts
        var successfulRefreshes = 0
        var newEpisodeCount = 0
        var failedFeeds: [String] = []

        for podcast in podcastsToRefresh {
            if let result = await refreshFeed(podcast, reloadLibraryState: false) {
                successfulRefreshes += 1
                newEpisodeCount += result.newEpisodeCount
            } else {
                failedFeeds.append(podcast.title)
            }
        }
        await loadPodcasts()
        await library.reloadVisibleContentAfterLibraryRefresh()
        await MainActor.run {
            library.isRefreshing = false
            refreshSummary = .libraryRefresh(
                refreshedFeedCount: successfulRefreshes,
                newEpisodeCount: newEpisodeCount,
                failedFeeds: failedFeeds
            )
        }
    }
    
    // MARK: - Favorites
    
    var favoritesURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let podvault = appSupport.appendingPathComponent("PodVault", isDirectory: true)
        try? FileManager.default.createDirectory(at: podvault, withIntermediateDirectories: true)
        return podvault.appendingPathComponent("favorites.json")
    }
    
    func loadFavorites() async {
        do {
            let favorites = try await libraryService.loadFavorites(legacyFavoritesURL: favoritesURL)
            await MainActor.run {
                library.applyFavorites(podcastIds: favorites.podcastIDs, episodes: favorites.episodes)
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    func toggleFavoritePodcast(_ podcast: Podcast) {
        let isFavorite = !library.favoritePodcastIds.contains(podcast.id)
        
        Task {
            do {
                try await libraryService.setPodcastFavorite(id: podcast.id, isFavorite: isFavorite)
                await loadFavorites()
                await loadPodcasts()
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    func toggleFavoriteEpisode(_ episode: Episode) {
        let isFavorite = !library.favoriteEpisodeIds.contains(episode.id)
        
        Task {
            do {
                try await libraryService.setEpisodeFavorite(id: episode.id, isFavorite: isFavorite)
                await loadFavorites()
                await library.reloadVisibleContent(afterEpisodeUpdateInPodcastId: episode.podcastId)
            } catch {
                print("Error: \(error)")
            }
        }
    }

    func markEpisodePlayed(_ episode: Episode) {
        Task {
            await libraryService.markEpisodePlayed(id: episode.id, played: true, playbackPosition: 0)
            _ = await library.loadInProgressEpisodesList()
            await library.reloadVisibleContent(afterEpisodeUpdateInPodcastId: episode.podcastId)
        }
    }

    func markEpisodeUnplayed(_ episode: Episode) {
        Task {
            await libraryService.markEpisodePlayed(
                id: episode.id,
                played: false,
                playbackPosition: episode.playbackPosition
            )
            _ = await library.loadInProgressEpisodesList()
            await library.reloadVisibleContent(afterEpisodeUpdateInPodcastId: episode.podcastId)
        }
    }
    
    // MARK: - Downloads
    
    func downloadEpisode(_ episode: Episode) async {
        guard let podcast = library.podcasts.first(where: { $0.id == episode.podcastId }) else { return }
        await downloadManager.downloadEpisode(episode, podcast: podcast)
    }
    
    func deleteDownload(_ episode: Episode) {
        if let path = episode.downloadPath {
            try? FileManager.default.removeItem(at: URL(fileURLWithPath: path))
        }
        library.removeDownloadedEpisode(id: episode.id)
        
        Task {
            await libraryService.clearEpisodeDownload(episode)
            await loadDownloadedEpisodesList()
        }
    }
    
    func showInFinder(_ episode: Episode) {
        guard let path = episode.downloadPath else { return }
        let fileURL = URL(fileURLWithPath: path)
        NSWorkspace.shared.selectFile(fileURL.path, inFileViewerRootedAtPath: fileURL.deletingLastPathComponent().path)
    }
    
    // MARK: - OPML & Export
    
    func importOPML() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.xml]
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url {
            Task {
                if let content = try? String(contentsOf: url, encoding: .utf8) {
                    let urls = parseOPML(content)
                    for feedURL in urls { await addPodcast(url: feedURL) }
                }
            }
        }
    }
    
    func parseOPML(_ content: String) -> [String] {
        var urls: [String] = []
        if let regex = try? NSRegularExpression(pattern: #"xmlUrl="([^"]+)""#, options: []) {
            let matches = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))
            for match in matches {
                if let range = Range(match.range(at: 1), in: content) {
                    urls.append(String(content[range]))
                }
            }
        }
        return urls
    }
    
    func exportOPML() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.xml]
        panel.nameFieldStringValue = "PodVault.opml"
        if panel.runModal() == .OK, let url = panel.url {
            var opml = "<?xml version=\"1.0\"?>\n<opml version=\"2.0\">\n<head><title>PodVault</title></head>\n<body>\n"
            for podcast in library.podcasts {
                let t = podcast.title.replacingOccurrences(of: "&", with: "&amp;").replacingOccurrences(of: "\"", with: "&quot;")
                let u = podcast.feedURL.replacingOccurrences(of: "&", with: "&amp;")
                opml += "<outline text=\"\(t)\" type=\"rss\" xmlUrl=\"\(u)\"/>\n"
            }
            opml += "</body>\n</opml>"
            try? opml.write(to: url, atomically: true, encoding: .utf8)
        }
    }
    
    func exportHistory() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.commaSeparatedText]
        panel.nameFieldStringValue = "PodVault History.csv"
        if panel.runModal() == .OK, let url = panel.url {
            var csv = "Episode,Podcast,Played At\n"
            for item in settings.playbackHistory {
                let ep = item.episodeTitle.replacingOccurrences(of: "\"", with: "\"\"")
                let pod = item.podcastTitle.replacingOccurrences(of: "\"", with: "\"\"")
                csv += "\"\(ep)\",\"\(pod)\",\"\(item.playedAt)\"\n"
            }
            try? csv.write(to: url, atomically: true, encoding: .utf8)
        }
    }
    
    // MARK: - Helpers
    
    func stripHTML(_ html: String) -> String {
        html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&quot;", with: "\"")
    }
    
    func formatDuration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        return h > 0 ? "\(h)h \(m)m" : "\(m) min"
    }
    
    func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite else { return "0:00" }
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        let s = Int(seconds) % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%d:%02d", m, s)
    }
    
    func formatSpeed(_ speed: Float) -> String {
        speed == Float(Int(speed)) ? String(format: "%.0fx", speed) : String(format: "%.2fx", speed)
    }
}

// MARK: - Data Types

struct FavoritesData: Codable {
    var podcastIds: [String]
    var episodeIds: [String]
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        try? DatabaseManager.shared.setup()
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}
