import 'package:bloc_manager/bloc_manager.dart';
import 'package:bloc_manager_example/models/todo.dart';
import 'package:bloc_manager_example/repositories/todos_repository.dart';

/// TodosCubit demonstrates all BaseState types and the executeAsync helper.
///
/// IMPORTANT: When using SuccessState for notifications, always re-emit
/// LoadedState AFTER emitSuccess so the UI always has data to display.
/// Otherwise, the BlocBuilder will rebuild with SuccessState (no data).
///
/// It showcases InitialState, LoadingState, LoadedState, SuccessState, ErrorState, and EmptyState.
class TodosCubit extends BaseCubit<BaseState<List<Todo>>> {
  final TodosRepository _repository;
  List<Todo> _allTodos = [];

  TodosCubit({TodosRepository? repository})
      : _repository = repository ?? TodosRepository(),
        super(const InitialState()) {
    // Note: We don't load automatically - user must tap refresh
    // to demonstrate InitialState -> LoadingState transition
  }

  List<Todo> get todos => state.data ?? [];

  /// Load todos - demonstrates InitialState -> LoadingState -> LoadedState
  Future<void> loadTodos() async {
    await executeAsync<dynamic>(
      () => _repository.fetchTodos(),
      loadingMessage: 'Loading todos...',
      onSuccess: (result) {
        _allTodos = result as List<Todo>;
        emit(LoadedState<List<Todo>>(
          data: _allTodos,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  /// Toggle todo completion - demonstrates SuccessState with snackbar
  Future<void> toggleTodo(int todoId) async {
    final currentTodos = List<Todo>.from(_allTodos);
    final index = currentTodos.indexWhere((t) => t.id == todoId);

    if (index == -1) return;

    final updatedTodo = currentTodos[index].copyWith(
      completed: !currentTodos[index].completed,
    );

    currentTodos[index] = updatedTodo;
    _allTodos = currentTodos;

    // Show success message (this emits SuccessState temporarily)
    emitSuccess('Todo ${updatedTodo.completed ? 'completed! 🎉' : 'uncompleted'}');

    // IMPORTANT: Re-emit LoadedState AFTER success so UI always has data to show
    emit(LoadedState<List<Todo>>(
      data: _allTodos,
      lastUpdated: DateTime.now(),
    ));
  }

  /// Delete todo with confirmation - demonstrates SuccessState
  Future<void> deleteTodo(int todoId) async {
    _allTodos = _allTodos.where((t) => t.id != todoId).toList();

    // Show success message
    emitSuccess('Todo deleted successfully');

    // IMPORTANT: Re-emit LoadedState AFTER success so UI always has data to show
    emit(LoadedState<List<Todo>>(
      data: _allTodos,
      lastUpdated: DateTime.now(),
    ));
  }

  /// Search todos - demonstrates EmptyState when no results
  void searchTodos(String query) {
    if (_allTodos.isEmpty) {
      emitError('Load todos first by tapping the refresh button');
      return;
    }

    final filtered = _repository.searchByTitle(_allTodos, query);

    if (filtered.isEmpty) {
      emit(const EmptyState<List<Todo>>(
        message: 'No todos match your search',
      ));
    } else {
      emit(LoadedState<List<Todo>>(
        data: filtered,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  /// Filter by completion status - demonstrates EmptyState
  void filterByCompletion(bool? completed) {
    if (_allTodos.isEmpty) {
      emitError('Load todos first by tapping the refresh button');
      return;
    }

    final filtered = _repository.filterByCompletion(_allTodos, completed);

    if (filtered.isEmpty) {
      emit(EmptyState<List<Todo>>(
        message: completed == true
            ? 'No completed todos yet'
            : 'No pending todos - great job!',
      ));
    } else {
      emit(LoadedState<List<Todo>>(
        data: filtered,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  /// Force an error - demonstrates ErrorState handling
  void forceError() {
    emitError('This is a demo error message!', errorCode: 'DEMO_ERROR');
  }

  /// Reset to initial state - demonstrates returning to InitialState
  void reset() {
    _allTodos = [];
    emit(const InitialState<List<Todo>>());
  }

  /// Clear search filters and show all todos
  void showAll() {
    if (_allTodos.isEmpty) {
      emit(const InitialState<List<Todo>>());
    } else {
      emit(LoadedState<List<Todo>>(
        data: _allTodos,
        lastUpdated: DateTime.now(),
      ));
    }
  }
}
