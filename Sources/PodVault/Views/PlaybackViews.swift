import SwiftUI

struct SidebarButtonView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let count: Int?
    let isSelected: Bool
    let scale: CGFloat
    let textColor: Color
    let secondaryText: Color
    let selectionColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 14 * scale))
                Text(title)
                    .font(.system(size: 14 * scale))
                    .foregroundColor(textColor)
                Spacer()
                if let count {
                    Text("\(count)")
                        .font(.system(size: 12 * scale))
                        .foregroundColor(secondaryText)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? selectionColor : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct PodcastSidebarRowView: View {
    let podcast: Podcast
    let isSelected: Bool
    let isFavorite: Bool
    let scale: CGFloat
    let accentColor: Color
    let textColor: Color
    let selectionColor: Color
    let onSelect: () -> Void
    let onRefresh: () -> Void
    let onToggleFavorite: () -> Void
    let onSetCategory: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 8) {
                if let artworkURL = podcast.artworkURL, let url = URL(string: artworkURL) {
                    AsyncImage(url: url) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "mic.fill").foregroundColor(accentColor)
                    }
                    .frame(width: 28, height: 28)
                    .cornerRadius(4)
                } else {
                    Image(systemName: "mic.fill")
                        .foregroundColor(accentColor)
                        .font(.system(size: 14 * scale))
                        .frame(width: 28, height: 28)
                }
                
                Text(podcast.title)
                    .font(.system(size: 13 * scale))
                    .foregroundColor(textColor)
                    .lineLimit(1)
                Spacer()
                if isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 10 * scale))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? selectionColor : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(action: onRefresh) {
                Label("Refresh Feed", systemImage: "arrow.clockwise")
            }
            Button(action: onToggleFavorite) {
                Label(isFavorite ? "Remove from Favorites" : "Add to Favorites",
                      systemImage: isFavorite ? "star.slash" : "star")
            }
            Divider()
            Button(action: onSetCategory) {
                Label("Set Category...", systemImage: "folder")
            }
            Divider()
            Button(role: .destructive, action: onDelete) {
                Label("Delete Podcast", systemImage: "trash")
            }
        }
    }
}

struct LibrarySidebarView: View {
    @Binding var podcastSearchText: String
    let isRefreshing: Bool
    let syncSummaryTitle: String?
    let syncSummarySubtitle: String?
    let syncSummaryFailures: [String]
    let continueListeningCount: Int
    let historyCount: Int
    let downloadedCount: Int
    let favoritePodcastCount: Int
    let favoriteEpisodeCount: Int
    let categories: [String]
    let categoryCounts: [String: Int]
    let podcasts: [Podcast]
    let selectedPodcastId: String?
    let currentView: String
    let scale: CGFloat
    let accentColor: Color
    let buttonBg: Color
    let buttonText: Color
    let sidebarBg: Color
    let dividerColor: Color
    let textColor: Color
    let secondaryText: Color
    let onRefreshAll: () -> Void
    let onSelectAllEpisodes: () -> Void
    let onSelectContinueListening: () -> Void
    let onSelectHistory: () -> Void
    let onSelectDownloads: () -> Void
    let onSelectFavoritePodcasts: () -> Void
    let onSelectFavoriteEpisodes: () -> Void
    let onSelectCategory: (String) -> Void
    let onSelectPodcast: (Podcast) -> Void
    let onRefreshPodcast: (Podcast) -> Void
    let onToggleFavoritePodcast: (Podcast) -> Void
    let onSetCategoryForPodcast: (Podcast) -> Void
    let onDeletePodcast: (Podcast) -> Void
    let onShowAddPodcast: () -> Void
    let onDismissSyncSummary: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Library")
                    .font(.system(size: 16 * scale, weight: .semibold))
                    .foregroundColor(textColor)
                Spacer()
                if isRefreshing {
                    ProgressView().scaleEffect(0.6)
                } else {
                    Button(action: onRefreshAll) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14))
                            .foregroundColor(accentColor)
                    }
                    .buttonStyle(.plain)
                    .help("Refresh all feeds")
                }
            }
            .padding()

            if let syncSummaryTitle, let syncSummarySubtitle, !isRefreshing {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(syncSummaryTitle)
                                .font(.system(size: 12 * scale, weight: .semibold))
                                .foregroundColor(textColor)
                            Text(syncSummarySubtitle)
                                .font(.system(size: 11 * scale))
                                .foregroundColor(secondaryText)
                        }
                        Spacer()
                        Button(action: onDismissSyncSummary) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(secondaryText)
                        }
                        .buttonStyle(.plain)
                    }

                    ForEach(syncSummaryFailures.prefix(3), id: \.self) { failure in
                        Text("• \(failure)")
                            .font(.system(size: 10 * scale))
                            .foregroundColor(.orange)
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
            }
            
            ScrollView {
                VStack(spacing: 4) {
                    SidebarButtonView(
                        icon: "rectangle.stack.fill",
                        iconColor: accentColor,
                        title: "All Episodes",
                        count: nil,
                        isSelected: currentView == "allEpisodes",
                        scale: scale,
                        textColor: textColor,
                        secondaryText: secondaryText,
                        selectionColor: accentColor.opacity(0.3),
                        action: onSelectAllEpisodes
                    )

                    SidebarButtonView(
                        icon: "play.circle.fill",
                        iconColor: .blue,
                        title: "Continue Listening",
                        count: continueListeningCount,
                        isSelected: currentView == "continueListening",
                        scale: scale,
                        textColor: textColor,
                        secondaryText: secondaryText,
                        selectionColor: accentColor.opacity(0.3),
                        action: onSelectContinueListening
                    )
                    
                    SidebarButtonView(
                        icon: "clock.fill",
                        iconColor: .orange,
                        title: "History",
                        count: historyCount,
                        isSelected: currentView == "history",
                        scale: scale,
                        textColor: textColor,
                        secondaryText: secondaryText,
                        selectionColor: accentColor.opacity(0.3),
                        action: onSelectHistory
                    )
                    
                    SidebarButtonView(
                        icon: "arrow.down.circle.fill",
                        iconColor: .green,
                        title: "Downloads",
                        count: downloadedCount,
                        isSelected: currentView == "downloads",
                        scale: scale,
                        textColor: textColor,
                        secondaryText: secondaryText,
                        selectionColor: accentColor.opacity(0.3),
                        action: onSelectDownloads
                    )
                    
                    SidebarButtonView(
                        icon: "star.fill",
                        iconColor: .yellow,
                        title: "Favorite Podcasts",
                        count: favoritePodcastCount,
                        isSelected: currentView == "favoritePodcasts",
                        scale: scale,
                        textColor: textColor,
                        secondaryText: secondaryText,
                        selectionColor: accentColor.opacity(0.3),
                        action: onSelectFavoritePodcasts
                    )
                    
                    SidebarButtonView(
                        icon: "heart.fill",
                        iconColor: .pink,
                        title: "Favorite Episodes",
                        count: favoriteEpisodeCount,
                        isSelected: currentView == "favoriteEpisodes",
                        scale: scale,
                        textColor: textColor,
                        secondaryText: secondaryText,
                        selectionColor: accentColor.opacity(0.3),
                        action: onSelectFavoriteEpisodes
                    )
                    
                    Rectangle().fill(dividerColor).frame(height: 1).padding(.vertical, 8).padding(.horizontal, 12)
                    
                    if !categories.isEmpty {
                        Text("Categories")
                            .font(.system(size: 11 * scale, weight: .medium))
                            .foregroundColor(secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .padding(.bottom, 4)
                        
                        ForEach(categories, id: \.self) { category in
                            SidebarButtonView(
                                icon: "folder.fill",
                                iconColor: accentColor,
                                title: category,
                                count: categoryCounts[category],
                                isSelected: currentView == "category:\(category)",
                                scale: scale,
                                textColor: textColor,
                                secondaryText: secondaryText,
                                selectionColor: accentColor.opacity(0.3),
                                action: { onSelectCategory(category) }
                            )
                        }
                        
                        Rectangle().fill(dividerColor).frame(height: 1).padding(.vertical, 8).padding(.horizontal, 12)
                    }
                    
                    Text("Podcasts")
                        .font(.system(size: 11 * scale, weight: .medium))
                        .foregroundColor(secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 4)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(secondaryText)
                            .font(.system(size: 11 * scale))
                        TextField("Search podcasts...", text: $podcastSearchText)
                            .textFieldStyle(.plain)
                            .font(.system(size: 12 * scale))
                            .foregroundColor(textColor)
                        if !podcastSearchText.isEmpty {
                            Button {
                                podcastSearchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(secondaryText)
                                    .font(.system(size: 11))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(dividerColor.opacity(0.5))
                    .cornerRadius(5)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 6)
                    
                    ForEach(podcasts, id: \.id) { podcast in
                        PodcastSidebarRowView(
                            podcast: podcast,
                            isSelected: selectedPodcastId == podcast.id && currentView == "none",
                            isFavorite: podcast.isFavorite,
                            scale: scale,
                            accentColor: accentColor,
                            textColor: textColor,
                            selectionColor: accentColor.opacity(0.3),
                            onSelect: { onSelectPodcast(podcast) },
                            onRefresh: { onRefreshPodcast(podcast) },
                            onToggleFavorite: { onToggleFavoritePodcast(podcast) },
                            onSetCategory: { onSetCategoryForPodcast(podcast) },
                            onDelete: { onDeletePodcast(podcast) }
                        )
                    }
                }
                .padding(.horizontal, 8)
            }
            
            Rectangle().fill(dividerColor).frame(height: 1)
            
            Button(action: onShowAddPodcast) {
                Label("Add Podcast", systemImage: "plus")
                    .font(.system(size: 14 * scale, weight: .medium))
                    .foregroundColor(buttonText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(buttonBg)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .padding(12)
        }
        .background(sidebarBg)
    }
}

struct EpisodeRowView: View {
    let episode: Episode
    let isSelected: Bool
    let isPlayed: Bool
    let resumePosition: Double
    let isCurrentlyPlaying: Bool
    let isPlaying: Bool
    let isFavorite: Bool
    let isDownloaded: Bool
    let showDownloadedBadge: Bool
    let isQueued: Bool
    let hasNote: Bool
    let scale: CGFloat
    let accentColor: Color
    let textColor: Color
    let secondaryText: Color
    let selectionColor: Color
    let formatDuration: (Int) -> String
    let onSelect: () -> Void
    let onAddToQueue: () -> Void
    let onPlayNext: () -> Void
    let onMarkPlayed: () -> Void
    let onMarkUnplayed: () -> Void
    let onToggleFavorite: () -> Void
    let onEditNote: () -> Void
    let onShowInFinder: (() -> Void)?
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 10) {
                if isPlayed {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(secondaryText)
                        .font(.system(size: 12 * scale))
                } else if resumePosition > 0 {
                    Image(systemName: "circle.lefthalf.filled")
                        .foregroundColor(accentColor)
                        .font(.system(size: 12 * scale))
                }
                
                if isCurrentlyPlaying {
                    Image(systemName: isPlaying ? "speaker.wave.2.fill" : "speaker.fill")
                        .foregroundColor(accentColor)
                        .font(.system(size: 12 * scale))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(episode.title)
                        .font(.system(size: 14 * scale, weight: isPlayed ? .regular : .medium))
                        .foregroundColor(isPlayed ? secondaryText : textColor)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 6) {
                        if let date = episode.pubDate {
                            Text(date, style: .date)
                                .font(.system(size: 11 * scale))
                                .foregroundColor(secondaryText)
                        }
                        if let duration = episode.duration, duration > 0 {
                            Text("•")
                                .foregroundColor(secondaryText)
                                .font(.system(size: 11 * scale))
                            Text(formatDuration(duration))
                                .font(.system(size: 11 * scale))
                                .foregroundColor(secondaryText)
                        }
                        if isFavorite {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.pink)
                                .font(.system(size: 10 * scale))
                        }
                        if isDownloaded && showDownloadedBadge {
                            Image(systemName: "arrow.down.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 10 * scale))
                        }
                        if isQueued {
                            Image(systemName: "list.number")
                                .foregroundColor(accentColor)
                                .font(.system(size: 10 * scale))
                        }
                        if hasNote {
                            Image(systemName: "note.text")
                                .foregroundColor(.orange)
                                .font(.system(size: 10 * scale))
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? selectionColor : Color.clear)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(action: onAddToQueue) {
                Label("Add to Queue", systemImage: "text.badge.plus")
            }
            Button(action: onPlayNext) {
                Label("Play Next", systemImage: "text.insert")
            }
            Divider()
            if isPlayed {
                Button(action: onMarkUnplayed) {
                    Label("Mark as Unplayed", systemImage: "circle")
                }
            } else {
                Button(action: onMarkPlayed) {
                    Label("Mark as Played", systemImage: "checkmark.circle")
                }
            }
            Divider()
            Button(action: onToggleFavorite) {
                Label(isFavorite ? "Remove from Favorites" : "Add to Favorites",
                      systemImage: isFavorite ? "heart.slash" : "heart")
            }
            Button(action: onEditNote) {
                Label("Edit Note...", systemImage: "note.text")
            }
            if let onShowInFinder {
                Button(action: onShowInFinder) {
                    Label("Show in Finder", systemImage: "folder")
                }
            }
        }
    }
}

struct EpisodeListContentView: View {
    @Binding var searchText: String
    let episodeFilter: EpisodeFilter
    let episodeSort: EpisodeSort
    let filteredEpisodes: [Episode]
    let scale: CGFloat
    let accentColor: Color
    let dividerColor: Color
    let textColor: Color
    let secondaryText: Color
    let onSelectFilter: (EpisodeFilter) -> Void
    let onSelectSort: (EpisodeSort) -> Void
    let rowContent: (Episode, Int) -> AnyView
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Menu {
                    ForEach(EpisodeFilter.allCases, id: \.self) { filter in
                        Button {
                            onSelectFilter(filter)
                        } label: {
                            if episodeFilter == filter {
                                Text("✓ " + filter.rawValue)
                            } else {
                                Text("    " + filter.rawValue)
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "line.3.horizontal.decrease.circle").font(.system(size: 11))
                        Text(episodeFilter.rawValue).font(.system(size: 11 * scale))
                    }
                    .foregroundColor(episodeFilter == .all ? secondaryText : accentColor)
                }
                .menuStyle(.borderlessButton)
                
                Menu {
                    ForEach(EpisodeSort.allCases, id: \.self) { sort in
                        Button {
                            onSelectSort(sort)
                        } label: {
                            if episodeSort == sort {
                                Text("✓ " + sort.rawValue)
                            } else {
                                Text("    " + sort.rawValue)
                            }
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
            .padding(.horizontal, 12)
            .padding(.bottom, 6)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(secondaryText)
                    .font(.system(size: 12 * scale))
                TextField("Search episodes...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13 * scale))
                    .foregroundColor(textColor)
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(secondaryText)
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(dividerColor.opacity(0.5))
            .cornerRadius(6)
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
            
            Rectangle().fill(dividerColor).frame(height: 1)
            
            if filteredEpisodes.isEmpty {
                VStack {
                    Spacer()
                    Text("No episodes")
                        .font(.system(size: 14 * scale))
                        .foregroundColor(secondaryText)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(filteredEpisodes.enumerated()), id: \.element.id) { index, episode in
                            VStack(spacing: 0) {
                                rowContent(episode, index)
                                if index < filteredEpisodes.count - 1 {
                                    Rectangle().fill(dividerColor).frame(height: 1).padding(.leading, 12)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct EpisodeDetailPaneView: View {
    let episode: Episode?
    let podcast: Podcast?
    let currentlyPlayingEpisodeID: String?
    let isPlaying: Bool
    let isEpisodePlayed: Bool
    let resumePosition: Double
    let isFavorite: Bool
    let isQueued: Bool
    let isDownloaded: Bool
    let isDownloading: Bool
    let note: String
    let scale: CGFloat
    let accentColor: Color
    let buttonBg: Color
    let buttonText: Color
    let detailBg: Color
    let dividerColor: Color
    let textColor: Color
    let secondaryText: Color
    let onPlayPause: () -> Void
    let onPlayEpisode: (Episode) -> Void
    let onQueue: (Episode) -> Void
    let onToggleFavorite: (Episode) -> Void
    let onShowInFinder: (Episode) -> Void
    let onDeleteDownload: (Episode) -> Void
    let onDownload: (Episode) -> Void
    let onEditNote: () -> Void
    let onAddNote: () -> Void
    let formatDuration: (Int) -> String
    let formatTime: (Double) -> String
    let stripHTML: (String) -> String
    
    var body: some View {
        VStack {
            if let episode {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        if let artworkURL = podcast?.artworkURL, let url = URL(string: artworkURL) {
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
                                Text(date, style: .date)
                                    .font(.system(size: 13 * scale))
                                    .foregroundColor(secondaryText)
                            }
                            if let duration = episode.duration, duration > 0 {
                                Text("•").foregroundColor(secondaryText)
                                Text(formatDuration(duration))
                                    .font(.system(size: 13 * scale))
                                    .foregroundColor(secondaryText)
                            }
                            if isEpisodePlayed {
                                Text("•").foregroundColor(secondaryText)
                                Text("Played")
                                    .font(.system(size: 13 * scale))
                                    .foregroundColor(secondaryText)
                            } else if resumePosition > 0 {
                                Text("•").foregroundColor(secondaryText)
                                Text("\(formatTime(resumePosition)) in")
                                    .font(.system(size: 13 * scale))
                                    .foregroundColor(accentColor)
                            }
                        }
                        
                        HStack(spacing: 8) {
                            Button {
                                if currentlyPlayingEpisodeID == episode.id {
                                    onPlayPause()
                                } else {
                                    onPlayEpisode(episode)
                                }
                            } label: {
                                Label(
                                    currentlyPlayingEpisodeID == episode.id && isPlaying ? "Pause" : (resumePosition > 0 ? "Resume" : "Play"),
                                    systemImage: currentlyPlayingEpisodeID == episode.id && isPlaying ? "pause.fill" : "play.fill"
                                )
                                .font(.system(size: 13 * scale, weight: .medium))
                                .foregroundColor(buttonText)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(buttonBg)
                                .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                            
                            Button {
                                onQueue(episode)
                            } label: {
                                Label("Queue", systemImage: "text.badge.plus")
                                    .font(.system(size: 13 * scale, weight: .medium))
                                    .foregroundColor(isQueued ? .white : textColor)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(isQueued ? accentColor : dividerColor.opacity(0.5))
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                            
                            Button {
                                onToggleFavorite(episode)
                            } label: {
                                Image(systemName: isFavorite ? "heart.fill" : "heart")
                                    .font(.system(size: 14 * scale))
                                    .foregroundColor(isFavorite ? .pink : textColor)
                                    .padding(6)
                                    .background(dividerColor.opacity(0.5))
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                            
                            if isDownloaded {
                                Menu {
                                    Button {
                                        onShowInFinder(episode)
                                    } label: {
                                        Label("Show in Finder", systemImage: "folder")
                                    }
                                    
                                    Button(role: .destructive) {
                                        onDeleteDownload(episode)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                } label: {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 14 * scale))
                                        .foregroundColor(.green)
                                        .padding(6)
                                        .background(dividerColor.opacity(0.5))
                                        .cornerRadius(6)
                                }
                            } else if isDownloading {
                                ProgressView().scaleEffect(0.7)
                            } else {
                                Button {
                                    onDownload(episode)
                                } label: {
                                    Image(systemName: "arrow.down.circle")
                                        .font(.system(size: 14 * scale))
                                        .foregroundColor(textColor)
                                        .padding(6)
                                        .background(dividerColor.opacity(0.5))
                                        .cornerRadius(6)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        if !note.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Image(systemName: "note.text")
                                        .foregroundColor(.orange)
                                        .font(.system(size: 12))
                                    Text("Note")
                                        .font(.system(size: 13 * scale, weight: .medium))
                                        .foregroundColor(textColor)
                                    Spacer()
                                    Button(action: onEditNote) {
                                        Text("Edit")
                                            .font(.system(size: 11 * scale))
                                            .foregroundColor(accentColor)
                                    }
                                    .buttonStyle(.plain)
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
                            Button(action: onAddNote) {
                                Label("Add Note", systemImage: "note.text.badge.plus")
                                    .font(.system(size: 12 * scale))
                                    .foregroundColor(secondaryText)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        Rectangle().fill(dividerColor).frame(height: 1).padding(.vertical, 4)
                        
                        if let description = episode.episodeDescription {
                            Text("Description")
                                .font(.system(size: 14 * scale, weight: .semibold))
                                .foregroundColor(textColor)
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
                    Image(systemName: "radio")
                        .font(.system(size: 50))
                        .foregroundColor(accentColor.opacity(0.6))
                    Text("Welcome to PodVault")
                        .font(.system(size: 24 * scale, weight: .bold))
                        .foregroundColor(textColor)
                    Text("Select a podcast and episode")
                        .font(.system(size: 14 * scale))
                        .foregroundColor(secondaryText)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(detailBg)
    }
}

struct QueuePanelView: View {
    let queue: [Episode]
    let activeDownloads: [DownloadManager.DownloadTask]
    let queuedDownloads: [DownloadManager.QueuedDownload]
    let overallDownloadProgress: Double
    let accentColor: Color
    let textColor: Color
    let secondaryText: Color
    let dividerColor: Color
    let backgroundColor: Color
    let scale: CGFloat
    let formatDuration: (Int) -> String
    let onClear: () -> Void
    let onRemove: (Int) -> Void
    let onSelect: (Int) -> Void
    let onCancelDownload: (String) -> Void
    let onCancelAllDownloads: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "list.number")
                    .foregroundColor(accentColor)
                    .font(.system(size: 14 * scale))
                Text("Up Next")
                    .font(.system(size: 14 * scale, weight: .semibold))
                    .foregroundColor(textColor)
                Spacer()
                if !queue.isEmpty {
                    Button(action: onClear) {
                        Text("Clear")
                            .font(.system(size: 12 * scale))
                            .foregroundColor(accentColor)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            
            Rectangle().fill(dividerColor).frame(height: 1)
            
            ScrollView {
                VStack(spacing: 0) {
                    if queue.isEmpty {
                        HStack {
                            Spacer()
                            Text("Queue is empty")
                                .font(.system(size: 13 * scale))
                                .foregroundColor(secondaryText)
                            Spacer()
                        }
                        .padding(.vertical, 18)
                    } else {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(queue.enumerated()), id: \.element.id) { index, episode in
                                VStack(spacing: 0) {
                                    HStack(spacing: 10) {
                                        Text("\(index + 1)")
                                            .font(.system(size: 12 * scale, weight: .medium))
                                            .foregroundColor(secondaryText)
                                            .frame(width: 20)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(episode.title)
                                                .font(.system(size: 13 * scale, weight: .medium))
                                                .foregroundColor(textColor)
                                                .lineLimit(1)
                                            
                                            if let duration = episode.duration, duration > 0 {
                                                Text(formatDuration(duration))
                                                    .font(.system(size: 11 * scale))
                                                    .foregroundColor(secondaryText)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Button {
                                            onRemove(index)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(secondaryText)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        onSelect(index)
                                    }
                                    
                                    if index < queue.count - 1 {
                                        Rectangle().fill(dividerColor).frame(height: 1).padding(.leading, 46)
                                    }
                                }
                            }
                        }
                    }
                    
                    if !activeDownloads.isEmpty || !queuedDownloads.isEmpty {
                        Rectangle().fill(dividerColor).frame(height: 1)
                            .padding(.top, queue.isEmpty ? 0 : 4)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.down.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 13 * scale))
                            Text("Downloads")
                                .font(.system(size: 13 * scale, weight: .semibold))
                                .foregroundColor(textColor)
                            Spacer()
                            Text("\(Int(overallDownloadProgress * 100))%")
                                .font(.system(size: 11 * scale))
                                .foregroundColor(secondaryText)
                            Button("Cancel All", action: onCancelAllDownloads)
                                .font(.system(size: 11 * scale))
                                .buttonStyle(.plain)
                                .foregroundColor(accentColor)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        
                        ForEach(activeDownloads, id: \.id) { download in
                            VStack(spacing: 6) {
                                HStack(spacing: 10) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(download.episodeTitle)
                                            .font(.system(size: 12 * scale, weight: .medium))
                                            .foregroundColor(textColor)
                                            .lineLimit(1)
                                        Text(download.podcastTitle)
                                            .font(.system(size: 10 * scale))
                                            .foregroundColor(secondaryText)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                    Text(download.formattedProgress)
                                        .font(.system(size: 11 * scale, weight: .medium))
                                        .foregroundColor(accentColor)
                                    Button {
                                        onCancelDownload(download.episodeId)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(secondaryText)
                                    }
                                    .buttonStyle(.plain)
                                }
                                
                                ProgressView(value: download.progress)
                                    .tint(accentColor)
                                
                                HStack {
                                    Text(download.formattedSize)
                                        .font(.system(size: 10 * scale))
                                        .foregroundColor(secondaryText)
                                    Spacer()
                                    Text(download.formattedSpeed)
                                        .font(.system(size: 10 * scale))
                                        .foregroundColor(secondaryText)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            
                            if download.id != activeDownloads.last?.id || !queuedDownloads.isEmpty {
                                Rectangle().fill(dividerColor).frame(height: 1).padding(.leading, 16)
                            }
                        }
                        
                        ForEach(queuedDownloads, id: \.id) { queued in
                            VStack(spacing: 0) {
                                HStack(spacing: 10) {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .foregroundColor(secondaryText)
                                        .font(.system(size: 11 * scale))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(queued.episodeTitle)
                                            .font(.system(size: 12 * scale, weight: .medium))
                                            .foregroundColor(textColor)
                                            .lineLimit(1)
                                        Text("Queued")
                                            .font(.system(size: 10 * scale))
                                            .foregroundColor(secondaryText)
                                    }
                                    Spacer()
                                    Button {
                                        onCancelDownload(queued.episodeId)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(secondaryText)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                
                                if queued.id != queuedDownloads.last?.id {
                                    Rectangle().fill(dividerColor).frame(height: 1).padding(.leading, 16)
                                }
                            }
                        }
                    }
                }
            }
        }
        .frame(height: (!activeDownloads.isEmpty || !queuedDownloads.isEmpty) ? 280 : 180)
        .background(backgroundColor)
    }
}

struct NowPlayingBarView: View {
    let episode: Episode
    let isPlaying: Bool
    let currentTime: Double
    let duration: Double
    let hasNextEpisode: Bool
    let scale: CGFloat
    let accentColor: Color
    let buttonBg: Color
    let buttonText: Color
    let sidebarBg: Color
    let dividerColor: Color
    let textColor: Color
    let secondaryText: Color
    let volumeBoost: Float
    let selectedSpeed: Float
    let playbackSpeeds: [Float]
    let formatTime: (Double) -> String
    let formatSpeed: (Float) -> String
    let onSkipBackward: () -> Void
    let onPlayPause: () -> Void
    let onSkipForward: () -> Void
    let onNext: () -> Void
    let onSeek: (Double) -> Void
    let onSetSpeed: (Float) -> Void
    let onStop: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(accentColor).frame(height: 2)
            
            HStack(spacing: 14) {
                Button(action: onSkipBackward) {
                    Image(systemName: "gobackward.15").font(.system(size: 18 * scale))
                }
                .buttonStyle(.plain)
                .foregroundColor(accentColor)
                
                Button(action: onPlayPause) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 22 * scale))
                }
                .buttonStyle(.plain)
                .foregroundColor(accentColor)
                
                Button(action: onSkipForward) {
                    Image(systemName: "goforward.30").font(.system(size: 18 * scale))
                }
                .buttonStyle(.plain)
                .foregroundColor(accentColor)
                
                Button(action: onNext) {
                    Image(systemName: "forward.end.fill").font(.system(size: 16 * scale))
                }
                .buttonStyle(.plain)
                .foregroundColor(hasNextEpisode ? accentColor : secondaryText.opacity(0.5))
                .disabled(!hasNextEpisode)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(episode.title)
                        .font(.system(size: 14 * scale, weight: .semibold))
                        .foregroundColor(textColor)
                        .lineLimit(1)
                    Text("\(formatTime(currentTime)) / \(formatTime(duration))")
                        .font(.system(size: 11 * scale))
                        .foregroundColor(secondaryText)
                }
                
                Spacer()
                
                if volumeBoost != 1.0 {
                    Text("\(Int(volumeBoost * 100))%")
                        .font(.system(size: 10 * scale))
                        .foregroundColor(secondaryText)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(dividerColor.opacity(0.5))
                        .cornerRadius(4)
                }
                
                Slider(
                    value: Binding(
                        get: { currentTime },
                        set: onSeek
                    ),
                    in: 0...max(duration, 1)
                )
                .frame(width: 160)
                .tint(accentColor)
                
                Menu {
                    ForEach(playbackSpeeds, id: \.self) { speed in
                        Button {
                            onSetSpeed(speed)
                        } label: {
                            if selectedSpeed == speed {
                                Text("✓ \(formatSpeed(speed))")
                            } else {
                                Text("    \(formatSpeed(speed))")
                            }
                        }
                    }
                } label: {
                    Text(formatSpeed(selectedSpeed))
                        .font(.system(size: 12 * scale, weight: .medium))
                        .foregroundColor(buttonText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(buttonBg)
                        .cornerRadius(6)
                }
                .menuStyle(.borderlessButton)
                .frame(width: 60)
                
                Button(action: onStop) {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 20 * scale))
                }
                .buttonStyle(.plain)
                .foregroundColor(secondaryText)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(sidebarBg)
        }
    }
}

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
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: onPlayPause) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill").font(.system(size: 22))
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: onSkipForward) {
                        Image(systemName: "goforward.30").font(.system(size: 14))
                    }
                    .buttonStyle(.plain)
                    
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
    
    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite else { return "0:00" }
        let m = (Int(seconds) % 3600) / 60
        let s = Int(seconds) % 60
        return String(format: "%d:%02d", m, s)
    }
}
