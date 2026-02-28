import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_manager/bloc_manager.dart';
import 'package:bloc_manager_example/cubits/todos/todos_cubit.dart';

/// Todos Screen demonstrates all BaseState types.
///
/// This screen shows the complete state management flow:
/// - **InitialState**: Starting state before any action
/// - **LoadingState**: Shows while fetching data
/// - **LoadedState**: Data displayed successfully
/// - **SuccessState**: Shows green snackbar on actions (toggle, delete)
/// - **ErrorState**: Shows red snackbar on failure
/// - **EmptyState**: No results after search/filter
class TodosScreen extends StatelessWidget {
  const TodosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TodosCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos (All States)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Load todos (InitialState → LoadingState → LoadedState)',
            onPressed: () => cubit.loadTodos(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter todos (demonstrates EmptyState)',
            onPressed: () => _showFilterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            color: Colors.orange,
            tooltip: 'Force error (demonstrates ErrorState)',
            onPressed: () => cubit.forceError(),
          ),
        ],
      ),
      body: BlocManager<TodosCubit, BaseState<List<dynamic>>>(
        bloc: cubit,
        showResultSuccessNotifications: true, // Show green snackbar on SuccessState
        child: Column(
          children: [
            // State indicator banner
            BlocBuilder<TodosCubit, BaseState<List<dynamic>>>(
              builder: (context, state) {
                return _buildStateBanner(state);
              },
            ),
            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getInstructionsForState(cubit.state),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search todos...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => cubit.showAll(),
                  ),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) => cubit.searchTodos(value),
              ),
            ),
            // Content
            Expanded(
              child: BlocBuilder<TodosCubit, BaseState<List<dynamic>>>(
                builder: (context, state) {
                  // InitialState - show empty screen with action
                  if (state is InitialState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.playlist_add_check,
                              size: 64,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'InitialState',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'This is the starting state.',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap the refresh button above to load todos',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => cubit.loadTodos(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Load Todos'),
                          ),
                        ],
                      ),
                    );
                  }

                  // LoadingState
                  if (state is LoadingState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'LoadingState',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text('Fetching todos from API...'),
                        ],
                      ),
                    );
                  }

                  // EmptyState
                  if (state is EmptyState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.inbox, size: 48, color: Colors.purple),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'EmptyState',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.purple,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No todos match your criteria',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () => cubit.showAll(),
                            icon: const Icon(Icons.clear),
                            label: const Text('Clear filters'),
                          ),
                        ],
                      ),
                    );
                  }

                  // ErrorState
                  if (state is ErrorState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.error_outline,
                                size: 48, color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'ErrorState',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.red,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              state.errorMessage ?? 'An error occurred',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => cubit.loadTodos(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  // LoadedState
                  if (state is LoadedState) {
                    final todos = state.data ?? [];

                    if (todos.isEmpty) {
                      return const Center(
                        child: Text('No todos available'),
                      );
                    }

                    return Column(
                      children: [
                        // Summary header
                        Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.green.withValues(alpha: 0.1),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'LoadedState: ${todos.length} todos loaded',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Todos list
                        Expanded(
                          child: ListView.builder(
                            itemCount: todos.length,
                            itemBuilder: (context, index) {
                              final todo = todos[index] as dynamic;
                              final isCompleted = todo.completed ?? false;
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                elevation: isCompleted ? 1 : 3,
                                child: ListTile(
                                  leading: Checkbox(
                                    value: isCompleted,
                                    onChanged: (value) =>
                                        cubit.toggleTodo(todo.id ?? 0),
                                  ),
                                  title: Text(
                                    todo.title ?? 'Untitled',
                                    style: TextStyle(
                                      decoration:
                                          isCompleted ? TextDecoration.lineThrough : null,
                                      color: isCompleted ? Colors.grey : null,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isCompleted ? 'Completed' : 'Pending',
                                        style: TextStyle(
                                          color: isCompleted ? Colors.green : Colors.orange,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'ID: ${todo.id ?? 0}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // SuccessState trigger
                                      IconButton(
                                        icon: const Icon(Icons.check_circle_outline),
                                        color: Colors.green,
                                        tooltip: 'Mark complete (shows SuccessState)',
                                        onPressed: () =>
                                            cubit.toggleTodo(todo.id ?? 0),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        color: Colors.red,
                                        tooltip: 'Delete (shows SuccessState)',
                                        onPressed: () =>
                                            cubit.deleteTodo(todo.id ?? 0),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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

  Widget _buildStateBanner(BaseState state) {
    Color color;
    String label;
    IconData icon;

    if (state is InitialState) {
      color = Colors.blue;
      label = 'InitialState';
      icon = Icons.start;
    } else if (state is LoadingState) {
      color = Colors.orange;
      label = 'LoadingState';
      icon = Icons.hourglass_empty;
    } else if (state is LoadedState) {
      color = Colors.green;
      label = 'LoadedState';
      icon = Icons.check_circle;
    } else if (state is SuccessState) {
      color = Colors.green;
      label = 'SuccessState';
      icon = Icons.celebration;
    } else if (state is ErrorState) {
      color = Colors.red;
      label = 'ErrorState';
      icon = Icons.error;
    } else if (state is EmptyState) {
      color = Colors.purple;
      label = 'EmptyState';
      icon = Icons.inbox;
    } else {
      color = Colors.grey;
      label = 'Unknown';
      icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: color.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            'Watch this banner change as you interact!',
            style: TextStyle(
              color: color.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getInstructionsForState(BaseState state) {
    if (state is InitialState) {
      return 'Tap refresh to load → Shows InitialState → LoadingState → LoadedState';
    } else if (state is LoadingState) {
      return 'LoadingState: Data is being fetched from the API...';
    } else if (state is LoadedState) {
      return 'LoadedState: Check/uncheck items to see SuccessState (green snackbar)';
    } else if (state is ErrorState) {
      return 'ErrorState: Tap Retry to attempt loading again';
    } else if (state is EmptyState) {
      return 'EmptyState: Clear filters to see all todos';
    }
    return 'Interact with the todos to see different states';
  }

  void _showFilterDialog(BuildContext context) {
    final cubit = context.read<TodosCubit>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Todos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filtering demonstrates EmptyState when no todos match',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('All'),
              onTap: () {
                cubit.filterByCompletion(null);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Completed'),
              onTap: () {
                cubit.filterByCompletion(true);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Pending'),
              onTap: () {
                cubit.filterByCompletion(false);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
