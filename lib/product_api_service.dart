// lib/services/api_service.dart
import 'dart:convert';
import 'package:api_products/models/Product_model.dart';
import 'package:http/http.dart' as http;

Future<List<Product>> fetchProducts() async {
  final response = await http.get(Uri.parse('https://dummyjson.com/products'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List products = data['products'];
    return products.map((json) => Product.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load products');
  }
}
