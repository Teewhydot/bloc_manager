import 'dart:async';

import 'package:bloc_manager/bloc_manager.dart';
import 'package:bloc_manager_example/models/product.dart';
import 'package:bloc_manager_example/repositories/products_repository.dart';

/// ProductsCubit demonstrates the RefreshableBlocMixin feature.
/// It supports pull-to-refresh and auto-refreshes every 30 seconds.
class ProductsCubit extends BaseCubit<BaseState<List<Product>>>
    with RefreshableBlocMixin<BaseState<List<Product>>> {
  final ProductsRepository _repository;
  DateTime? _lastRefreshTimeLocal;

  ProductsCubit({ProductsRepository? repository})
      : _repository = repository ?? ProductsRepository(),
        super(const InitialState()) {
    // Load initial data
    loadProducts();

    // Start auto-refresh timer (every 30 seconds for demo)
    startAutoRefresh();
  }

  List<Product> get products => state.data ?? [];

  /// Load products for the first time
  Future<void> loadProducts() async {
    emit(const LoadingState<List<Product>>(message: 'Loading products...'));

    try {
      final products = await _repository.fetchProducts();
      _lastRefreshTimeLocal = DateTime.now();
      emit(LoadedState<List<Product>>(
        data: products,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emitError('Failed to load products. Please check your connection.',
          exception: e as Exception?);
    }
  }

  @override
  Future<void> onRefresh() async {
    // Don't show full-screen loading during refresh
    // Store current data to show during refresh
    final currentData = state.data;

    try {
      final products = await _repository.fetchProducts();
      _lastRefreshTimeLocal = DateTime.now();
      emit(LoadedState<List<Product>>(
        data: products,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      // On error, keep showing the current data with a snackbar (handled by BlocManager)
      if (currentData != null) {
        emit(LoadedState<List<Product>>(
          data: currentData,
          lastUpdated: _lastRefreshTimeLocal,
        ));
      }
      emitError('Refresh failed. Showing cached data.',
          exception: e as Exception?);
    }
  }

  /// Filter products by category
  Future<void> filterByCategory(String category) async {
    emit(const LoadingState<List<Product>>(message: 'Filtering products...'));

    try {
      if (category == 'All') {
        await loadProducts();
      } else {
        final products = await _repository.fetchProductsByCategory(category);
        _lastRefreshTimeLocal = DateTime.now();
        emit(LoadedState<List<Product>>(
          data: products,
          lastUpdated: DateTime.now(),
        ));
      }
    } catch (e) {
      emitError('Failed to filter products.', exception: e as Exception?);
    }
  }

  @override
  Future<void> onRefreshError(Object error, StackTrace stackTrace) async {
    // Error is handled in onRefresh
  }

  // Auto-refresh configuration
  @override
  bool get autoRefreshEnabled => true;

  @override
  Duration get autoRefreshInterval => const Duration(seconds: 30);

  @override
  Future<void> close() {
    disposeRefreshable();
    return super.close();
  }

  /// Public method to manually trigger refresh (wraps protected mixin method)
  Future<void> manualRefresh() => forceRefresh();

  /// Get formatted time since last refresh
  String get timeSinceLastRefresh {
    if (_lastRefreshTimeLocal == null) return 'Never';
    final diff = DateTime.now().difference(_lastRefreshTimeLocal!);
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else {
      return '${diff.inHours}h ago';
    }
  }

  /// Get refresh cooldown remaining
  String get cooldownRemaining {
    final remaining = refreshCooldownRemaining;
    if (remaining == null) return '';
    final seconds = remaining.inSeconds;
    return '($seconds s cooldown)';
  }
}
