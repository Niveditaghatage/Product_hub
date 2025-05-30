import 'dart:convert';
import 'package:api_products/views/ProductDetailScreen.dart';
import 'package:api_products/views/create_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:api_products/models/Product_model.dart';
import 'package:api_products/models/UserModel.dart';
import 'package:api_products/views/profile/profile_screen.dart';

import '../Services/api_service_profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user;
  bool isUserLoading = true;
  String searchQuery = '';
  String selectedSort = 'None';
  String selectedCategory = 'All';
  List<String> categories = ['All'];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUser();
    fetchCategories();
  }

  void loadUser() async {
    final fetchedUser = await ApiService.getUserProfile();
    setState(() {
      user = fetchedUser;
      isUserLoading = false;
    });
  }

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse('https://dummyjson.com/products/categories'));
    if (response.statusCode == 200) {
      final List<dynamic> fetchedCategories = json.decode(response.body);
      setState(() {
        categories = ['All', ...fetchedCategories.cast<String>()];
      });
    }
  }

  String getSortQuery() {
    switch (selectedSort) {
      case 'A-Z':
        return '&sortBy=title&order=asc';
      case 'Z-A':
        return '&sortBy=title&order=desc';
      case 'Price Low to High':
        return '&sortBy=price&order=asc';
      case 'Price High to Low':
        return '&sortBy=price&order=desc';
      default:
        return '';
    }
  }

  Future<List<Product>> fetchProducts() async {
    String url = '';

    if (selectedCategory != 'All') {
      url = 'https://dummyjson.com/products/category/$selectedCategory';
    } else if (searchQuery.isNotEmpty) {
      url = 'https://dummyjson.com/products/search?q=$searchQuery${getSortQuery()}';
    } else {
      url = 'https://dummyjson.com/products?${getSortQuery().replaceFirst('&', '')}';
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List products = data['products'];
      return products.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'),
          actions: [
          IconButton(
          icon: const Icon(Icons.add),
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  CreateProductScreen()),
        );
        print("Add Product button tapped");
      },
    ),
    ],),

      body: Column(
        children: [
          // User Info
          if (isUserLoading)
            const Center(child: CircularProgressIndicator())
          else if (user == null)
            const Center(child: Text('Failed to load user.'))
          else
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(user!.image),
                      radius: 30,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${user!.firstName} ${user!.lastName}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black87)),
                        Text(user!.email, style: const TextStyle(fontSize: 14,color: Colors.black87)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: TextField(
              controller: searchController,
              cursorColor: Colors.black87,
              style:const TextStyle(color: Colors.black87,),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
            ),
          ),

          // Sorting and Category Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedSort,
                    items: [
                      'None',
                      'A-Z',
                      'Z-A',
                      'Price Low to High',
                      'Price High to Low'
                    ]
                        .map((label) => DropdownMenuItem(
                      value: label,
                      child: Text(label,style: const TextStyle(color: Colors.black87),),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSort = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Sort By',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categories
                        .map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat,style: const TextStyle(color: Colors.black87),),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),
          // Product List
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: fetchProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final products = snapshot.data!;
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: ListTile(
                          leading: product.images.isNotEmpty
                              ? Image.network(product.images[0], width: 50, height: 50, fit: BoxFit.cover)
                              : const Icon(Icons.image_not_supported),
                          title: Text(product.title),
                          subtitle: Text('₹${product.price} | ⭐ ${product.rating}'),
                          onTap: () {
                            Navigator.of(context).push(PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 400),
                              pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
                                opacity: animation,
                                child: ProductDetailScreen(product: product),
                              ),
                            ));
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
