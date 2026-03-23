# PodVault Redesign Handoff

## Status
This codebase has moved from an all-in-one app shell toward a usable layered structure.

The redesign work completed so far is incremental, not a rewrite. Core app behavior is preserved, but state ownership and workflow boundaries are materially cleaner than the original baseline.

## What Changed

### 1. Playback Is Unified
- `PlaybackManager` is now the active playback engine.
- The app shell no longer owns a separate `AVPlayer`.
- The now-playing bar, mini-player, queue progression, and playback completion logic all route through the shared playback manager.

Main files:
- `Sources/PodVault/Services/PlaybackManager.swift`
- `Sources/PodVault/PodVaultApp.swift`
- `Sources/PodVault/Views/PlaybackViews.swift`

### 2. Favorites Are Database-Backed
- Podcast and episode favorites now live in SQLite instead of a JSON file.
- Legacy favorites are migrated from `favorites.json` into the database.
- Repository queries now drive favorite podcasts and favorite episodes.

Main files:
- `Sources/PodVault/Database/DatabaseManager.swift`
- `Sources/PodVault/Database/PodcastRepository.swift`
- `Sources/PodVault/PodVaultApp.swift`

### 3. Library State Has a Real View Model
- `LibraryViewModel` now owns:
  - selected podcast and episode IDs
  - current library section
  - episode filter/sort/search state
  - favorite/download/in-progress list state
  - visible-content reload rules
- The app shell uses that model instead of manually owning all list state.

Main file:
- `Sources/PodVault/ViewModels/LibraryViewModel.swift`

### 4. Library Workflows Moved Out of the App Shell
- `LibraryService` now owns:
  - add podcast
  - refresh podcast
  - delete podcast
  - favorite loading/migration
  - played-state persistence helper
  - download record validation

Main file:
- `Sources/PodVault/Services/LibraryService.swift`

### 5. Downloading Uses One System
- The app now routes downloads through `DownloadManager`.
- The old direct `URLSession` shell download path is gone.
- Download UI now shows active and queued downloads with cancel controls.
- Downloaded state is derived from persisted `downloadPath` values.

Main files:
- `Sources/PodVault/Services/DownloadManager.swift`
- `Sources/PodVault/Views/PlaybackViews.swift`
- `Sources/PodVault/PodVaultApp.swift`

### 6. Search Uses the Database Search Infrastructure
- FTS tables are now backfilled and maintained with triggers.
- Episode search can use database-backed search matches instead of only local in-memory substring filtering.
- Notes search is also available through the same indexed path.

Main files:
- `Sources/PodVault/Database/DatabaseManager.swift`
- `Sources/PodVault/Database/PodcastRepository.swift`
- `Sources/PodVault/ViewModels/LibraryViewModel.swift`

### 7. Continue Listening Exists as a Real Library Section
- There is now a first-class `Continue Listening` section.
- It is driven by in-progress episodes from the database.
- It updates from playback progress changes and playback completion.

Main files:
- `Sources/PodVault/ViewModels/LibraryViewModel.swift`
- `Sources/PodVault/PodVaultApp.swift`
- `Sources/PodVault/Views/PlaybackViews.swift`

### 8. Refresh Feedback Exists
- Full-library refresh now produces a visible summary.
- Single-feed refresh also produces visible feedback.
- Refresh all avoids unnecessary repeated reload work inside the loop.

Main files:
- `Sources/PodVault/Services/LibraryService.swift`
- `Sources/PodVault/PodVaultApp.swift`
- `Sources/PodVault/Views/PlaybackViews.swift`

### 9. Playback Progress / Played State Now Has One Active Source of Truth
- The library UI now reads played/progress state from episode records.
- `PlaybackManager` restores and saves playback position through the repository.
- Manual played/unplayed actions persist through the repository too.
- `AppSettings` no longer acts as the active store for per-episode played/progress state.

Main files:
- `Sources/PodVault/Services/PlaybackManager.swift`
- `Sources/PodVault/Services/LibraryService.swift`
- `Sources/PodVault/PodVaultApp.swift`

## User-Visible Improvements
- Download queue is visible and cancellable.
- Refresh actions show clear results.
- Continue Listening is available from the sidebar.
- Search quality is better because the app can use indexed search results.
- Playback/download/library behavior is more consistent.

## Codebase Shape Now

### App Shell
- `Sources/PodVault/PodVaultApp.swift`

Role:
- UI composition
- event routing
- lightweight orchestration

### View Models
- `Sources/PodVault/ViewModels/LibraryViewModel.swift`

Role:
- library state
- selection
- search/filter/sort
- visible list composition

### Services
- `Sources/PodVault/Services/PlaybackManager.swift`
- `Sources/PodVault/Services/DownloadManager.swift`
- `Sources/PodVault/Services/LibraryService.swift`

Role:
- playback
- download queue/progress
- library workflows

### Persistence
- `Sources/PodVault/Database/DatabaseManager.swift`
- `Sources/PodVault/Database/PodcastRepository.swift`

Role:
- migrations
- query APIs
- playback/download/favorite/search persistence

## Testing Status
- Tests now cover:
  - library view model state behavior
  - continue listening view-model behavior
  - matched-ID search filtering behavior
  - repository playback progress persistence
  - repository FTS-backed episode search

Current test count:
- 11 passing tests

Main file:
- `Tests/PodVaultTests/PodVaultTests.swift`

## What Still Needs Work

### Moderate Priority
- Add more repository/service tests around:
  - refresh result handling
  - download status cleanup
  - note search / FTS maintenance behavior

### Lower-Level Structural Cleanup
- `PodVaultApp.swift` is much thinner than before, but it is still large.
- If further architecture work is needed, the next clean step is introducing a small app coordinator or splitting more shell actions into focused helpers.

### Product Polish Opportunities
- Better empty states and status messaging in the episode list/detail panes.
- Download completion/failure toast or inline indicator.
- Search-specific UI feedback when indexed search returns no matches.
- Better history and sync reporting surfaces.

## Recommended Next Steps

### Best Next Technical Step
Add a few more repository/service tests before another major refactor.

Why:
- The architecture seam is now strong enough to justify protecting it.
- The highest-risk logic is now in services and persistence, not just views.

### Best Next Product Step
Add lightweight download completion/failure feedback or a stronger sync results surface.

Why:
- The architecture now supports those features cleanly.
- They improve clarity without reopening major state design questions.

## Practical Summary
The redesign is no longer just a plan. The app now has:
- one playback path
- one download path
- database-backed favorites
- database-backed active playback state
- a real library view model
- a library workflow service
- visible refresh/download progress improvements
- test coverage for the most important new seams

This is a stable handoff point for continued implementation work.
