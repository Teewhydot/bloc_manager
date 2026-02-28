import 'package:bloc_manager_example/models/product.dart';
import 'api_client.dart';

/// Repository for fetching products from Fake Store API
class ProductsRepository {
  final ApiClient _apiClient;
  static const String _baseUrl = 'https://fakestoreapi.com';

  ProductsRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetch all products
  Future<List<Product>> fetchProducts() async {
    final response = await _apiClient.get(
      '$_baseUrl/products',
    );

    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Fetch products by category
  Future<List<Product>> fetchProductsByCategory(String category) async {
    final response = await _apiClient.get(
      '$_baseUrl/products/category/$category',
    );

    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Get available categories
  Future<List<String>> fetchCategories() async {
    final response = await _apiClient.get(
      '$_baseUrl/products/categories',
    );

    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((e) => e as String).toList();
  }
}
