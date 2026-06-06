
## [1.5.3] - 2026-06-06

### Fixed
- `SuccessState` now extends `DataState<T>` instead of `BaseState<T>`, allowing it to inherit and hold `data`. This prevents `BlocManager` from clearing out existing data when rendering a success state.

## [1.5.2] - 2026-06-01

### Changed
- Updated `pubspec.yaml` description to be within the recommended 60–180 character limit for pub.dev listings.
- Upgraded `bloc` constraint to `^9.0.0` and `flutter_bloc` to `^9.0.0` to support latest versions.
- Upgraded `bloc_test` dev dependency to `^10.0.0` for compatibility with bloc 9.x.

## [1.5.1] - 2026-06-01

### Fixed
- `BottomSheetLoadingWrapper` no longer throws "setState() or markNeedsBuild() called during build" when `loadingWidget` or `overlayColor` changes while the overlay is visible. The overlay rebuild is now deferred to the next frame.

## [1.5.0] - 2026-06-01

### Changed
- Example app switched to dark mode for better loading type testing.
- Updated README with comprehensive documentation for LoadingConfig styles, SkeletonConfig, InlineSkeleton, and all latest features.

## [1.4.0] - 2026-05-29

### Added
- **Skeleton loading support** with shimmer animation — `BlocManager` now shows skeleton placeholders during `LoadingState`/`InitialState`.
- `SkeletonConfig` class to configure skeleton layout (list, grid, row, wrap), item count, spacing, and shimmer colours.
- `SkeletonListWidget` — renders skeleton items in non-scrollable layouts for safe nesting inside any parent widget.
- `BlocManagerThemeData.skeletonBaseColor` and `.skeletonHighlightColor` for app-wide shimmer colour defaults.
- `BlocManager.skeletonConfig`, `.skeletonBaseColor`, `.skeletonHighlightColor` properties for per-instance skeleton configuration.
- `BlocManager.builder` property — direct state-driven builder replacing the need for a nested `BlocBuilder`.
- `showLoadingIndicator: false` support — disables the loading overlay when skeletons are used instead.
- Comprehensive skeleton demo in `DemoScreen` with list, grid, row, and custom-colour sections.
- Custom skeleton widgets for all example screens (`PostCardSkeleton`, `ProductCardSkeleton`, `TodoCardSkeleton`, `PokemonCardSkeleton`).

### Changed
- Example screens (`Posts`, `Products`, `Todos`, `Pokemon`) now use shimmer skeletons instead of `CircularProgressIndicator` for loading states.
- Status bars and search bars moved outside `BlocManager` in example screens so skeleton only covers the content area.
- Nested `BlocBuilder` inside `BlocManager.child` replaced with `BlocManager.builder` property throughout example app.

## [1.3.0] - 2026-05-27

### Added
- `LoadingIndicatorStyle` enum with `fullScreen` (default) and `bottomSheet` options for configurable loading UI.
- `BlocBottomSheetWidget` — a bottom-sheet style loading indicator anchored at the bottom of the screen.
- `BlocManagerThemeData.loadingStyle` — configure the loading indicator style app-wide.
- `BlocManagerThemeData.bottomSheetTrailingWidget` — optional trailing widget for bottom-sheet loading indicators.
- Example `DemoScreen` showcasing both full-screen and bottom-sheet loading styles.

### Changed
- `BlocManager` now respects the configured `loadingStyle` from theme data.
- `TodosScreen` in the example app updated to use bottom-sheet loading style.
- `LoadingCard` now uses `CircularProgressIndicator.adaptive()` for better platform integration.
- Wrapped loading container in `Material` widget to ensure proper styling context.

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.2] - 2026-03-23

### Changed
- Updated package metadata and documentation wording in preparation for republish.

## [1.2.1] - 2026-03-23

### Fixed
- `BlocManager` loading overlay now keeps a stable widget wrapper and toggles `isLoading` instead of conditionally inserting/removing the wrapper. This prevents child subtree disposal and state loss (for example, `TextEditingController` values clearing during loading).

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
