import 'package:bloc_manager_example/models/todo.dart';
import 'api_client.dart';

/// Repository for managing todos from JSONPlaceholder API
class TodosRepository {
  final ApiClient _apiClient;
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  TodosRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetch all todos
  Future<List<Todo>> fetchTodos() async {
    final response = await _apiClient.get(
      '$_baseUrl/todos',
    );

    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => Todo.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Fetch todos for a specific user
  Future<List<Todo>> fetchTodosByUserId(int userId) async {
    final response = await _apiClient.get(
      '$_baseUrl/todos',
      queryParameters: {'userId': userId},
    );

    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => Todo.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Filter todos by completion status
  List<Todo> filterByCompletion(List<Todo> todos, bool? completed) {
    if (completed == null) return todos;
    return todos.where((todo) => todo.completed == completed).toList();
  }

  /// Search todos by title
  List<Todo> searchByTitle(List<Todo> todos, String query) {
    if (query.isEmpty) return todos;
    final lowerQuery = query.toLowerCase();
    return todos
        .where((todo) => todo.title.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
