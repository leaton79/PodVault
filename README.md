# PodVault

Native macOS podcast streaming and offline listening app built with SwiftUI, GRDB, and FeedKit.

## What It Does
- Subscribe to podcast feeds directly or paste a podcast webpage and let the app find the RSS feed.
- Browse podcasts, all episodes, favorites, downloads, history, and continue-listening items.
- Stream episodes or play downloaded files locally.
- Queue episodes, use continuous playback, and control playback speed, skip, and volume boost.
- Organize podcasts with categories and add notes to episodes.
- Import/export OPML and export listening history.

## Current Highlights
- One playback system through `PlaybackManager`
- Database-backed favorites, playback progress, and played state
- Download queue UI backed by `DownloadManager`
- Continue Listening section driven by in-progress episodes
- Refresh summaries for full-library and single-feed sync
- Indexed episode search using SQLite FTS

## Requirements
- macOS 14 or later
- Xcode 15 or newer
- Xcode Command Line Tools
- Homebrew `xcodegen` if you want to generate the Xcode project from `project.yml`

## Build From Source

### Swift Package
For development and tests:

```bash
git clone https://github.com/leaton79/PodVault.git
cd PodVault
swift build
swift test
```

### macOS App Bundle
Generate the Xcode project and build the `.app`:

```bash
xcodegen generate
xcodebuild -project PodVault.xcodeproj -scheme PodVault -configuration Debug -derivedDataPath build
```

The built app will be at:

```bash
build/Build/Products/Debug/PodVault.app
```

## Install On Mac
After building:

```bash
cp -R build/Build/Products/Debug/PodVault.app ~/Applications/PodVault.app
open ~/Applications/PodVault.app
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

## Project Notes
- Original redesign plan: [`ARCHITECTURE_REDESIGN.md`](ARCHITECTURE_REDESIGN.md)
- Current implementation handoff: [`REDESIGN_HANDOFF.md`](REDESIGN_HANDOFF.md)

## License

MIT License. See [`LICENSE`](LICENSE).
