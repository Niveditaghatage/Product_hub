import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:api_products/models/Product_model.dart';
import 'package:http/http.dart' as http;

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product List')),
      body: FutureBuilder<List<Product>>(
        future: fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print("Error:${snapshot.error}");
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  leading: product.images.isNotEmpty
                      ? Image.network(product.images[0], width: 50)
                      : const Icon(Icons.image_not_supported),
                  title: Text(product.title),
                  subtitle: Text('₹${product.price} | ⭐ ${product.rating}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
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