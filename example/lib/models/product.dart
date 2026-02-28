import 'package:equatable/equatable.dart';

/// Product model from Fake Store API
/// https://fakestoreapi.com/products
class Product extends Equatable {
  final int id;
  final String title;
  final double price;
  final String category;
  final String description;
  final String image;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.description,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'category': category,
      'description': description,
      'image': image,
    };
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get displayCategory => category[0].toUpperCase() + category.substring(1);

  @override
  List<Object?> get props => [id, title, price, category, description, image];
}
