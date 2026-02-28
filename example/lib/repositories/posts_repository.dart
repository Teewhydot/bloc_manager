import 'package:bloc_manager_example/models/post.dart';
import 'api_client.dart';

/// Repository for fetching posts from JSONPlaceholder API
class PostsRepository {
  final ApiClient _apiClient;
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  PostsRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetch paginated posts
  Future<List<Post>> fetchPosts({
    required int page,
    required int pageSize,
  }) async {
    // JSONPlaceholder doesn't support pagination, so we fetch all and slice
    final response = await _apiClient.get(
      '$_baseUrl/posts',
    );

    final List<dynamic> data = response.data as List<dynamic>;
    final allPosts = data.map((json) => Post.fromJson(json as Map<String, dynamic>)).toList();

    // Manually paginate the results
    final start = (page - 1) * pageSize;
    final end = start + pageSize;

    if (start >= allPosts.length) {
      return [];
    }

    return allPosts.sublist(start, end.clamp(0, allPosts.length));
  }

  /// Get total count of posts (for pagination info)
  Future<int> getTotalCount() async {
    final response = await _apiClient.get('$_baseUrl/posts');
    final List<dynamic> data = response.data as List<dynamic>;
    return data.length;
  }
}
