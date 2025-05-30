import 'dart:convert';
import 'package:api_products/models/Product_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Product currentProduct;
  bool isDeleted = false;

  @override
  void initState() {
    super.initState();
    currentProduct = widget.product;

    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> deleteProduct() async {
    final response = await http.delete(
      Uri.parse('https://dummyjson.com/products/${currentProduct.id}'),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      setState(() {
        isDeleted = result['isDeleted'] == true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product deleted successfully!")),
      );
      Navigator.pop(context); // Navigate back to the product list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete product.")),
      );
    }
  }

  Future<void> updateProductTitle(String newTitle) async {
    final response = await http.put(
      Uri.parse('https://dummyjson.com/products/${currentProduct.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': newTitle}),
    );

    if (response.statusCode == 200) {
      final updated = Product.fromJson(json.decode(response.body));
      setState(() {
        currentProduct = updated;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product title updated!")),
      );
    }
  }

  void showUpdateDialog() {
    final controller = TextEditingController(text: currentProduct.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Title"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "New Title"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              updateProductTitle(controller.text);
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Product"),
        content: const Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              deleteProduct();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isDeleted) {
      return const Scaffold(
        body: Center(child: Text("Product has been deleted.")),
      );
    }

    return Scaffold(
      body: Stack(
        children: [

          FadeTransition(
            opacity: _fadeIn,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  children: [
                    Hero(

                      tag: currentProduct.id,
                      child: currentProduct.images.isNotEmpty
                          ? Image.network(currentProduct.images[0], height: 250, fit: BoxFit.cover)
                          : const Icon(Icons.image_not_supported, size: 100),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 15,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(currentProduct.title,
                              style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                          const SizedBox(height: 10),
                          Text(currentProduct.description,
                              style: const TextStyle(fontSize: 16, color: Colors.black54)),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₹${currentProduct.price}',
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    currentProduct.rating.toString(),
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: showUpdateDialog,
                                icon: const Icon(Icons.edit),
                                label: const Text("Edit"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: showDeleteConfirmation,
                                icon: const Icon(Icons.delete),
                                label: const Text("Delete"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
