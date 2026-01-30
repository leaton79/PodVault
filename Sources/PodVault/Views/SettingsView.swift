import SwiftUI

/// Main settings/preferences view
struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            SyncSettingsView()
                .tabItem {
                    Label("Sync", systemImage: "arrow.triangle.2.circlepath")
                }
            
            PlaybackSettingsView()
                .tabItem {
                    Label("Playback", systemImage: "play.circle")
                }
            
            DownloadsSettingsView()
                .tabItem {
                    Label("Downloads", systemImage: "arrow.down.circle")
                }
            
            StorageSettingsView()
                .tabItem {
                    Label("Storage", systemImage: "internaldrive")
                }
            
            KeyboardShortcutsView()
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }
        }
        .frame(width: 550, height: 400)
    }
}

// MARK: - General Settings

struct GeneralSettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("showInMenuBar") private var showInMenuBar = true
    @AppStorage("showDockIcon") private var showDockIcon = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("notifyOnNewEpisodes") private var notifyOnNewEpisodes = true
    @AppStorage("notifyOnDownloadComplete") private var notifyOnDownloadComplete = true
    
    var body: some View {
        Form {
            Section {
                Toggle("Launch at login", isOn: $launchAtLogin)
                Toggle("Show in menu bar", isOn: $showInMenuBar)
                Toggle("Show Dock icon", isOn: $showDockIcon)
            } header: {
                Text("App Behavior")
            }
            
            Section {
                Toggle("Enable notifications", isOn: $notificationsEnabled)
                
                if notificationsEnabled {
                    Toggle("Notify when new episodes arrive", isOn: $notifyOnNewEpisodes)
                        .padding(.leading, 20)
                    Toggle("Notify when downloads complete", isOn: $notifyOnDownloadComplete)
                        .padding(.leading, 20)
                }
            } header: {
                Text("Notifications")
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Sync Settings

struct SyncSettingsView: View {
    @AppStorage("syncInterval") private var syncInterval: Int = 60
    @AppStorage("syncOnLaunch") private var syncOnLaunch = true
    @AppStorage("syncInBackground") private var syncInBackground = true
    
    let syncIntervalOptions = [
        (15, "Every 15 minutes"),
        (30, "Every 30 minutes"),
        (60, "Every hour"),
        (120, "Every 2 hours"),
        (360, "Every 6 hours"),
        (1440, "Once a day"),
        (0, "Manual only")
    ]
    
    var body: some View {
        Form {
            Section {
                Picker("Sync interval", selection: $syncInterval) {
                    ForEach(syncIntervalOptions, id: \.0) { option in
                        Text(option.1).tag(option.0)
                    }
                }
                
                Toggle("Sync on app launch", isOn: $syncOnLaunch)
                Toggle("Sync in background", isOn: $syncInBackground)
            } header: {
                Text("Automatic Sync")
            }
            
            Section {
                Text("Last sync: \(formattedLastSync)")
                    .foregroundStyle(.secondary)
                
                Button("Sync Now") {
                    Task {
                        await SyncScheduler.shared.syncNow()
                    }
                }
            } header: {
                Text("Manual Sync")
            }
        }
        .formStyle(.grouped)
        .padding()
    }
    
    var formattedLastSync: String {
        if let lastSync = SyncScheduler.shared.lastSyncTime {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .abbreviated
            return formatter.localizedString(for: lastSync, relativeTo: Date())
        }
        return "Never"
    }
}

// MARK: - Playback Settings

struct PlaybackSettingsView: View {
    @AppStorage("defaultPlaybackSpeed") private var defaultPlaybackSpeed: Double = 1.0
    @AppStorage("skipForwardInterval") private var skipForwardInterval: Int = 30
    @AppStorage("skipBackInterval") private var skipBackInterval: Int = 15
    @AppStorage("rememberPlaybackPosition") private var rememberPlaybackPosition = true
    @AppStorage("markPlayedWhenFinished") private var markPlayedWhenFinished = true
    @AppStorage("autoPlayNext") private var autoPlayNext = false
    
    let speedOptions: [Double] = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
    let skipOptions = [5, 10, 15, 30, 45, 60]
    
    var body: some View {
        Form {
            Section {
                Picker("Default speed", selection: $defaultPlaybackSpeed) {
                    ForEach(speedOptions, id: \.self) { speed in
                        Text("\(speed, specifier: "%.2f")×").tag(speed)
                    }
                }
                
                Picker("Skip forward", selection: $skipForwardInterval) {
                    ForEach(skipOptions, id: \.self) { seconds in
                        Text("\(seconds) seconds").tag(seconds)
                    }
                }
                
                Picker("Skip back", selection: $skipBackInterval) {
                    ForEach(skipOptions, id: \.self) { seconds in
                        Text("\(seconds) seconds").tag(seconds)
                    }
                }
            } header: {
                Text("Controls")
            }
            
            Section {
                Toggle("Remember playback position", isOn: $rememberPlaybackPosition)
                Toggle("Mark as played when finished", isOn: $markPlayedWhenFinished)
                Toggle("Auto-play next episode", isOn: $autoPlayNext)
            } header: {
                Text("Behavior")
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Downloads Settings

struct DownloadsSettingsView: View {
    @AppStorage("maxConcurrentDownloads") private var maxConcurrentDownloads: Int = 3
    @AppStorage("autoDownloadNewEpisodes") private var autoDownloadNewEpisodes = false
    @AppStorage("deleteDownloadsAfterPlaying") private var deleteDownloadsAfterPlaying = false
    @AppStorage("downloadOverCellular") private var downloadOverCellular = true
    
    let concurrentOptions = [1, 2, 3, 5, 10]
    
    var body: some View {
        Form {
            Section {
                Picker("Concurrent downloads", selection: $maxConcurrentDownloads) {
                    ForEach(concurrentOptions, id: \.self) { count in
                        Text("\(count)").tag(count)
                    }
                }
                
                Toggle("Auto-download new episodes", isOn: $autoDownloadNewEpisodes)
                Toggle("Delete downloads after playing", isOn: $deleteDownloadsAfterPlaying)
            } header: {
                Text("Download Behavior")
            }
            
            Section {
                HStack {
                    Text("Downloads folder")
                    Spacer()
                    Text(downloadsPath)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    
                    Button("Show") {
                        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: DatabaseManager.downloadsDirectory.path)
                    }
                }
            } header: {
                Text("Location")
            }
        }
        .formStyle(.grouped)
        .padding()
    }
    
    var downloadsPath: String {
        DatabaseManager.downloadsDirectory.path.replacingOccurrences(
            of: FileManager.default.homeDirectoryForCurrentUser.path,
            with: "~"
        )
    }
}

// MARK: - Storage Settings

struct StorageSettingsView: View {
    @State private var downloadsSize: String = "Calculating..."
    @State private var savedLibrarySize: String = "Calculating..."
    @State private var databaseSize: String = "Calculating..."
    @State private var showingClearConfirmation = false
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Downloads")
                    Spacer()
                    Text(downloadsSize)
                        .foregroundStyle(.secondary)
                    Button("Clear") {
                        showingClearConfirmation = true
                    }
                    .buttonStyle(.bordered)
                }
                
                HStack {
                    Text("Saved Library")
                    Spacer()
                    Text(savedLibrarySize)
                        .foregroundStyle(.secondary)
                    Button("Open") {
                        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: DatabaseManager.savedLibraryDirectory.path)
                    }
                    .buttonStyle(.bordered)
                }
                
                HStack {
                    Text("Database")
                    Spacer()
                    Text(databaseSize)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Storage Usage")
            }
            
            Section {
                Button("Prune Activity Log (keep 90 days)") {
                    Task {
                        let repo = PodcastRepository()
                        try? await repo.pruneOldActivity(olderThan: 90)
                    }
                }
            } header: {
                Text("Maintenance")
            }
        }
        .formStyle(.grouped)
        .padding()
        .onAppear {
            calculateStorageUsage()
        }
        .alert("Clear Downloads", isPresented: $showingClearConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearDownloads()
            }
        } message: {
            Text("This will delete all downloaded episode files. Episodes will need to be re-downloaded to play offline.")
        }
    }
    
    private func calculateStorageUsage() {
        Task {
            downloadsSize = await calculateFolderSize(DatabaseManager.downloadsDirectory)
            savedLibrarySize = await calculateFolderSize(DatabaseManager.savedLibraryDirectory)
            databaseSize = calculateFileSize(DatabaseManager.appSupportDirectory.appendingPathComponent("podvault.sqlite"))
        }
    }
    
    private func calculateFolderSize(_ url: URL) async -> String {
        let fileManager = FileManager.default
        var totalSize: Int64 = 0
        
        if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in enumerator {
                if let size = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    totalSize += Int64(size)
                }
            }
        }
        
        return ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }
    
    private func calculateFileSize(_ url: URL) -> String {
        let fileManager = FileManager.default
        if let attributes = try? fileManager.attributesOfItem(atPath: url.path),
           let size = attributes[.size] as? Int64 {
            return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
        }
        return "Unknown"
    }
    
    private func clearDownloads() {
        let fileManager = FileManager.default
        let downloadsURL = DatabaseManager.downloadsDirectory
        
        if let contents = try? fileManager.contentsOfDirectory(at: downloadsURL, includingPropertiesForKeys: nil) {
            for file in contents {
                try? fileManager.removeItem(at: file)
            }
        }
        
        calculateStorageUsage()
    }
}

// MARK: - Keyboard Shortcuts

struct KeyboardShortcutsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ShortcutSection(title: "Playback", shortcuts: [
                    ("Space", "Play / Pause"),
                    ("⌘.", "Stop"),
                    ("⌘→", "Skip Forward"),
                    ("⌘←", "Skip Back"),
                    ("⌘+", "Cycle Speed")
                ])
                
                ShortcutSection(title: "Navigation", shortcuts: [
                    ("⌘1", "Show Library"),
                    ("⌘F", "Search"),
                    ("⇧⌘L", "Show Activity Log")
                ])
                
                ShortcutSection(title: "Podcasts", shortcuts: [
                    ("⌘N", "Add Feed"),
                    ("⌘R", "Sync All Feeds"),
                    ("⇧⌘I", "Import OPML"),
                    ("⇧⌘E", "Export OPML"),
                    ("⌥⌘E", "Export Library")
                ])
                
                ShortcutSection(title: "Window", shortcuts: [
                    ("⌘,", "Settings"),
                    ("⌘W", "Close Window"),
                    ("⌘Q", "Quit")
                ])
            }
            .padding()
        }
    }
}

struct ShortcutSection: View {
    let title: String
    let shortcuts: [(String, String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            ForEach(shortcuts, id: \.0) { shortcut in
                HStack {
                    Text(shortcut.0)
                        .font(.system(.body, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.quaternary)
                        .cornerRadius(4)
                        .frame(width: 80, alignment: .center)
                    
                    Text(shortcut.1)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
            }
        }
    }
}

