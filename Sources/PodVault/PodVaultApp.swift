import SwiftUI
import AppKit
import AVFoundation

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
    @Published var playbackPositions: [String: Double] = [:]
    @Published var playedEpisodes: Set<String> = []
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
            playbackPositions = decoded.playbackPositions ?? [:]
            playedEpisodes = Set(decoded.playedEpisodes ?? [])
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
            playbackPositions: playbackPositions, playedEpisodes: Array(playedEpisodes),
            volumeBoost: volumeBoost, continuousPlayback: continuousPlayback,
            playbackHistory: playbackHistory, podcastCategories: podcastCategories,
            episodeNotes: episodeNotes, listeningStats: listeningStats
        )
        if let encoded = try? JSONEncoder().encode(data) {
            try? encoded.write(to: settingsURL)
        }
    }
    
    func savePosition(for episodeId: String, position: Double) {
        playbackPositions[episodeId] = position
        save()
    }
    
    func getPosition(for episodeId: String) -> Double { playbackPositions[episodeId] ?? 0 }
    
    func markAsPlayed(_ episodeId: String) {
        playedEpisodes.insert(episodeId)
        playbackPositions.removeValue(forKey: episodeId)
        save()
    }
    
    func markAsUnplayed(_ episodeId: String) {
        playedEpisodes.remove(episodeId)
        save()
    }
    
    func isPlayed(_ episodeId: String) -> Bool { playedEpisodes.contains(episodeId) }
    
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
    var playbackPositions: [String: Double]?
    var playedEpisodes: [String]?
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

// MARK: - Content View

struct ContentView: View {
    @EnvironmentObject var settings: AppSettings
    @Environment(\.colorScheme) var colorScheme
    @Binding var showMiniPlayer: Bool
    @Binding var showStats: Bool
    
    @State private var podcasts: [Podcast] = []
    @State private var episodes: [Episode] = []
    @State private var allEpisodes: [Episode] = []
    @State private var selectedPodcastId: String?
    @State private var selectedEpisodeId: String?
    @State private var showAddSheet = false
    @State private var feedURL = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var downloadedEpisodesList: [Episode] = []
    @State private var currentView: LibraryView = .none
    enum LibraryView: Equatable { case none, downloads, favoritePodcasts, favoriteEpisodes, allEpisodes, history, category(String) }
    @State private var favoritePodcastIds: Set<String> = []
    @State private var favoriteEpisodeIds: Set<String> = []
    @State private var favoriteEpisodesList: [Episode] = []
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var currentlyPlayingEpisode: Episode?
    @State private var currentPodcastTitle: String = ""
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var downloadingEpisodes: Set<String> = []
    @State private var downloadedEpisodes: Set<String> = []
    @State private var sidebarWidth: CGFloat = 220
    @State private var episodesWidth: CGFloat = 320
    @State private var searchText: String = ""
    @State private var podcastSearchText: String = ""
    @State private var isRefreshing = false
    @State private var playbackEndObserver: Any?
    @State private var playQueue: [Episode] = []
    @State private var episodeFilter: EpisodeFilter = .all
    @State private var episodeSort: EpisodeSort = .newestFirst
    @State private var showCategorySheet = false
    @State private var selectedPodcastForCategory: Podcast?
    @State private var newCategoryName = ""
    @State private var showNoteEditor = false
    @State private var currentNote = ""
    @State private var miniPlayerWindow: MiniPlayerWindow?
    @State private var lastPositionSaveTime: Date = Date()
    
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
    
    var selectedPodcast: Podcast? { podcasts.first { $0.id == selectedPodcastId } }
    
    var filteredPodcasts: [Podcast] {
        if podcastSearchText.isEmpty { return podcasts }
        return podcasts.filter { $0.title.localizedCaseInsensitiveContains(podcastSearchText) }
    }
    
    var selectedEpisode: Episode? {
        let list: [Episode]
        switch currentView {
        case .downloads: list = downloadedEpisodesList
        case .favoriteEpisodes: list = favoriteEpisodesList
        case .allEpisodes: list = allEpisodes
        default: list = episodes
        }
        return list.first { $0.id == selectedEpisodeId }
    }
    
    var displayedEpisodes: [Episode] {
        switch currentView {
        case .downloads: return downloadedEpisodesList
        case .favoriteEpisodes: return favoriteEpisodesList
        case .allEpisodes: return allEpisodes
        default: return episodes
        }
    }
    
    var filteredAndSortedEpisodes: [Episode] {
        var result = displayedEpisodes
        
        switch episodeFilter {
        case .all: break
        case .unplayed: result = result.filter { !settings.isPlayed($0.id) && settings.getPosition(for: $0.id) == 0 }
        case .inProgress: result = result.filter { settings.getPosition(for: $0.id) > 0 && !settings.isPlayed($0.id) }
        case .downloaded: result = result.filter { downloadedEpisodes.contains($0.id) }
        case .favorites: result = result.filter { favoriteEpisodeIds.contains($0.id) }
        }
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                ($0.episodeDescription?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        switch episodeSort {
        case .newestFirst: result.sort { ($0.pubDate ?? .distantPast) > ($1.pubDate ?? .distantPast) }
        case .oldestFirst: result.sort { ($0.pubDate ?? .distantPast) < ($1.pubDate ?? .distantPast) }
        case .longestFirst: result.sort { ($0.duration ?? 0) > ($1.duration ?? 0) }
        case .shortestFirst: result.sort { ($0.duration ?? 0) < ($1.duration ?? 0) }
        case .titleAZ: result.sort { $0.title.localizedCompare($1.title) == .orderedAscending }
        case .titleZA: result.sort { $0.title.localizedCompare($1.title) == .orderedDescending }
        }
        
        return result
    }
    
    var favoritePodcasts: [Podcast] { podcasts.filter { favoritePodcastIds.contains($0.id) } }
    
    var listTitle: String {
        switch currentView {
        case .downloads: return "Downloads"
        case .favoritePodcasts: return "Favorite Podcasts"
        case .favoriteEpisodes: return "Favorite Episodes"
        case .allEpisodes: return "All Episodes"
        case .history: return "History"
        case .category(let cat): return cat
        case .none: return selectedPodcast?.title ?? "Episodes"
        }
    }
    
    var shouldShowEpisodeList: Bool {
        currentView == .downloads || currentView == .favoriteEpisodes || currentView == .allEpisodes || selectedPodcast != nil
    }
    
    var hasNextEpisode: Bool {
        if !playQueue.isEmpty { return true }
        guard let current = currentlyPlayingEpisode else { return false }
        let feedEpisodes = episodes.sorted { ($0.pubDate ?? .distantPast) > ($1.pubDate ?? .distantPast) }
        if let index = feedEpisodes.firstIndex(where: { $0.id == current.id }) {
            return index + 1 < feedEpisodes.count
        }
        return false
    }
    
    var body: some View {
        GeometryReader { geometry in
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
        .frame(minWidth: 1000, minHeight: 700)
        .overlay(alignment: .bottom) {
            if let episode = currentlyPlayingEpisode {
                nowPlayingBar(episode: episode)
            }
        }
        .background(mainBg)
        .sheet(isPresented: $showAddSheet) { addPodcastSheet }
        .sheet(isPresented: $showCategorySheet) { categorySheet }
        .sheet(isPresented: $showNoteEditor) { noteEditorSheet }
        .sheet(isPresented: $showStats) { statsView }
        .task {
            await loadPodcasts()
            loadDownloadedEpisodes()
            loadFavorites()
        }
        .onReceive(NotificationCenter.default.publisher(for: .importOPML)) { _ in importOPML() }
        .onReceive(NotificationCenter.default.publisher(for: .exportOPML)) { _ in exportOPML() }
        .onReceive(NotificationCenter.default.publisher(for: .exportHistory)) { _ in exportHistory() }
        .onReceive(NotificationCenter.default.publisher(for: .togglePlayback)) { _ in togglePlayPause() }
        .onReceive(NotificationCenter.default.publisher(for: .playNext)) { _ in playNextEpisode() }
        .onReceive(NotificationCenter.default.publisher(for: .skipForward)) { _ in skipForward() }
        .onReceive(NotificationCenter.default.publisher(for: .skipBack)) { _ in skipBackward() }
        .onReceive(NotificationCenter.default.publisher(for: .volumeUp)) { _ in adjustVolume(by: 0.1) }
        .onReceive(NotificationCenter.default.publisher(for: .volumeDown)) { _ in adjustVolume(by: -0.1) }
        .onReceive(NotificationCenter.default.publisher(for: .speedChanged)) { _ in if isPlaying { player?.rate = settings.playbackSpeed } }
        .onChange(of: showMiniPlayer) { show in
            if show { openMiniPlayer() } else { closeMiniPlayer() }
        }
        .onChange(of: currentlyPlayingEpisode?.id) { _ in updateMiniPlayer() }
        .onChange(of: isPlaying) { _ in updateMiniPlayer() }
        .onChange(of: currentTime) { _ in updateMiniPlayer() }
    }
    
    // MARK: - Sidebar
    var sidebarView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Library").font(.system(size: 16 * scale, weight: .semibold)).foregroundColor(textColor)
                Spacer()
                if isRefreshing {
                    ProgressView().scaleEffect(0.6)
                } else {
                    Button { Task { await refreshAllFeeds() } } label: {
                        Image(systemName: "arrow.clockwise").font(.system(size: 14)).foregroundColor(theme.accentColor)
                    }
                    .buttonStyle(.plain).help("Refresh all feeds")
                }
            }
            .padding()
            
            ScrollView {
                VStack(spacing: 4) {
                    sidebarButton(icon: "rectangle.stack.fill", iconColor: theme.accentColor, title: "All Episodes", count: nil, isSelected: currentView == .allEpisodes) {
                        currentView = .allEpisodes; selectedPodcastId = nil; selectedEpisodeId = nil; searchText = ""
                        Task { await loadAllEpisodes() }
                    }
                    
                    sidebarButton(icon: "clock.fill", iconColor: .orange, title: "History", count: settings.playbackHistory.count, isSelected: currentView == .history) {
                        currentView = .history; selectedPodcastId = nil; selectedEpisodeId = nil; searchText = ""
                    }
                    
                    sidebarButton(icon: "arrow.down.circle.fill", iconColor: .green, title: "Downloads", count: downloadedEpisodes.count, isSelected: currentView == .downloads) {
                        currentView = .downloads; selectedPodcastId = nil; selectedEpisodeId = nil; searchText = ""
                        Task { await loadDownloadedEpisodesList() }
                    }
                    
                    sidebarButton(icon: "star.fill", iconColor: .yellow, title: "Favorite Podcasts", count: favoritePodcastIds.count, isSelected: currentView == .favoritePodcasts) {
                        currentView = .favoritePodcasts; selectedPodcastId = nil; selectedEpisodeId = nil; searchText = ""
                    }
                    
                    sidebarButton(icon: "heart.fill", iconColor: .pink, title: "Favorite Episodes", count: favoriteEpisodeIds.count, isSelected: currentView == .favoriteEpisodes) {
                        currentView = .favoriteEpisodes; selectedPodcastId = nil; selectedEpisodeId = nil; searchText = ""
                        Task { await loadFavoriteEpisodesList() }
                    }
                    
                    Rectangle().fill(dividerColor).frame(height: 1).padding(.vertical, 8).padding(.horizontal, 12)
                    
                    if !settings.allCategories.isEmpty {
                        Text("Categories").font(.system(size: 11 * scale, weight: .medium)).foregroundColor(secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 12).padding(.bottom, 4)
                        
                        ForEach(settings.allCategories, id: \.self) { category in
                            let count = podcasts.filter { settings.getCategory(for: $0.id) == category }.count
                            sidebarButton(icon: "folder.fill", iconColor: theme.accentColor, title: category, count: count, isSelected: currentView == .category(category)) {
                                currentView = .category(category); selectedPodcastId = nil; selectedEpisodeId = nil; searchText = ""
                            }
                        }
                        
                        Rectangle().fill(dividerColor).frame(height: 1).padding(.vertical, 8).padding(.horizontal, 12)
                    }
                    
                    Text("Podcasts").font(.system(size: 11 * scale, weight: .medium)).foregroundColor(secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 12).padding(.bottom, 4)
                    
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(secondaryText).font(.system(size: 11 * scale))
                        TextField("Search podcasts...", text: $podcastSearchText)
                            .textFieldStyle(.plain).font(.system(size: 12 * scale)).foregroundColor(textColor)
                        if !podcastSearchText.isEmpty {
                            Button { podcastSearchText = "" } label: {
                                Image(systemName: "xmark.circle.fill").foregroundColor(secondaryText).font(.system(size: 11))
                            }.buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 8).padding(.vertical, 5)
                    .background(dividerColor.opacity(0.5))
                    .cornerRadius(5)
                    .padding(.horizontal, 12).padding(.bottom, 6)
                    
                    ForEach(filteredPodcasts, id: \.id) { podcast in
                        podcastRow(podcast: podcast)
                    }
                }
                .padding(.horizontal, 8)
            }
            
            Rectangle().fill(dividerColor).frame(height: 1)
            
            // Add Podcast Button
            Button { showAddSheet = true } label: {
                Label("Add Podcast", systemImage: "plus")
                    .font(.system(size: 14 * scale, weight: .medium))
                    .foregroundColor(theme.buttonText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(theme.buttonBg)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .padding(12)
        }
        .background(sidebarBg)
    }
    
    func podcastRow(podcast: Podcast) -> some View {
        Button {
            currentView = .none; selectedPodcastId = podcast.id; selectedEpisodeId = nil; searchText = ""
            Task { await loadEpisodes(for: podcast) }
        } label: {
            HStack(spacing: 8) {
                if let artworkURL = podcast.artworkURL, let url = URL(string: artworkURL) {
                    AsyncImage(url: url) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "mic.fill").foregroundColor(theme.accentColor)
                    }
                    .frame(width: 28, height: 28)
                    .cornerRadius(4)
                } else {
                    Image(systemName: "mic.fill").foregroundColor(theme.accentColor).font(.system(size: 14 * scale))
                        .frame(width: 28, height: 28)
                }
                
                Text(podcast.title).font(.system(size: 13 * scale)).foregroundColor(textColor).lineLimit(1)
                Spacer()
                if favoritePodcastIds.contains(podcast.id) {
                    Image(systemName: "star.fill").foregroundColor(.yellow).font(.system(size: 10 * scale))
                }
            }
            .padding(.horizontal, 10).padding(.vertical, 6)
            .background(selectedPodcastId == podcast.id && currentView == .none ? theme.accentColor.opacity(0.3) : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button { Task { await refreshFeed(podcast) } } label: { Label("Refresh Feed", systemImage: "arrow.clockwise") }
            Button { toggleFavoritePodcast(podcast) } label: {
                Label(favoritePodcastIds.contains(podcast.id) ? "Remove from Favorites" : "Add to Favorites",
                      systemImage: favoritePodcastIds.contains(podcast.id) ? "star.slash" : "star")
            }
            Divider()
            Button { selectedPodcastForCategory = podcast; newCategoryName = settings.getCategory(for: podcast.id); showCategorySheet = true } label: {
                Label("Set Category...", systemImage: "folder")
            }
            Divider()
            Button(role: .destructive) { Task { await deletePodcast(podcast) } } label: { Label("Delete Podcast", systemImage: "trash") }
        }
    }
    
    func sidebarButton(icon: String, iconColor: Color, title: String, count: Int?, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon).foregroundColor(iconColor).font(.system(size: 14 * scale))
                Text(title).font(.system(size: 14 * scale)).foregroundColor(textColor)
                Spacer()
                if let c = count { Text("\(c)").font(.system(size: 12 * scale)).foregroundColor(secondaryText) }
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(isSelected ? theme.accentColor.opacity(0.3) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
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
            
            if shouldShowEpisodeList {
                HStack(spacing: 8) {
                    Menu {
                        ForEach(EpisodeFilter.allCases, id: \.self) { filter in
                            Button { episodeFilter = filter } label: {
                                if episodeFilter == filter { Text("✓ " + filter.rawValue) }
                                else { Text("    " + filter.rawValue) }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "line.3.horizontal.decrease.circle").font(.system(size: 11))
                            Text(episodeFilter.rawValue).font(.system(size: 11 * scale))
                        }
                        .foregroundColor(episodeFilter == .all ? secondaryText : theme.accentColor)
                    }
                    .menuStyle(.borderlessButton)
                    
                    Menu {
                        ForEach(EpisodeSort.allCases, id: \.self) { sort in
                            Button { episodeSort = sort } label: {
                                if episodeSort == sort { Text("✓ " + sort.rawValue) }
                                else { Text("    " + sort.rawValue) }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.arrow.down").font(.system(size: 11))
                            Text(episodeSort.rawValue).font(.system(size: 11 * scale))
                        }
                        .foregroundColor(secondaryText)
                    }
                    .menuStyle(.borderlessButton)
                    
                    Spacer()
                }
                .padding(.horizontal, 12).padding(.bottom, 6)
                
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(secondaryText).font(.system(size: 12 * scale))
                    TextField("Search episodes...", text: $searchText)
                        .textFieldStyle(.plain).font(.system(size: 13 * scale)).foregroundColor(textColor)
                    if !searchText.isEmpty {
                        Button { searchText = "" } label: {
                            Image(systemName: "xmark.circle.fill").foregroundColor(secondaryText).font(.system(size: 12))
                        }.buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(dividerColor.opacity(0.5))
                .cornerRadius(6)
                .padding(.horizontal, 12).padding(.bottom, 8)
            }
            
            Rectangle().fill(dividerColor).frame(height: 1)
            
            if currentView == .history {
                historyView
            } else if currentView == .favoritePodcasts {
                favoritePodcastsView
            } else if case .category(let cat) = currentView {
                categoryPodcastsView(category: cat)
            } else if shouldShowEpisodeList {
                if filteredAndSortedEpisodes.isEmpty {
                    VStack { Spacer(); Text("No episodes").font(.system(size: 14 * scale)).foregroundColor(secondaryText); Spacer() }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(filteredAndSortedEpisodes.enumerated()), id: \.element.id) { index, episode in
                                VStack(spacing: 0) {
                                    episodeRow(episode: episode)
                                    if index < filteredAndSortedEpisodes.count - 1 {
                                        Rectangle().fill(dividerColor).frame(height: 1).padding(.leading, 12)
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
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
                            currentView = .none; selectedPodcastId = podcast.id
                            Task { await loadEpisodes(for: podcast) }
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
        let categoryPodcasts = podcasts.filter { settings.getCategory(for: $0.id) == category }
        if categoryPodcasts.isEmpty {
            return AnyView(VStack { Spacer(); Text("No podcasts in this category").font(.system(size: 14 * scale)).foregroundColor(secondaryText); Spacer() }
                .frame(maxWidth: .infinity, maxHeight: .infinity))
        }
        return AnyView(ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(categoryPodcasts.enumerated()), id: \.element.id) { index, podcast in
                    VStack(spacing: 0) {
                        Button {
                            currentView = .none; selectedPodcastId = podcast.id
                            Task { await loadEpisodes(for: podcast) }
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
        Button { selectedEpisodeId = episode.id } label: {
            HStack(spacing: 10) {
                if settings.isPlayed(episode.id) {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(secondaryText).font(.system(size: 12 * scale))
                } else if settings.getPosition(for: episode.id) > 0 {
                    Image(systemName: "circle.lefthalf.filled").foregroundColor(theme.accentColor).font(.system(size: 12 * scale))
                }
                
                if currentlyPlayingEpisode?.id == episode.id {
                    Image(systemName: isPlaying ? "speaker.wave.2.fill" : "speaker.fill")
                        .foregroundColor(theme.accentColor).font(.system(size: 12 * scale))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(episode.title)
                        .font(.system(size: 14 * scale, weight: settings.isPlayed(episode.id) ? .regular : .medium))
                        .foregroundColor(settings.isPlayed(episode.id) ? secondaryText : textColor)
                        .lineLimit(2).multilineTextAlignment(.leading)
                    HStack(spacing: 6) {
                        if let date = episode.pubDate {
                            Text(date, style: .date).font(.system(size: 11 * scale)).foregroundColor(secondaryText)
                        }
                        if let dur = episode.duration, dur > 0 {
                            Text("•").foregroundColor(secondaryText).font(.system(size: 11 * scale))
                            Text(formatDuration(dur)).font(.system(size: 11 * scale)).foregroundColor(secondaryText)
                        }
                        if favoriteEpisodeIds.contains(episode.id) {
                            Image(systemName: "heart.fill").foregroundColor(.pink).font(.system(size: 10 * scale))
                        }
                        if downloadedEpisodes.contains(episode.id) && currentView != .downloads {
                            Image(systemName: "arrow.down.circle.fill").foregroundColor(.green).font(.system(size: 10 * scale))
                        }
                        if playQueue.contains(where: { $0.id == episode.id }) {
                            Image(systemName: "list.number").foregroundColor(theme.accentColor).font(.system(size: 10 * scale))
                        }
                        if !settings.getNote(for: episode.id).isEmpty {
                            Image(systemName: "note.text").foregroundColor(.orange).font(.system(size: 10 * scale))
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 12).padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(selectedEpisodeId == episode.id ? theme.accentColor.opacity(0.3) : Color.clear)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button { addToQueue(episode) } label: { Label("Add to Queue", systemImage: "text.badge.plus") }
            Button { playNext(episode) } label: { Label("Play Next", systemImage: "text.insert") }
            Divider()
            if settings.isPlayed(episode.id) {
                Button { settings.markAsUnplayed(episode.id) } label: { Label("Mark as Unplayed", systemImage: "circle") }
            } else {
                Button { settings.markAsPlayed(episode.id) } label: { Label("Mark as Played", systemImage: "checkmark.circle") }
            }
            Divider()
            Button { toggleFavoriteEpisode(episode) } label: {
                Label(favoriteEpisodeIds.contains(episode.id) ? "Remove from Favorites" : "Add to Favorites",
                      systemImage: favoriteEpisodeIds.contains(episode.id) ? "heart.slash" : "heart")
            }
            Button { selectedEpisodeId = episode.id; currentNote = settings.getNote(for: episode.id); showNoteEditor = true } label: {
                Label("Edit Note...", systemImage: "note.text")
            }
            if currentView == .downloads {
                Button { showInFinder(episode) } label: { Label("Show in Finder", systemImage: "folder") }
            }
        }
    }
    
    // MARK: - Detail View
    var detailView: some View {
        VStack {
            if let episode = selectedEpisode {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        if let podcast = podcasts.first(where: { $0.id == episode.podcastId }),
                           let artworkURL = podcast.artworkURL, let url = URL(string: artworkURL) {
                            HStack {
                                AsyncImage(url: url) { image in
                                    image.resizable().aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Rectangle().fill(dividerColor)
                                }
                                .frame(width: 100, height: 100)
                                .cornerRadius(8)
                                Spacer()
                            }
                        }
                        
                        Text(episode.title)
                            .font(.system(size: 22 * scale, weight: .bold))
                            .foregroundColor(textColor)
                            .textSelection(.enabled)
                        
                        HStack(spacing: 12) {
                            if let date = episode.pubDate {
                                Text(date, style: .date).font(.system(size: 13 * scale)).foregroundColor(secondaryText)
                            }
                            if let dur = episode.duration, dur > 0 {
                                Text("•").foregroundColor(secondaryText)
                                Text(formatDuration(dur)).font(.system(size: 13 * scale)).foregroundColor(secondaryText)
                            }
                            if settings.isPlayed(episode.id) {
                                Text("•").foregroundColor(secondaryText)
                                Text("Played").font(.system(size: 13 * scale)).foregroundColor(secondaryText)
                            } else if settings.getPosition(for: episode.id) > 0 {
                                Text("•").foregroundColor(secondaryText)
                                Text("\(formatTime(settings.getPosition(for: episode.id))) in").font(.system(size: 13 * scale)).foregroundColor(theme.accentColor)
                            }
                        }
                        
                        HStack(spacing: 8) {
                            Button {
                                if currentlyPlayingEpisode?.id == episode.id { togglePlayPause() }
                                else {
                                    let podcastTitle = podcasts.first { $0.id == episode.podcastId }?.title ?? ""
                                    playEpisode(episode, podcastTitle: podcastTitle)
                                }
                            } label: {
                                Label(currentlyPlayingEpisode?.id == episode.id && isPlaying ? "Pause" : (settings.getPosition(for: episode.id) > 0 ? "Resume" : "Play"),
                                      systemImage: currentlyPlayingEpisode?.id == episode.id && isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 13 * scale, weight: .medium))
                                    .foregroundColor(theme.buttonText)
                                    .padding(.horizontal, 12).padding(.vertical, 6)
                                    .background(theme.buttonBg)
                                    .cornerRadius(6)
                            }.buttonStyle(.plain)
                            
                            Button { addToQueue(episode) } label: {
                                Label("Queue", systemImage: "text.badge.plus")
                                    .font(.system(size: 13 * scale, weight: .medium))
                                    .foregroundColor(playQueue.contains { $0.id == episode.id } ? .white : textColor)
                                    .padding(.horizontal, 12).padding(.vertical, 6)
                                    .background(playQueue.contains { $0.id == episode.id } ? theme.accentColor : dividerColor.opacity(0.5))
                                    .cornerRadius(6)
                            }.buttonStyle(.plain)
                            
                            Button { toggleFavoriteEpisode(episode) } label: {
                                Image(systemName: favoriteEpisodeIds.contains(episode.id) ? "heart.fill" : "heart")
                                    .font(.system(size: 14 * scale))
                                    .foregroundColor(favoriteEpisodeIds.contains(episode.id) ? .pink : textColor)
                                    .padding(6)
                                    .background(dividerColor.opacity(0.5))
                                    .cornerRadius(6)
                            }.buttonStyle(.plain)
                            
                            if downloadedEpisodes.contains(episode.id) {
                                Menu {
                                    Button { showInFinder(episode) } label: { Label("Show in Finder", systemImage: "folder") }
                                    Button(role: .destructive) { deleteDownload(episode) } label: { Label("Delete", systemImage: "trash") }
                                } label: {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 14 * scale))
                                        .foregroundColor(.green)
                                        .padding(6)
                                        .background(dividerColor.opacity(0.5))
                                        .cornerRadius(6)
                                }
                            } else if downloadingEpisodes.contains(episode.id) {
                                ProgressView().scaleEffect(0.7)
                            } else {
                                Button { Task { await downloadEpisode(episode) } } label: {
                                    Image(systemName: "arrow.down.circle")
                                        .font(.system(size: 14 * scale))
                                        .foregroundColor(textColor)
                                        .padding(6)
                                        .background(dividerColor.opacity(0.5))
                                        .cornerRadius(6)
                                }.buttonStyle(.plain)
                            }
                        }
                        
                        let note = settings.getNote(for: episode.id)
                        if !note.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Image(systemName: "note.text").foregroundColor(.orange).font(.system(size: 12))
                                    Text("Note").font(.system(size: 13 * scale, weight: .medium)).foregroundColor(textColor)
                                    Spacer()
                                    Button { currentNote = note; showNoteEditor = true } label: {
                                        Text("Edit").font(.system(size: 11 * scale)).foregroundColor(theme.accentColor)
                                    }.buttonStyle(.plain)
                                }
                                Text(note)
                                    .font(.system(size: 13 * scale))
                                    .foregroundColor(secondaryText)
                                    .padding(10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(dividerColor.opacity(0.3))
                                    .cornerRadius(6)
                            }
                        } else {
                            Button { currentNote = ""; showNoteEditor = true } label: {
                                Label("Add Note", systemImage: "note.text.badge.plus")
                                    .font(.system(size: 12 * scale))
                                    .foregroundColor(secondaryText)
                            }.buttonStyle(.plain)
                        }
                        
                        Rectangle().fill(dividerColor).frame(height: 1).padding(.vertical, 4)
                        
                        if let description = episode.episodeDescription {
                            Text("Description").font(.system(size: 14 * scale, weight: .semibold)).foregroundColor(textColor)
                            Text(stripHTML(description))
                                .font(.system(size: 13 * scale))
                                .foregroundColor(textColor)
                                .textSelection(.enabled)
                                .lineSpacing(4)
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "radio").font(.system(size: 50)).foregroundColor(theme.accentColor.opacity(0.6))
                    Text("Welcome to PodVault").font(.system(size: 24 * scale, weight: .bold)).foregroundColor(textColor)
                    Text("Select a podcast and episode").font(.system(size: 14 * scale)).foregroundColor(secondaryText)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(detailBg)
    }
    
    // MARK: - Queue View
    var queueView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "list.number").foregroundColor(theme.accentColor).font(.system(size: 14 * scale))
                Text("Up Next").font(.system(size: 14 * scale, weight: .semibold)).foregroundColor(textColor)
                Spacer()
                if !playQueue.isEmpty {
                    Button { playQueue.removeAll() } label: {
                        Text("Clear").font(.system(size: 12 * scale)).foregroundColor(theme.accentColor)
                    }.buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            
            Rectangle().fill(dividerColor).frame(height: 1)
            
            if playQueue.isEmpty {
                VStack {
                    Spacer()
                    Text("Queue is empty").font(.system(size: 13 * scale)).foregroundColor(secondaryText)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(playQueue.enumerated()), id: \.element.id) { index, episode in
                            VStack(spacing: 0) {
                                HStack(spacing: 10) {
                                    Text("\(index + 1)").font(.system(size: 12 * scale, weight: .medium)).foregroundColor(secondaryText).frame(width: 20)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(episode.title).font(.system(size: 13 * scale, weight: .medium)).foregroundColor(textColor).lineLimit(1)
                                        if let dur = episode.duration, dur > 0 {
                                            Text(formatDuration(dur)).font(.system(size: 11 * scale)).foregroundColor(secondaryText)
                                        }
                                    }
                                    Spacer()
                                    Button { playQueue.remove(at: index) } label: {
                                        Image(systemName: "xmark.circle.fill").font(.system(size: 14)).foregroundColor(secondaryText)
                                    }.buttonStyle(.plain)
                                }
                                .padding(.horizontal, 16).padding(.vertical, 8)
                                .contentShape(Rectangle())
                                .onTapGesture { playFromQueue(at: index) }
                                
                                if index < playQueue.count - 1 {
                                    Rectangle().fill(dividerColor).frame(height: 1).padding(.leading, 46)
                                }
                            }
                        }
                    }
                }
            }
        }
        .frame(height: 180)
        .background(queueBg)
    }
    
    // MARK: - Now Playing Bar
    func nowPlayingBar(episode: Episode) -> some View {
        VStack(spacing: 0) {
            Rectangle().fill(theme.accentColor).frame(height: 2)
            HStack(spacing: 14) {
                Button { skipBackward() } label: { Image(systemName: "gobackward.15").font(.system(size: 18 * scale)) }
                    .buttonStyle(.plain).foregroundColor(theme.accentColor)
                
                Button { togglePlayPause() } label: { Image(systemName: isPlaying ? "pause.fill" : "play.fill").font(.system(size: 22 * scale)) }
                    .buttonStyle(.plain).foregroundColor(theme.accentColor)
                
                Button { skipForward() } label: { Image(systemName: "goforward.30").font(.system(size: 18 * scale)) }
                    .buttonStyle(.plain).foregroundColor(theme.accentColor)
                
                Button { playNextEpisode() } label: { Image(systemName: "forward.end.fill").font(.system(size: 16 * scale)) }
                    .buttonStyle(.plain).foregroundColor(hasNextEpisode ? theme.accentColor : secondaryText.opacity(0.5))
                    .disabled(!hasNextEpisode)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(episode.title).font(.system(size: 14 * scale, weight: .semibold)).foregroundColor(textColor).lineLimit(1)
                    Text("\(formatTime(currentTime)) / \(formatTime(duration))").font(.system(size: 11 * scale)).foregroundColor(secondaryText)
                }
                
                Spacer()
                
                if settings.volumeBoost != 1.0 {
                    Text("\(Int(settings.volumeBoost * 100))%")
                        .font(.system(size: 10 * scale))
                        .foregroundColor(secondaryText)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(dividerColor.opacity(0.5))
                        .cornerRadius(4)
                }
                
                Slider(value: $currentTime, in: 0...max(duration, 1)) { editing in if !editing { seek(to: currentTime) } }
                    .frame(width: 160).tint(theme.accentColor)
                
                Menu {
                    ForEach(playbackSpeeds, id: \.self) { speed in
                        Button { setPlaybackSpeed(speed) } label: {
                            if settings.playbackSpeed == speed { Text("✓ \(formatSpeed(speed))") }
                            else { Text("    \(formatSpeed(speed))") }
                        }
                    }
                } label: {
                    Text(formatSpeed(settings.playbackSpeed))
                        .font(.system(size: 12 * scale, weight: .medium))
                        .foregroundColor(theme.buttonText)
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(theme.buttonBg)
                        .cornerRadius(6)
                }
                .menuStyle(.borderlessButton).frame(width: 60)
                
                Button { stopPlayback() } label: { Image(systemName: "xmark.circle.fill").font(.system(size: 20 * scale)) }
                    .buttonStyle(.plain).foregroundColor(secondaryText)
            }
            .padding(.horizontal, 20).padding(.vertical, 12)
            .background(sidebarBg)
        }
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
        let podcastTitle = podcasts.first { $0.id == episode.podcastId }?.title ?? ""
        playEpisode(episode, podcastTitle: podcastTitle)
    }
    
    func playNextInQueue() {
        guard !playQueue.isEmpty else { return }
        let episode = playQueue.removeFirst()
        let podcastTitle = podcasts.first { $0.id == episode.podcastId }?.title ?? ""
        playEpisode(episode, podcastTitle: podcastTitle)
    }
    
    // MARK: - Playback
    
    func playEpisode(_ episode: Episode, podcastTitle: String) {
        let localFile = localFileURL(for: episode)
        let playURL: URL? = FileManager.default.fileExists(atPath: localFile.path) ? localFile :
            episode.audioURL.flatMap { URL(string: $0) }
        guard let url = playURL else { return }
        
        if let current = currentlyPlayingEpisode, currentTime > 10 {
            settings.savePosition(for: current.id, position: currentTime)
            let listened = currentTime - settings.getPosition(for: current.id)
            if listened > 60 { settings.addListeningTime(listened) }
        }
        
        if let observer = playbackEndObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        stopPlaybackWithoutSaving()
        player = AVPlayer(playerItem: AVPlayerItem(url: url))
        currentlyPlayingEpisode = episode
        currentPodcastTitle = podcastTitle
        
        player?.volume = settings.volumeBoost
        
        let savedPosition = settings.getPosition(for: episode.id)
        if savedPosition > 0 {
            player?.seek(to: CMTime(seconds: savedPosition, preferredTimescale: 600))
        }
        
        player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { time in
            currentTime = time.seconds
            if let dur = player?.currentItem?.duration.seconds, dur.isFinite {
                duration = dur
                if currentTime > dur - 30 && dur > 60 {
                    settings.markAsPlayed(episode.id)
                }
            }
            
            if Date().timeIntervalSince(lastPositionSaveTime) > 30 {
                settings.savePosition(for: episode.id, position: currentTime)
                lastPositionSaveTime = Date()
            }
        }
        
        playbackEndObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            settings.markAsPlayed(episode.id)
            settings.addToHistory(episode, podcastTitle: podcastTitle)
            settings.addListeningTime(duration)
            
            if !playQueue.isEmpty {
                playNextInQueue()
            } else if settings.continuousPlayback {
                playNextEpisodeInFeed()
            } else {
                stopPlayback()
            }
        }
        
        player?.play()
        player?.rate = settings.playbackSpeed
        isPlaying = true
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
        let feedEpisodes = episodes.sorted { ($0.pubDate ?? .distantPast) > ($1.pubDate ?? .distantPast) }
        if let index = feedEpisodes.firstIndex(where: { $0.id == current.id }), index + 1 < feedEpisodes.count {
            let next = feedEpisodes[index + 1]
            let podcastTitle = podcasts.first { $0.id == next.podcastId }?.title ?? ""
            playEpisode(next, podcastTitle: podcastTitle)
        } else {
            stopPlayback()
        }
    }
    
    func togglePlayPause() {
        guard let player = player else { return }
        if isPlaying {
            player.pause()
            if let episode = currentlyPlayingEpisode {
                settings.savePosition(for: episode.id, position: currentTime)
            }
        } else {
            player.play()
            player.rate = settings.playbackSpeed
        }
        isPlaying.toggle()
    }
    
    func stopPlaybackWithoutSaving() {
        player?.pause()
        player = nil
        isPlaying = false
        currentlyPlayingEpisode = nil
        currentTime = 0
        duration = 0
    }
    
    func stopPlayback() {
        if let episode = currentlyPlayingEpisode, currentTime > 10 {
            settings.savePosition(for: episode.id, position: currentTime)
        }
        stopPlaybackWithoutSaving()
    }
    
    func seek(to time: Double) { player?.seek(to: CMTime(seconds: time, preferredTimescale: 600)) }
    func skipForward() { let t = min(currentTime + 30, duration); seek(to: t); currentTime = t }
    func skipBackward() { let t = max(currentTime - 15, 0); seek(to: t); currentTime = t }
    
    func setPlaybackSpeed(_ speed: Float) {
        settings.playbackSpeed = speed
        settings.save()
        if isPlaying { player?.rate = speed }
    }
    
    func adjustVolume(by delta: Float) {
        settings.volumeBoost = max(0.5, min(2.0, settings.volumeBoost + delta))
        player?.volume = settings.volumeBoost
        settings.save()
    }
    
    // MARK: - Data Operations
    
    func loadPodcasts() async {
        do {
            let loaded = try await PodcastRepository().getAllPodcasts()
            await MainActor.run { podcasts = loaded }
        } catch { print("Error: \(error)") }
    }
    
    func loadEpisodes(for podcast: Podcast) async {
        do {
            let loaded = try await PodcastRepository().getEpisodes(forPodcast: podcast.id)
            await MainActor.run { episodes = loaded }
        } catch { print("Error: \(error)") }
    }
    
    func loadAllEpisodes() async {
        do {
            let repo = PodcastRepository()
            var all: [Episode] = []
            for podcast in podcasts {
                let eps = try await repo.getEpisodes(forPodcast: podcast.id)
                all.append(contentsOf: eps)
            }
            all.sort { ($0.pubDate ?? .distantPast) > ($1.pubDate ?? .distantPast) }
            await MainActor.run { allEpisodes = all }
        } catch { print("Error: \(error)") }
    }
    
    func loadDownloadedEpisodesList() async {
        do {
            let repo = PodcastRepository()
            var downloaded: [Episode] = []
            for id in downloadedEpisodes {
                if let ep = try await repo.getEpisode(id: id) { downloaded.append(ep) }
            }
            downloaded.sort { ($0.pubDate ?? .distantPast) > ($1.pubDate ?? .distantPast) }
            await MainActor.run { downloadedEpisodesList = downloaded }
        } catch { print("Error: \(error)") }
    }
    
    func loadFavoriteEpisodesList() async {
        do {
            let repo = PodcastRepository()
            var favorites: [Episode] = []
            for id in favoriteEpisodeIds {
                if let ep = try await repo.getEpisode(id: id) { favorites.append(ep) }
            }
            favorites.sort { ($0.pubDate ?? .distantPast) > ($1.pubDate ?? .distantPast) }
            await MainActor.run { favoriteEpisodesList = favorites }
        } catch { print("Error: \(error)") }
    }
    
    func addPodcast(url: String) async {
        await MainActor.run { isLoading = true; errorMessage = nil }
        do {
            let result = try await FeedService().fetchFeed(url: url)
            let repo = PodcastRepository()
            try await repo.savePodcast(result.podcast)
            try await repo.saveEpisodes(result.episodes)
            await loadPodcasts()
            await MainActor.run { isLoading = false; showAddSheet = false; feedURL = "" }
        } catch {
            await MainActor.run { isLoading = false; errorMessage = "Failed: \(error.localizedDescription)" }
        }
    }
    
    func deletePodcast(_ podcast: Podcast) async {
        do {
            try await PodcastRepository().deletePodcast(id: podcast.id)
            await loadPodcasts()
            favoritePodcastIds.remove(podcast.id)
            saveFavorites()
            settings.podcastCategories.removeValue(forKey: podcast.id)
            settings.save()
            if selectedPodcastId == podcast.id { selectedPodcastId = nil }
        } catch { print("Error: \(error)") }
    }
    
    func refreshFeed(_ podcast: Podcast) async {
        do {
            let result = try await FeedService().fetchFeed(url: podcast.feedURL)
            let repo = PodcastRepository()
            try await repo.saveEpisodes(result.episodes)
            if selectedPodcastId == podcast.id { await loadEpisodes(for: podcast) }
            if currentView == .allEpisodes { await loadAllEpisodes() }
        } catch { print("Error: \(error)") }
    }
    
    func refreshAllFeeds() async {
        await MainActor.run { isRefreshing = true }
        for podcast in podcasts { await refreshFeed(podcast) }
        await MainActor.run { isRefreshing = false }
    }
    
    // MARK: - Favorites
    
    var favoritesURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let podvault = appSupport.appendingPathComponent("PodVault", isDirectory: true)
        try? FileManager.default.createDirectory(at: podvault, withIntermediateDirectories: true)
        return podvault.appendingPathComponent("favorites.json")
    }
    
    func loadFavorites() {
        if let data = try? Data(contentsOf: favoritesURL),
           let fav = try? JSONDecoder().decode(FavoritesData.self, from: data) {
            favoritePodcastIds = Set(fav.podcastIds)
            favoriteEpisodeIds = Set(fav.episodeIds)
        }
    }
    
    func saveFavorites() {
        let data = FavoritesData(podcastIds: Array(favoritePodcastIds), episodeIds: Array(favoriteEpisodeIds))
        if let encoded = try? JSONEncoder().encode(data) { try? encoded.write(to: favoritesURL) }
    }
    
    func toggleFavoritePodcast(_ podcast: Podcast) {
        if favoritePodcastIds.contains(podcast.id) { favoritePodcastIds.remove(podcast.id) }
        else { favoritePodcastIds.insert(podcast.id) }
        saveFavorites()
    }
    
    func toggleFavoriteEpisode(_ episode: Episode) {
        if favoriteEpisodeIds.contains(episode.id) {
            favoriteEpisodeIds.remove(episode.id)
            if currentView == .favoriteEpisodes { favoriteEpisodesList.removeAll { $0.id == episode.id } }
        } else { favoriteEpisodeIds.insert(episode.id) }
        saveFavorites()
    }
    
    // MARK: - Downloads
    
    var downloadsDirectory: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let downloads = appSupport.appendingPathComponent("PodVault/Downloads", isDirectory: true)
        try? FileManager.default.createDirectory(at: downloads, withIntermediateDirectories: true)
        return downloads
    }
    
    func localFileURL(for episode: Episode) -> URL {
        downloadsDirectory.appendingPathComponent("\(episode.id).mp3")
    }
    
    func loadDownloadedEpisodes() {
        if let files = try? FileManager.default.contentsOfDirectory(at: downloadsDirectory, includingPropertiesForKeys: nil) {
            downloadedEpisodes = Set(files.map { $0.deletingPathExtension().lastPathComponent })
        }
    }
    
    func downloadEpisode(_ episode: Episode) async {
        guard let urlString = episode.audioURL, let url = URL(string: urlString) else { return }
        await MainActor.run { _ = downloadingEpisodes.insert(episode.id) }
        do {
            let (tempURL, _) = try await URLSession.shared.download(from: url)
            let dest = localFileURL(for: episode)
            try? FileManager.default.removeItem(at: dest)
            try FileManager.default.moveItem(at: tempURL, to: dest)
            await MainActor.run { _ = downloadingEpisodes.remove(episode.id); _ = downloadedEpisodes.insert(episode.id) }
        } catch {
            await MainActor.run { _ = downloadingEpisodes.remove(episode.id) }
        }
    }
    
    func deleteDownload(_ episode: Episode) {
        try? FileManager.default.removeItem(at: localFileURL(for: episode))
        downloadedEpisodes.remove(episode.id)
        if currentView == .downloads { downloadedEpisodesList.removeAll { $0.id == episode.id } }
    }
    
    func showInFinder(_ episode: Episode) {
        NSWorkspace.shared.selectFile(localFileURL(for: episode).path, inFileViewerRootedAtPath: downloadsDirectory.path)
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
            for podcast in podcasts {
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

// MARK: - Mini Player View

struct MiniPlayerView: View {
    let episode: Episode?
    let isPlaying: Bool
    let currentTime: Double
    let duration: Double
    let theme: AppTheme
    let hasNext: Bool
    let onPlayPause: () -> Void
    let onSkipBack: () -> Void
    let onSkipForward: () -> Void
    let onNext: () -> Void
    let onClose: () -> Void
    @EnvironmentObject var settings: AppSettings
    
    var body: some View {
        VStack(spacing: 8) {
            if let episode = episode {
                Text(episode.title)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 16) {
                    Button(action: onSkipBack) {
                        Image(systemName: "gobackward.15").font(.system(size: 14))
                    }.buttonStyle(.plain)
                    
                    Button(action: onPlayPause) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill").font(.system(size: 22))
                    }.buttonStyle(.plain)
                    
                    Button(action: onSkipForward) {
                        Image(systemName: "goforward.30").font(.system(size: 14))
                    }.buttonStyle(.plain)
                    
                    Button(action: onNext) {
                        Image(systemName: "forward.end.fill").font(.system(size: 14))
                    }
                    .buttonStyle(.plain)
                    .disabled(!hasNext)
                    .opacity(hasNext ? 1 : 0.4)
                }
                .foregroundColor(theme.accentColor)
                
                Text("\(formatTime(currentTime)) / \(formatTime(duration))")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            } else {
                Text("Nothing playing")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 300, height: 110)
        .background(theme.sidebarBgFixed)
    }
    
    func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite else { return "0:00" }
        let m = (Int(seconds) % 3600) / 60
        let s = Int(seconds) % 60
        return String(format: "%d:%02d", m, s)
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
