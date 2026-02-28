# bloc_manager

[![pub.dev](https://img.shields.io/pub/v/bloc_manager.svg)](https://pub.dev/packages/bloc_manager)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A Flutter BLoC management package by **[Abubakar Issa](https://sirteefyapps.com.ng/)** that
eliminates boilerplate state-management code by providing a ready-made sealed-state
hierarchy, a declarative `BlocManager` widget, and reusable mixins for caching,
pagination, and pull-to-refresh.

- **`BaseState<T>`** – sealed state hierarchy (`InitialState`, `LoadingState`, `SuccessState`, `ErrorState`, `LoadedState`, `EmptyState` and async variants).
- **`BaseCubit<S>` / `BaseBloc<E,S>`** – base classes with `emitLoading()`, `emitSuccess()`, `emitError()`, and `executeAsync()` helpers.
- **`BlocManager<B,S>`** – a `BlocConsumer` wrapper that automatically shows loading overlays, error snackbars, and success snackbars.
- **Mixins** – `CacheableBlocMixin`, `PaginationBlocMixin`, `RefreshableBlocMixin`.

---

## Installation

```yaml
dependencies:
  bloc_manager: ^1.1.0
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

Instead of repeating `loadingColor`, `onError`, and `onSuccess` on every `BlocManager` instance,
set them once at the app root and have every instance inherit automatically.

```dart
// In MyApp.build() — wrap your MaterialApp / GetMaterialApp
BlocManagerTheme(
  data: BlocManagerThemeData(
    loadingColor: AppColors.primary.withValues(alpha: 0.5),
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
| `loadingWidget` | `Widget?` | `null` | Global spinner (default: `SpinKitCircle`) |
| `loadingColor` | `Color?` | `null` | Global overlay tint colour |
| `onError` | `void Function(BuildContext, String)?` | `null` | Global error handler — replaces the built-in red snackbar |
| `onSuccess` | `void Function(BuildContext, String?)?` | `null` | Global success handler — replaces the built-in green snackbar |
| `showResultErrorNotifications` | `bool` | `true` | Show error notifications when no `onError` is set |
| `showResultSuccessNotifications` | `bool` | `false` | Show success notifications when no `onSuccess` is set |

#### Resolution priority

For each setting, `BlocManager` resolves in this order:

1. **Instance param** — explicit value passed directly to the `BlocManager` widget
2. **`BlocManagerTheme`** — value from the nearest `BlocManagerTheme` ancestor
3. **Built-in default** — package default (e.g. red snackbar for errors)

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

### 2 · States — no subclassing needed

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

### 3 · `BaseCubit` — async made simple

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

### 4 · `BlocManager` — declarative UI wiring

Replaces the manual `BlocConsumer` + loading-check + snackbar boilerplate:

```dart
BlocManager<UserCubit, BaseState<User>>(
  bloc: context.read<UserCubit>(),
  onSuccess: (ctx, state) => Navigator.of(ctx).pop(),
  onError: (ctx, state) => MyAnalytics.log(state.errorMessage),
  child: UserFormWidget(),
)
```

This auto-wires:
- Full-screen spinner during `LoadingState`
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
| `enablePullToRefresh` | `bool` | `false` | Wraps content in `RefreshIndicator` |
| `onRefresh` | `Future<void> Function()?` | `null` | Pull-to-refresh callback |
| `loadingWidget` | `Widget?` | `null` | Custom spinner (default: `SpinKitCircle`) |
| `loadingColor` | `Color?` | `null` | Overlay tint colour |
| `errorSnackbarColor` | `Color` | `#B00020` | Error snackbar background |
| `successSnackbarColor` | `Color` | `#388E3C` | Success snackbar background |

---

### 5 · `PaginationBlocMixin` — infinite scroll

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

### 6 · `CacheableBlocMixin` — in-memory TTL cache

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

### 7 · `RefreshableBlocMixin` — pull-to-refresh + auto-refresh

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
├── ErrorState<T>             errorMessage, errorCode?, exception?
├── EmptyState<T>             message?
│
│   ── Async (stream / real-time) variants ──
├── AsyncLoadingState<T>      data? (stale), message?, isRefreshing
├── AsyncLoadedState<T>       data, lastUpdated, isFromCache
└── AsyncErrorState<T>        data? (stale), errorMessage, isRetryable
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

### Architecture

```
example/
├── lib/
│   ├── main.dart                 # BlocManagerTheme setup
│   ├── models/                   # Post, Pokemon, Product, Todo
│   ├── repositories/             # Dio-based API client + repos
│   ├── cubits/                   # All feature cubits
│   ├── screens/                  # Tab screens
│   └── widgets/                  # PokemonCard, LoadingCard, ErrorCard
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
| 🌐 Portfolio | [sirteefyapps.com.ng](https://sirteefyapps.com.ng/)

---

## License

[MIT](LICENSE) © 2026 Abubakar Issa
