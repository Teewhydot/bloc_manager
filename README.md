# bloc_manager

[![pub.dev](https://img.shields.io/pub/v/bloc_manager.svg)](https://pub.dev/packages/bloc_manager)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A Flutter BLoC management package that
eliminates boilerplate state-management code by providing a ready-made sealed-state
hierarchy, a declarative `BlocManager` widget, and reusable mixins for caching,
pagination, and pull-to-refresh.

- **`BaseState<T>`** – sealed state hierarchy (`InitialState`, `LoadingState`, `SuccessState`, `ErrorState`, `LoadedState`, `EmptyState` and async variants).
- **`BaseCubit<S>` / `BaseBloc<E,S>`** – base classes with `emitLoading()`, `emitSuccess()`, `emitError()`, and `executeAsync()` helpers.
- **`BlocManager<B,S>`** – a `BlocConsumer` wrapper that automatically shows loading overlays, error snackbars, and success snackbars.
- **`LoadingConfig`** – pluggable loading indicator styles: full-screen overlay, bottom sheet, top progress bar, and frosted glass.
- **`SkeletonConfig` / `InlineSkeleton`** – shimmer-animated skeleton placeholders for smooth loading states.
- **`BlocManagerTheme`** – app-wide branding for loading, error, and success behaviour.
- **Mixins** – `CacheableBlocMixin`, `PaginationBlocMixin`, `RefreshableBlocMixin`.

---

## Installation

```yaml
dependencies:
  bloc_manager: ^1.4.0
```

```sh
flutter pub get
```

Or via a local path during development:

```yaml
dependencies:
  bloc_manager:
    path: ../bloc_manager
```

---

## How to Use

### 1 · `BlocManagerTheme` — app-wide branding

Instead of repeating `loadingConfig`, `onError`, and `onSuccess` on every `BlocManager` instance,
set them once at the app root and have every instance inherit automatically.

```dart
// In MyApp.build() — wrap your MaterialApp / GetMaterialApp
BlocManagerTheme(
  data: BlocManagerThemeData(
    // Choose a global loading style
    loadingConfig: const FullScreenLoadingConfig(
      loadingWidget: SpinKitFoldingCube(color: Colors.white, size: 50.0),
      overlayColor: Color(0x4D2196F3), // blue at ~30% opacity
    ),

    // Global shimmer colours for skeleton loading
    skeletonBaseColor: Colors.grey[300],
    skeletonHighlightColor: Colors.grey[100],

    onError: (context, message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      );
    },
    onSuccess: (context, message) {
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.success,
          ),
        );
      }
    },
  ),
  child: MaterialApp(…),
)
```

Now every `BlocManager` in the tree will use these handlers without any extra configuration.

#### `BlocManagerThemeData` fields

| Field | Type | Default | Description |
|---|---|---|---|
| `loadingConfig` | `LoadingConfig?` | `null` | Global loading indicator style — falls back to `FullScreenLoadingConfig` |
| `skeletonConfig` | `SkeletonConfig?` | `null` | Global skeleton placeholder configuration |
| `skeletonBaseColor` | `Color?` | `null` | Global shimmer base colour (default: `Colors.grey[300]`) |
| `skeletonHighlightColor` | `Color?` | `null` | Global shimmer highlight colour (default: `Colors.grey[100]`) |
| `onError` | `void Function(BuildContext, String)?` | `null` | Global error handler — replaces the built-in red snackbar |
| `onSuccess` | `void Function(BuildContext, String?)?` | `null` | Global success handler — replaces the built-in green snackbar |
| `showResultErrorNotifications` | `bool` | `true` | Show error notifications when no `onError` is set |
| `showResultSuccessNotifications` | `bool` | `false` | Show success notifications when no `onSuccess` is set |

#### Resolution priority

For each setting, `BlocManager` resolves in this order:

1. **Instance param** — explicit value passed directly to the `BlocManager` widget
2. **`BlocManagerTheme`** — value from the nearest `BlocManagerTheme` ancestor
3. **Built-in default** — package default (e.g. `FullScreenLoadingConfig` for loading, red snackbar for errors)

#### Per-instance overrides still work

```dart
// Silence error notifications for this one silent / root observer
BlocManager<AuthCubit, BaseState<AuthData>>(
  bloc: sl<AuthCubit>(),
  showResultErrorNotifications: false,
  showLoadingIndicator: false,
  child: child,
)

// Active screen — theme handles the error UI automatically
BlocManager<AuthCubit, BaseState<AuthData>>(
  bloc: sl<AuthCubit>(),
  onSuccess: (ctx, _) => Navigator.pushReplacementNamed(ctx, '/home'),
  child: LoginForm(),
)
```

---

### 2 · Loading Config styles

Pass a typed `LoadingConfig` to `BlocManager.loadingConfig` (or set it globally via `BlocManagerThemeData.loadingConfig`) to choose how the loading indicator is presented.

#### `FullScreenLoadingConfig` (default)

A full-screen overlay that obscures the content underneath.

```dart
BlocManager<AuthCubit, BaseState<AuthData>>(
  bloc: cubit,
  loadingConfig: const FullScreenLoadingConfig(
    loadingWidget: SpinKitCircle(color: Colors.white, size: 50.0),
    overlayColor: Color(0x4D2196F3), // blue tint
  ),
  child: MyScreen(),
)
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `loadingWidget` | `Widget?` | `SpinKitCircle` | Custom spinner widget |
| `overlayColor` | `Color?` | Primary at 50% opacity | Tint colour for the overlay |

#### `BottomSheetLoadingConfig`

A slide-up bottom sheet anchored to the bottom of the screen. Keeps the existing content visible underneath.

```dart
BlocManager<TodosCubit, BaseState<List<Todo>>>(
  bloc: cubit,
  loadingConfig: const BottomSheetLoadingConfig(
    overlayColor: Colors.transparent,
    trailingWidget: Icon(Icons.check_circle, color: Colors.green),
  ),
  child: TodosList(),
)
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `loadingWidget` | `Widget?` | `BlocBottomSheetWidget` | Custom widget inside the bottom sheet |
| `overlayColor` | `Color?` | Primary at 50% opacity | Screen tint behind the bottom sheet |
| `trailingWidget` | `Widget?` | `null` | Trailing widget on the right (ignored when `loadingWidget` is set) |

#### `TopProgressBarLoadingConfig`

A thin linear progress bar pinned to the top edge (YouTube-style). Non-intrusive — keeps the full UI visible.

```dart
BlocManager<PostsCubit, BaseState<List<Post>>>(
  bloc: cubit,
  loadingConfig: const TopProgressBarLoadingConfig(
    progressColor: Colors.teal,
  ),
  child: PostsList(),
)
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `progressColor` | `Color?` | Theme primary | Colour of the progress bar |

#### `FrostedGlassLoadingConfig`

A frosted glass (blurred backdrop) loading overlay using `BackdropFilter`.

```dart
BlocManager<PostsCubit, BaseState<List<Post>>>(
  bloc: cubit,
  loadingConfig: const FrostedGlassLoadingConfig(
    sigmaX: 12.0,
    sigmaY: 12.0,
    overlayColor: Color(0x26FFFFFF), // white at ~15%
  ),
  child: PostsList(),
)
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `loadingWidget` | `Widget?` | `SpinKitCircle` | Custom spinner widget |
| `overlayColor` | `Color?` | White at 15% opacity | Tint colour for the glass overlay |
| `sigmaX` | `double` | `12.0` | Blur sigma on the X axis |
| `sigmaY` | `double` | `12.0` | Blur sigma on the Y axis |

---

### 3 · States — no subclassing needed

You do not need to declare any custom state classes. Just pick from the sealed hierarchy:

```dart
import 'package:bloc_manager/bloc_manager.dart';

// Loading
emit(const LoadingState<User>());

// Data ready
emit(LoadedState<User>(data: user, lastUpdated: DateTime.now()));

// Write operation done
emit(SuccessState<User>(successMessage: 'Profile saved!'));

// Failed
emit(ErrorState<User>(errorMessage: 'Network error', errorCode: 'NET_01'));

// Empty result
emit(const EmptyState<User>(message: 'No results found'));
```

---

### 4 · `BaseCubit` — async made simple

```dart
class UserCubit extends BaseCubit<BaseState<User>> {
  UserCubit(this._repo) : super(const InitialState());
  final UserRepository _repo;

  // executeAsync: emits LoadingState → runs action → emits result
  Future<void> loadUser(String id) => executeAsync(
    () => _repo.fetchUser(id),
    onSuccess: (user) =>
        LoadedState(data: user, lastUpdated: DateTime.now()),
    loadingMessage: 'Loading profile…',
  );

  Future<void> updateUser(String name) => executeAsync(
    () => _repo.update(name),
    successMessage: 'Profile updated!', // auto emits SuccessState
  );

  // Fine-grained helpers are also available directly:
  void somethingFailed(String msg) =>
      emitError(msg, errorCode: 'E01');
}
```

`executeAsync` signature:

```dart
Future<void> executeAsync<T>(
  Future<T> Function() action, {
  State Function(T result)? onSuccess,  // return your custom state
  void Function(Exception e)? onError,  // override error handling
  String? loadingMessage,
  String? successMessage,
})
```

---

### 5 · `BlocManager` — declarative UI wiring

Replaces the manual `BlocConsumer` + loading-check + snackbar boilerplate:

#### With `onSuccess` / `onError` callbacks

```dart
BlocManager<UserCubit, BaseState<User>>(
  bloc: context.read<UserCubit>(),
  onSuccess: (ctx, state) => Navigator.of(ctx).pop(),
  onError: (ctx, state) => MyAnalytics.log(state.errorMessage),
  child: UserFormWidget(),
)
```

#### With `builder` — direct state-driven UI

```dart
BlocManager<UserCubit, BaseState<User>>(
  bloc: context.read<UserCubit>(),
  builder: (context, state) {
    if (state is EmptyState) return const EmptyView();
    if (state is LoadedState<User>) return DataView(state.data!);
    return const SizedBox.shrink();
  },
  child: const SizedBox.shrink(), // ignored when builder is provided
)
```

#### With skeleton loading

```dart
BlocManager<PostsCubit, BaseState<List<Post>>>(
  bloc: cubit,
  skeletonConfig: SkeletonConfig(
    builder: (context, index) => const PostCardSkeleton(),
    count: 6,
    orientation: SkeletonOrientation.list,
    spacing: 6.0,
  ),
  showLoadingIndicator: false, // disable overlay when using skeletons
  child: PostsList(),
)
```

This auto-wires:
- Skeleton placeholders during `LoadingState` / `InitialState` (when `skeletonConfig` is set)
- Full-screen spinner during `LoadingState` (when `showLoadingIndicator` is true)
- Red snackbar on `ErrorState` (disable with `showResultErrorNotifications: false`)
- Green snackbar on `SuccessState` (opt-in with `showResultSuccessNotifications: true`)
- `onSuccess` called for both `SuccessState` and `LoadedState`

#### All parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `bloc` | `B` | required | The BLoC/Cubit to observe |
| `child` | `Widget` | required | Screen content |
| `builder` | `(ctx, state) → Widget?` | `null` | Custom builder; replaces `child` when set |
| `listener` | `(ctx, state) → void?` | `null` | Fires on every meaningful state change |
| `onSuccess` | `(ctx, state) → void?` | `null` | Called on `SuccessState` or `LoadedState` |
| `onError` | `(ctx, state) → void?` | `null` | Called on `ErrorState` |
| `showLoadingIndicator` | `bool` | `true` | Full-screen overlay during `LoadingState` |
| `showResultErrorNotifications` | `bool?` | `null` | Auto red snackbar on error; `null` inherits from `BlocManagerTheme` |
| `showResultSuccessNotifications` | `bool?` | `null` | Auto green snackbar on success; `null` inherits from `BlocManagerTheme` |
| `loadingConfig` | `LoadingConfig?` | `null` | Loading indicator style; `null` inherits from `BlocManagerTheme` |
| `skeletonConfig` | `SkeletonConfig?` | `null` | Skeleton placeholder config; `null` inherits from `BlocManagerTheme` |
| `skeletonBaseColor` | `Color?` | `null` | Shimmer base colour; `null` inherits from theme (default: `Colors.grey[300]`) |
| `skeletonHighlightColor` | `Color?` | `null` | Shimmer highlight colour; `null` inherits from theme (default: `Colors.grey[100]`) |
| `enablePullToRefresh` | `bool` | `false` | Wraps content in `RefreshIndicator` |
| `onRefresh` | `Future<void> Function()?` | `null` | Pull-to-refresh callback |
| `errorSnackbarColor` | `Color` | `#B00020` | Error snackbar background |
| `successSnackbarColor` | `Color` | `#388E3C` | Success snackbar background |

---

### 6 · Skeleton Loading

Skeleton placeholders give users a visual preview of the layout while data is loading. `bloc_manager` supports two approaches: **full-screen skeletons** via `BlocManager` and **inline skeletons** for fine-grained control.

#### `SkeletonConfig` — full-screen skeleton placeholders

Pass a `SkeletonConfig` to `BlocManager.skeletonConfig` to show shimmer-animated skeleton items during loading states.

```dart
BlocManager<PostsCubit, BaseState<List<Post>>>(
  bloc: cubit,
  skeletonConfig: SkeletonConfig(
    builder: (context, index) => const PostCardSkeleton(),
    count: 6,
    orientation: SkeletonOrientation.list,
    spacing: 6.0,
  ),
  showLoadingIndicator: false, // disable overlay when using skeletons
  child: const SizedBox.shrink(),
  builder: (context, state) {
    if (state is LoadedState<List<Post>>) {
      return PostList(state.data!);
    }
    return const SizedBox.shrink();
  },
)
```

#### `SkeletonOrientation`

Choose from four layout orientations:

```dart
// Vertical list (default)
SkeletonOrientation.list

// Grid layout
SkeletonOrientation.grid

// Horizontal scrollable row
SkeletonOrientation.row

// Flowing wrap layout
SkeletonOrientation.wrap
```

**Grid example:**

```dart
SkeletonConfig(
  builder: (context, index) => const ProductCardSkeleton(),
  count: 8,
  orientation: SkeletonOrientation.grid,
  crossAxisCount: 2,
  spacing: 12.0,
)
```

**Horizontal row example:**

```dart
SkeletonConfig(
  builder: (context, index) => const HorizontalCardSkeleton(),
  count: 5,
  orientation: SkeletonOrientation.row,
  spacing: 12.0,
)
```

#### `SkeletonConfig` fields

| Parameter | Type | Default | Description |
|---|---|---|---|
| `builder` | `Widget Function(BuildContext, int)` | required | Returns a skeleton placeholder widget for the given index |
| `count` | `int` | required | Number of skeleton items to display |
| `orientation` | `SkeletonOrientation` | `list` | Layout orientation |
| `crossAxisCount` | `int?` | `null` | Number of columns for `grid` orientation |
| `spacing` | `double` | `8.0` | Spacing between skeleton items |
| `baseColor` | `Color?` | `null` | Shimmer base colour; inherits from theme |
| `highlightColor` | `Color?` | `null` | Shimmer highlight colour; inherits from theme |
| `enableShimmer` | `bool` | `true` | Set to `false` for static placeholders without animation |

#### Custom shimmer colours

Override shimmer colours per-instance or globally via `BlocManagerTheme`:

```dart
// Per-instance
BlocManager<FeedCubit, BaseState<List<Article>>>(
  bloc: cubit,
  skeletonConfig: SkeletonConfig(
    builder: (context, index) => const ArticleSkeleton(),
    count: 5,
    orientation: SkeletonOrientation.list,
  ),
  skeletonBaseColor: Colors.blue.withValues(alpha: 0.15),
  skeletonHighlightColor: Colors.blue.withValues(alpha: 0.4),
  child: ArticleList(),
)

// Global (via theme)
BlocManagerTheme(
  data: BlocManagerThemeData(
    skeletonBaseColor: Colors.blue.withValues(alpha: 0.15),
    skeletonHighlightColor: Colors.blue.withValues(alpha: 0.4),
  ),
  child: MaterialApp(…),
)
```

#### `InlineSkeleton` — fine-grained skeleton control

Use `InlineSkeleton` to selectively skeletonize individual parts of your UI while keeping the rest visible and interactive.

```dart
BlocBuilder<UserCubit, BaseState<User>>(
  builder: (context, state) {
    final isLoading = state.isLoading;
    return Row(
      children: [
        // Avatar — independently skeletonised
        InlineSkeleton(
          isLoading: isLoading,
          skeleton: const CircleAvatar(radius: 30, backgroundColor: Colors.white),
          child: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(user.avatarUrl),
          ),
        ),
        const SizedBox(width: 16),
        // Text body — independently skeletonised
        Expanded(
          child: InlineSkeleton(
            isLoading: isLoading,
            skeleton: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: 160, color: Colors.white),
                const SizedBox(height: 8),
                Container(height: 12, width: double.infinity, color: Colors.white),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(user.email, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ],
    );
  },
)
```

`InlineSkeleton` fields:

| Parameter | Type | Default | Description |
|---|---|---|---|
| `isLoading` | `bool` | required | Whether to show the skeleton placeholder |
| `skeleton` | `Widget` | required | The skeleton widget shown while loading |
| `child` | `Widget` | required | The real content widget shown when loaded |
| `baseColor` | `Color?` | `null` | Shimmer base colour; inherits from theme |
| `highlightColor` | `Color?` | `null` | Shimmer highlight colour; inherits from theme |
| `enableShimmer` | `bool` | `true` | Set to `false` for static placeholders |

---

### 7 · `PaginationBlocMixin` — infinite scroll

```dart
class ProductsCubit extends BaseCubit<BaseState<List<Product>>>
    with PaginationBlocMixin<Product, BaseState<List<Product>>> {

  Future<void> load() async {
    initializePagination(pageSize: 20);
    await loadFirstPage();
  }

  Future<void> loadMore() => loadNextPage(); // no-op at last page

  @override
  Future<PaginatedResult<Product>> onLoadPage({
    required int page, required int pageSize,
  }) => _repo.fetchProducts(page: page, pageSize: pageSize);

  @override
  Future<void> onPageLoaded(PaginatedResult<Product> result, int page) async {
    final prev = state.data ?? [];
    emit(LoadedState(
      data: page == 1 ? result.items : [...prev, ...result.items],
      lastUpdated: DateTime.now(),
    ));
    updatePaginationInfo(
      totalItems: result.totalItems,
      hasNextPage: result.hasNextPage,
      loadedPage: page,
    );
  }
}
```

Wire scroll detection:

```dart
NotificationListener<ScrollNotification>(
  onNotification: (n) {
    if (cubit.shouldLoadMore(n.metrics.pixels, n.metrics.maxScrollExtent)) {
      cubit.loadMore();
    }
    return false;
  },
  child: ListView.builder(…),
)
```

---

### 8 · `CacheableBlocMixin` — in-memory TTL cache

```dart
class ProfileCubit extends BaseCubit<BaseState<Profile>>
    with CacheableBlocMixin<BaseState<Profile>> {

  @override String get cacheKey => 'user_profile';
  @override Duration get cacheTimeout => const Duration(minutes: 10);

  @override
  Map<String, dynamic>? stateToJson(BaseState<Profile> state) =>
      state is LoadedState ? (state.data as Profile).toJson() : null;

  @override
  BaseState<Profile>? stateFromJson(Map<String, dynamic> json) =>
      LoadedState(data: Profile.fromJson(json), lastUpdated: DateTime.now());

  Future<void> load() async {
    final cached = await loadStateFromCache();
    if (cached != null) { emit(cached); return; }
    await executeAsync(_repo.fetchProfile,
      onSuccess: (p) {
        final s = LoadedState(data: p, lastUpdated: DateTime.now());
        saveStateToCache(s);
        return s;
      },
    );
  }
}
```

---

### 9 · `RefreshableBlocMixin` — pull-to-refresh + auto-refresh

```dart
class FeedCubit extends BaseCubit<BaseState<List<Article>>>
    with RefreshableBlocMixin<BaseState<List<Article>>> {

  @override
  Future<void> onRefresh() async {
    final articles = await _repo.fetchLatest();
    emit(LoadedState(data: articles, lastUpdated: DateTime.now()));
  }

  // Optional: refresh every 5 minutes while widget is alive.
  @override bool get autoRefreshEnabled => true;
  @override Duration get autoRefreshInterval => const Duration(minutes: 5);

  @override
  Future<void> close() {
    disposeRefreshable(); // cancel timer
    return super.close();
  }
}
```

Wire to `BlocManager`:

```dart
BlocManager<FeedCubit, BaseState<List<Article>>>(
  bloc: cubit,
  enablePullToRefresh: true,
  onRefresh: cubit.performRefresh,
  child: ArticleList(),
)
```

---

## `BaseState<T>` Reference

```
BaseState<T>                ─ isInitial / isLoading / isLoaded /
│                             isSuccess / isError / hasData
├── InitialState<T>
├── LoadingState<T>           message?, progress?
├── LoadedState<T>            data, lastUpdated?, isFromCache
├── SuccessState<T>           successMessage, metadata?
├── ErrorState<T>             errorMessage, errorCode?, exception?, stackTrace?
├── EmptyState<T>             message?
│
│   ── Async (stream / real-time) variants ──
├── AsyncLoadingState<T>      data? (stale), message?, progress?, isRefreshing
├── AsyncLoadedState<T>       data, lastUpdated, isFromCache
└── AsyncErrorState<T>        data? (stale), errorMessage, errorCode?, exception?,
                              isRetryable
```

All states extend `Equatable` and have descriptive `toString()` for logging.

---

## Example App

A comprehensive example app demonstrating all `bloc_manager` features lives in [`example/`](example/).

The example app uses **real public APIs** to showcase production-ready implementations:

| Tab | Feature | API | Demonstrates |
|-----|---------|-----|--------------|
| **Posts** | PaginationBlocMixin | JSONPlaceholder Posts | Infinite scroll pagination with page indicators |
| **Pokemon** | CacheableBlocMixin | PokeAPI | In-memory caching with 10-minute TTL and visual "From Cache" badge |
| **Products** | RefreshableBlocMixin | Fake Store API | Pull-to-refresh + auto-refresh every 30 seconds |
| **Todos** | All BaseState types | JSONPlaceholder Todos | Complete state flow: Initial → Loading → Loaded → Success/Error/Empty |
| **Demo** | LoadingConfig + Skeletons | — | All loading styles (full-screen, bottom-sheet, top-bar, frosted glass) + skeleton layouts (list, grid, row, custom colours, inline) |

### Running the Example

```sh
cd example && flutter pub get && flutter run
```

### What You'll Learn

Each tab is self-contained and demonstrates real-world patterns:

1. **Posts Tab** - Infinite scroll pagination with:
   - `loadFirstPage()` / `loadNextPage()` methods
   - `PaginationInfo` with page numbers and total count
   - Loading indicators for additional pages

2. **Pokemon Tab** - Smart caching with:
   - Cache checking before API calls (search same Pokemon twice)
   - Orange "From Cache" badge indicator
   - Cache TTL (10 minutes)
   - Manual cache controls (restore/clear)

3. **Products Tab** - Refresh capabilities with:
   - Pull-to-refresh gesture support
   - Auto-refresh timer (30 seconds for demo)
   - Refresh cooldown protection
   - "Last updated" timestamp

4. **Todos Tab** - Complete state management with:
   - All 6 BaseState types demonstrated
   - State banner showing current state with color coding
   - SuccessState snackbars on actions
   - Force error button for testing ErrorState

5. **Demo Tab** - Loading and skeleton showcase with:
   - Full-screen overlay, bottom sheet, top progress bar, and frosted glass loading styles
   - List, grid, and horizontal row skeleton layouts
   - Custom shimmer colour configurations
   - InlineSkeleton for fine-grained per-widget skeleton loading

### Architecture

```
example/
├── lib/
│   ├── main.dart                 # BlocManagerTheme setup
│   ├── models/                   # Post, Pokemon, Product, Todo
│   ├── repositories/             # Dio-based API client + repos
│   ├── cubits/                   # All feature cubits
│   ├── screens/                  # Tab screens
│   └── widgets/                  # PokemonCard, LoadingCard, ErrorCard, skeleton widgets
└── README.md                     # Example-specific docs
```

See [`example/README.md`](example/README.md) for detailed implementation notes.

---

## Contributing

Contributions are welcome! If you'd like to contribute to `bloc_manager`, please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please feel free to:
- Report bugs via [GitHub Issues](https://github.com/Teewhydot/bloc_manager/issues)
- Suggest new features or enhancements
- Submit pull requests for bug fixes or new features
- Improve documentation

All contributions are appreciated, and help make this package better for everyone!

---

## Author

Created and maintained by **Abubakar Issa**.

| | |
|---|---|
| 🐙 GitHub | [github.com/Teewhydot/bloc_manager](https://github.com/Teewhydot/bloc_manager) |
| 💼 LinkedIn | [linkedin.com/in/issa-abubakar-a0a200189](https://www.linkedin.com/in/issa-abubakar-a0a200189/) |
| 🌐 Portfolio | [sirteefyapps.com.ng](https://sirteefyapps.com.ng/) |

---

## License

[MIT](LICENSE) © 2026 Abubakar Issa
