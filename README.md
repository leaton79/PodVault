# PodVault 🎧⚡

A modern, native macOS podcast player built with Swift and SwiftUI.

![PodVault Screenshot](screenshot.png)

## Features

### Playback
- Stream or play downloaded episodes
- Playback speed control (0.5x - 2x)
- Volume boost (50% - 200%)
- Skip forward/back (30s/15s)
- Playback position memory
- Auto-advance queue
- Continuous playback option
- Mini player (⇧⌘M)

### Library Management
- Add podcasts via RSS feed URL
- Auto-detects RSS from podcast webpage URLs
- Podcast categories/folders
- Favorites (podcasts & episodes)
- Episode notes
- Playback history
- OPML import/export

### Organization
- Episode filters (All, Unplayed, In Progress, Downloaded, Favorites)
- Episode sorting (Newest, Oldest, Longest, Shortest, Title)
- Search podcasts and episodes
- All Episodes view across all podcasts

### Customization
- 8 color themes
- 4 font sizes
- Resizable columns

### Extras
- Statistics dashboard (⇧⌘S)
- Export listening history
- Offline downloads with Show in Finder
- Keyboard shortcuts

## Requirements

- macOS 13.0 or later
- Xcode Command Line Tools

## Installation

### Option 1: Download Release
Download the latest `PodVault.app` from the [Releases](https://github.com/leaton79/podvault/releases) page and drag it to your Applications folder.

### Option 2: Build from Source
```bash
git clone https://github.com/leaton79/podvault.git
cd podvault
swift build
cp .build/debug/PodVault PodVault.app/Contents/MacOS/
codesign --force --deep --sign - PodVault.app
cp -R PodVault.app /Applications/
```

## Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Play/Pause | Space |
| Skip Forward | ⌘→ |
| Skip Back | ⌘← |
| Next Episode | ⌘N |
| Volume Up | ⌘↑ |
| Volume Down | ⌘↓ |
| Mini Player | ⇧⌘M |
| Statistics | ⇧⌘S |
| Import OPML | ⇧⌘I |
| Export OPML | ⇧⌘E |

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Author

Created by Lance Eaton
