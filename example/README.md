# Bloc Manager Example App

A comprehensive Flutter example app demonstrating all features of the `bloc_manager` package using real public APIs.

## Features Demonstrated

### 1. PaginationBlocMixin (Posts Tab)
- Infinite scroll pagination
- Page-based data loading
- Pagination metadata (current page, total pages, etc.)
- Loading indicators for additional pages

**API Used:** [JSONPlaceholder Posts](https://jsonplaceholder.typicode.com/posts)

**Key Features:**
- `loadFirstPage()` - Initialize pagination and load first page
- `loadNextPage()` - Load next page when scrolling
- `shouldLoadMore()` - Detect when to trigger next page load
- `updatePaginationInfo()` - Update pagination metadata

### 2. CacheableBlocMixin (Pokemon Tab)
- In-memory caching with TTL (Time To Live)
- Cache serialization/deserialization
- Cache age tracking
- Manual cache clearing

**API Used:** [PokeAPI](https://pokeapi.co/api/v2/pokemon/)

**Key Features:**
- `saveStateToCache()` - Save state to in-memory cache
- `loadStateFromCache()` - Load cached state
- `clearCache()` - Clear cached data
- `getCacheAge()` - Get age of cached data
- Custom `cacheTimeout` (10 minutes)

### 3. RefreshableBlocMixin (Products Tab)
- Pull-to-refresh functionality
- Auto-refresh timer (30 seconds)
- Refresh cooldown protection
- Optimistic UI during refresh

**API Used:** [Fake Store API](https://fakestoreapi.com/products)

**Key Features:**
- `performRefresh()` - Trigger refresh with cooldown protection
- `forceRefresh()` - Bypass cooldown
- `startAutoRefresh()` / `stopAutoRefresh()` - Control auto-refresh timer
- `isRefreshing` - Check if refresh is in progress
- Custom `autoRefreshInterval` (30 seconds)

### 4. All BaseState Types (Todos Tab)
- `InitialState` - Starting state
- `LoadingState` - Loading in progress
- `LoadedState` - Data loaded successfully
- `SuccessState` - Operation completed (with snackbar)
- `ErrorState` - Operation failed (with snackbar)
- `EmptyState` - No data available
- `executeAsync()` helper - Automatic loading/success/error handling

**API Used:** [JSONPlaceholder Todos](https://jsonplaceholder.typicode.com/todos)

**Key Features:**
- Checkbox to toggle todo completion (shows `SuccessState`)
- Delete button with confirmation
- Search/filter todos (demonstrates `EmptyState`)
- Force error button (demonstrates `ErrorState`)

## Architecture

### Project Structure
```
example/
├── lib/
│   ├── main.dart                 # App entry with BlocManagerTheme
│   ├── models/                   # Data models for API responses
│   │   ├── post.dart
│   │   ├── pokemon.dart
│   │   ├── product.dart
│   │   └── todo.dart
│   ├── repositories/             # API repository layer
│   │   ├── api_client.dart       # Dio-based HTTP client
│   │   ├── posts_repository.dart
│   │   ├── pokemon_repository.dart
│   │   ├── products_repository.dart
│   │   └── todos_repository.dart
│   ├── cubits/                   # BLoC/Cubit implementations
│   │   ├── posts/
│   │   ├── pokemon/
│   │   ├── products/
│   │   └── todos/
│   ├── screens/                  # UI screens
│   │   ├── home_screen.dart      # Tab navigation
│   │   ├── posts_screen.dart
│   │   ├── pokemon_screen.dart
│   │   ├── products_screen.dart
│   │   └── todos_screen.dart
│   └── widgets/                  # Reusable widgets
│       ├── loading_card.dart
│       ├── error_card.dart
│       └── pokemon_card.dart
└── pubspec.yaml
```

### BlocManagerTheme Setup

The app uses `BlocManagerTheme` to provide consistent loading/success/error UI across all screens:

```dart
BlocManagerTheme(
  data: BlocManagerThemeData(
    loadingWidget: const SpinKitFoldingCube(color: Colors.white),
    loadingColor: Colors.blue.withValues(alpha: 0.3),
    onError: (context, message) => /* custom error snackbar */,
    onSuccess: (context, message) => /* custom success snackbar */,
    showResultErrorNotifications: true,
    showResultSuccessNotifications: true,
  ),
  child: MaterialApp(...),
)
```

## Running the Example

1. Install dependencies:
   ```bash
   cd example
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

3. Test each feature:
   - **Posts Tab**: Scroll to bottom to trigger pagination
   - **Pokemon Tab**: Search "pikachu" twice to see cached data indicator
   - **Products Tab**: Pull down to refresh, wait for auto-refresh
   - **Todos Tab**: Tap refresh to load, complete todos for success snackbars

## Learning Resources

Each screen is self-contained and demonstrates a specific feature. You can:

1. **Copy code directly** - Each screen can be used as a standalone example
2. **Read inline comments** - Code is documented with explanations
3. **Experiment** - Try modifying parameters like page size, cache TTL, etc.

## Public APIs Used

- **[JSONPlaceholder](https://jsonplaceholder.typicode.com/)** - Fake REST API for testing
- **[PokeAPI](https://pokeapi.co/)** - Pokemon data API
- **[Fake Store API](https://fakestoreapi.com/)** - Fake e-commerce data

## Dependencies

- `bloc_manager` - The package being demonstrated
- `dio` - HTTP client for API calls
- `equatable` - Value equality for models
- `flutter_spinkit` - Custom loading indicators

## License

This example code is part of the bloc_manager package. See the main package LICENSE for details.
