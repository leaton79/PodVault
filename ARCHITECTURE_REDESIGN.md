# PodVault Architecture Redesign Plan

## Goal
Improve performance, smoothness, maintainability, and implementation clarity without changing the core product:

- Browse podcasts and episodes
- Stream or play downloaded audio
- Manage queue, favorites, downloads, and notes
- Sync feeds reliably
- Keep the app practical for incremental Codex implementation

## What Exists Today

### Confirmed
- Native macOS app built with SwiftUI.
- SQLite persistence through GRDB.
- A real repository layer for podcasts, episodes, notes, tags, and activity.
- Dedicated service files for playback, downloads, saved library, exports, OPML, and syncing.
- A very large `ContentView` in `Sources/PodVault/PodVaultApp.swift` still drives most user behavior directly.
- `ContentView` contains its own playback implementation even though `PlaybackManager` already exists.
- User episode state is split between database fields and `AppSettings` JSON.
- Tests are minimal.

### Key Architectural Problem
The codebase already contains the start of a better architecture, but the shipping app still bypasses much of it. The result is duplicated logic, multiple sources of truth, and extra work on the UI layer.

## Design Principles

- Prefer one source of truth per type of data.
- Keep UI code focused on presentation and user interaction.
- Keep persistence and background work out of views.
- Avoid introducing new frameworks unless the current stack cannot support the target design.
- Refactor incrementally, not as a rewrite.

## Target Architecture

Use four simple layers:

1. Views
- Pure SwiftUI views.
- No direct database reads.
- No direct networking.
- No direct `AVPlayer` ownership.

2. Feature ViewModels
- Own screen state and user actions.
- Call services/repositories.
- Expose display-ready state to views.

3. Services
- Handle playback, sync, downloading, import/export, and saved-library workflows.
- Publish long-lived state where appropriate.

4. Persistence
- GRDB-backed repositories.
- Small settings store for app preferences only.

## Target File Structure

```text
Sources/PodVault/
  App/
    PodVaultApp.swift
    AppCoordinator.swift
  Features/
    Library/
      LibraryView.swift
      LibraryViewModel.swift
      SidebarView.swift
    Episodes/
      EpisodeListView.swift
      EpisodeListViewModel.swift
      EpisodeDetailView.swift
    Player/
      NowPlayingBar.swift
      MiniPlayerView.swift
      PlayerViewModel.swift
    Downloads/
      DownloadsView.swift
      DownloadsViewModel.swift
    Settings/
      SettingsView.swift
      SettingsViewModel.swift
  Services/
    PlaybackManager.swift
    DownloadManager.swift
    SyncService.swift
    FeedService.swift
    OPMLService.swift
    ExportService.swift
    SavedLibraryManager.swift
  Persistence/
    DatabaseManager.swift
    PodcastRepository.swift
    SettingsStore.swift
  Models/
    Podcast.swift
    Episode.swift
    ActivityLog.swift
    Tag.swift
```

## Ownership Rules

### Database Owns
- Podcasts
- Episodes
- Playback progress
- Played/unplayed state
- Saved/downloaded state
- Notes
- Favorites
- Activity log

### Settings Owns
- Theme
- Font size
- Sync interval
- Playback defaults such as preferred speed and skip interval
- Window/layout preferences

### PlaybackManager Owns
- Current episode
- Current podcast
- Current time
- Duration
- Is playing / loading / error state
- Remote command handling

### ViewModels Own
- Selected rows
- Search text
- Filter choice
- Sort choice
- Sheet visibility
- Screen-specific loading/error state

## What Changes First

### 1. Eliminate Duplicate Playback
Current problem:
- `ContentView` owns an `AVPlayer`.
- `PlaybackManager` also owns playback logic.

Target:
- `PlaybackManager` becomes the only playback engine.
- UI reads published playback state from it.
- `ContentView` no longer creates or manages an `AVPlayer`.

Expected gains:
- Fewer playback bugs
- Better media key behavior consistency
- Cleaner now-playing bar and mini-player wiring

### 2. Move Episode State Into Database
Current problem:
- Progress and played state live in both the DB and `AppSettings`.
- Favorites live in a JSON file outside the DB.

Target:
- Episode state becomes DB-backed.
- `AppSettings` becomes a lightweight preference store only.

Expected gains:
- One truth for library state
- Simpler refresh logic
- Easier future search, sync, and export

### 3. Replace View-As-Repository Pattern
Current problem:
- `ContentView` directly loads data from the repository and manually stitches lists together.

Target:
- Add dedicated repository queries for major screens.
- Add small view models for each screen.

Expected gains:
- Less redundant loading
- Better responsiveness for larger libraries
- More testable behavior

## Repository Changes Needed

Add explicit queries instead of assembling arrays in the view:

- `getAllEpisodes(limit:offset:)`
- `getDownloadedEpisodes()`
- `getFavoriteEpisodes()`
- `getFavoritePodcasts()`
- `searchEpisodes(query:filter:sort:)`
- `getEpisodes(forCategory:)` if categories remain settings-backed initially

If favorites are migrated to the database, add:

- `setPodcastFavorite(id:isFavorite:)`
- `setEpisodeFavorite(id:isFavorite:)`
- `getFavoritePodcastIDs()`
- `getFavoriteEpisodeIDs()`

## Sync Design

### Current Problems
- Multiple sync paths exist.
- One path only refreshes episode rows.
- Sync happens sequentially through all podcasts.

### Target
- One sync entry point for manual and scheduled sync.
- Standard sync result model used by UI and activity log.
- Controlled concurrency, not unlimited parallelism.

### Recommended Rule
- Sync 3 to 5 feeds in parallel at most.
- Keep per-feed failures isolated.
- Update UI summary once at the end.

## Search Design

### Current State
- FTS tables exist, but there is no confirmed index-maintenance path.

### Recommendation
Phase 1:
- Use normal SQL search for titles/descriptions if needed immediately.

Phase 2:
- Either wire FTS properly with triggers or remove it until it is ready.

Do not keep half-wired search infrastructure.

## Download Design

### Current Problem
- `DownloadManager` exists, but the main UI also downloads episodes directly.

### Target
- `DownloadManager` handles all downloading.
- UI observes manager state.
- Repository reflects stable download outcomes.

### Result
- Better progress visibility
- Better cancellation/retry support
- Less duplicated file handling

## UI Decomposition Plan

Split `ContentView` into these pieces:

- `LibraryShellView`
- `SidebarView`
- `EpisodeListView`
- `EpisodeRowView`
- `EpisodeDetailView`
- `QueueView`
- `NowPlayingBar`
- `AddPodcastSheet`
- `CategorySheet`
- `NoteEditorSheet`
- `StatisticsView`

The first split should be structural only. Keep visuals mostly unchanged while moving logic out.

## Migration Plan

### Phase 0: Safety Net
- Add tests for repository reads/writes.
- Add tests for feed sync duplicate handling.
- Add tests for playback progress save/restore rules.

### Phase 1: Single Source of Truth
- Move favorites into DB.
- Move played/progress ownership fully into DB.
- Reduce `AppSettings` to UI preferences and app-level settings.

### Phase 2: Playback Consolidation
- Replace `ContentView` playback code with `PlaybackManager`.
- Wire now-playing and mini-player to manager state.
- Remove duplicate playback observers in `ContentView`.

### Phase 3: Query and Screen Refactor
- Introduce `LibraryViewModel`, `EpisodeListViewModel`, and `PlayerViewModel`.
- Replace view-driven list assembly with repository queries.
- Split `ContentView` into smaller views.

### Phase 4: Service Integration
- Route downloads through `DownloadManager`.
- Route manual/scheduled sync through one sync service.
- Reconnect saved-library export and notes/tags on top of the cleaned data flow.

### Phase 5: Performance Pass
- Add artwork caching.
- Reduce unnecessary view recomputation.
- Profile feed sync and episode list loading on a larger library.

## Keep / Change / Remove

### Keep
- SwiftUI
- GRDB
- SQLite database
- Existing service files as implementation seeds
- Existing product scope

### Change
- State ownership
- Sync orchestration
- View composition
- Query strategy

### Remove
- `ContentView`-owned `AVPlayer`
- JSON-backed favorites
- JSON-backed episode progress and played state
- Unused placeholder app state unless promoted into the real coordinator

## First Codex Refactor Tasks

These are the best first implementation tasks in order:

1. Add a database migration for favorites.
- Podcast `isFavorite`
- Episode `isFavorite`

2. Add repository queries for:
- all episodes
- downloaded episodes
- favorite episodes
- favorite podcasts

3. Replace favorites JSON loading/saving in `PodVaultApp.swift` with repository-backed reads/writes.

4. Create `PlayerViewModel` that wraps `PlaybackManager`.

5. Replace `ContentView` playback actions with `PlaybackManager` calls.

6. Extract `SidebarView`, `EpisodeListView`, and `EpisodeDetailView` without changing behavior.

## Recommended Initial Scope

Do this first and stop there before expanding:

- Favorites to DB
- Playback through `PlaybackManager`
- Repository queries for major lists
- `ContentView` split into 3 to 5 smaller views

That is enough to materially improve structure without overengineering.

## Decisions Needed

### Decision 1
Store episode/library state in the database, not JSON files.

Recommended:
- Yes

Why:
- It simplifies the app and removes conflicting state.

### Decision 2
Keep the current three-pane UI layout for now.

Recommended:
- Yes

Why:
- It reduces migration risk while still allowing internal cleanup.

### Decision 3
Defer advanced search/indexing cleanup until after playback and list-state cleanup.

Recommended:
- Yes

Why:
- Playback and list correctness matter more to daily use.

## Definition of Success

The redesign is succeeding when:

- There is only one playback path.
- Episode state has one source of truth.
- Major screens load from repository queries, not stitched arrays.
- `PodVaultApp.swift` is reduced to app setup and shell composition.
- New feature work can be done in small, isolated changes.
