# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] – 2026-02-28

### Added
- **Comprehensive example app** with 4 feature tabs demonstrating all bloc_manager capabilities:
  - **Posts Tab**: PaginationBlocMixin with infinite scroll pagination (JSONPlaceholder API)
  - **Pokemon Tab**: CacheableBlocMixin with 10-minute TTL cache and visual "From Cache" badge (PokeAPI)
  - **Products Tab**: RefreshableBlocMixin with pull-to-refresh and 30-second auto-refresh (Fake Store API)
  - **Todos Tab**: All BaseState types with color-coded state banner showing current state (JSONPlaceholder)
- Example app uses real public APIs for production-ready demonstrations
- Updated README with detailed example app documentation and feature breakdown
- Central BlocProvider registry in home screen for clean architecture

### Changed
- TodosCubit: Fixed `toggleTodo` and `deleteTodo` to re-emit LoadedState after SuccessState, preventing UI data loss
- PokemonCubit: Search now checks cache before API call for improved performance
- Improved example app code with inline comments explaining each feature

### Fixed
- Todos list no longer disappears when marking items as completed
- Pokemon cache now shows "From Cache" badge when searching for same Pokemon

## [1.1.2] – 2026-02-28

### Changed
- Moved `BlocManagerTheme` section to the top of README for better discoverability.
- Added dedicated Contributing section with PR workflow and bug reporting guidance.

## [1.1.1] – 2026-02-19

### Changed
- Updated README with `BlocManagerTheme` usage guide, `BlocManagerThemeData` fields table, resolution priority chain, and corrected section numbering.
- Updated installation snippet to `^1.1.0`.

## [1.1.0] – 2026-02-19

### Added
- `BlocManagerTheme` — an `InheritedWidget` that sets app-wide defaults for loading widget, loading colour, error handler, and success handler in one place.
- `BlocManagerThemeData` — holds the configuration values.
- `BlocManager.showResultErrorNotifications` and `showResultSuccessNotifications` are now `bool?`; `null` inherits from the nearest `BlocManagerTheme`.
- `BlocManager` error/success resolution priority: instance callback → theme callback → built-in snackbar.

## [1.0.2] – 2026-02-19

### Changed
- `BlocManager` now detects Firebase/Firestore error patterns (missing index, permission denied, document not found) and logs enhanced debug messages automatically.

## [1.0.1] – 2026-02-19

### Changed
- Removed author name from package description (author credits are in README).
- Widened `loading_overlay` constraint to `>=0.3.0 <1.0.0` to avoid version conflicts with host apps.

## [1.0.0] – 2026-02-19

### Added
- `BaseState<T>` sealed class hierarchy (`InitialState`, `LoadingState`, `SuccessState`, `ErrorState`, `LoadedState`, `EmptyState`, and async variants).
- `BaseCubit<S>` and `BaseBloc<E,S>` with `emitLoading()`, `emitSuccess()`, `emitError()`, and `executeAsync()`.
- `BlocManager<B,S>` widget wrapping `BlocConsumer` with automatic loading overlay, error snackbar, and success snackbar.
- `CacheableBlocMixin` – in-memory state caching with TTL support.
- `PaginationBlocMixin` – page-based data loading with cursor tracking.
- `RefreshableBlocMixin` – pull-to-refresh with cooldown and optional auto-refresh timer.
- `BlocManagerLogger` – colour-coded ANSI console logging.
- Example counter app under `example/`.
