import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_manager/bloc_manager.dart';
import 'package:bloc_manager_example/cubits/products/products_cubit.dart';

/// Products Screen demonstrates RefreshableBlocMixin.
/// Shows products with pull-to-refresh and auto-refresh capabilities.
class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductsCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products (Refresh)'),
        actions: [
          // Manual refresh button
          BlocBuilder<ProductsCubit, BaseState<List<dynamic>>>(
            builder: (context, state) {
              return IconButton(
                icon: cubit.isRefreshing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                onPressed: cubit.canRefresh ? () => cubit.manualRefresh() : null,
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (category) => cubit.filterByCategory(category),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All')),
              const PopupMenuItem(
                value: 'electronics',
                child: Text('Electronics'),
              ),
              const PopupMenuItem(
                value: 'jewelery',
                child: Text('Jewelry'),
              ),
              const PopupMenuItem(
                value: "men's clothing",
                child: Text("Men's Clothing"),
              ),
              const PopupMenuItem(
                value: "women's clothing",
                child: Text("Women's Clothing"),
              ),
            ],
          ),
        ],
      ),
      body: BlocManager<ProductsCubit, BaseState<List<dynamic>>>(
        bloc: cubit,
        enablePullToRefresh: true,
        onRefresh: () => cubit.manualRefresh(),
        showLoadingIndicator: false, // Use inline loading instead
        child: Column(
          children: [
            // Status bar with auto-refresh info
            BlocBuilder<ProductsCubit, BaseState<List<dynamic>>>(
              builder: (context, state) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Row(
                    children: [
                      Icon(
                        Icons.autorenew,
                        size: 16,
                        color: cubit.isRefreshing ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        cubit.isRefreshing
                            ? 'Refreshing...'
                            : 'Updated ${cubit.timeSinceLastRefresh}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Text(
                        'Auto-refresh: 30s',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Products list
            Expanded(
              child: BlocBuilder<ProductsCubit, BaseState<List<dynamic>>>(
                builder: (context, state) {
                  if (state is InitialState || state is LoadingState) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading products...'),
                        ],
                      ),
                    );
                  }

                  if (state is ErrorState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            state.errorMessage ?? 'An error occurred',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is LoadedState) {
                    final products = state.data ?? [];

                    if (products.isEmpty) {
                      return const Center(
                        child: Text('No products available'),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index] as dynamic;
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product image
                              Expanded(
                                child: Image.network(
                                  product.image ?? '',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey[100],
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Product info
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.title ?? 'Untitled',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product.formattedPrice ?? '\$0.00',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      product.displayCategory ?? 'Unknown',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
