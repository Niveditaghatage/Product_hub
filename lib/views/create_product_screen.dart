import 'package:api_products/views/ProductListPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateProductScreen extends StatefulWidget {
  @override
  _CreateProductScreenState createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  String title = '';
  String description = '';
  String category = '';
  String tags = '';
  String price = '';
  String rating = '';
  String thumbnail = '';
  String images = '';

  bool isLoading = false;

  Future<void> _submitProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => isLoading = true);

      final product = {
        "title": title,
        "description": description,
        "category": category,
        "tags": tags.split(',').map((e) => e.trim()).toList(),
        "price": int.tryParse(price) ?? 0,
        "rating": double.tryParse(rating) ?? 0.0,
        "thumbnail": thumbnail,
        "images": images.split(',').map((e) => e.trim()).toList(),
      };

      try {
        final response = await http.post(
          Uri.parse("https://dummyjson.com/products/add"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(product),
        );

        setState(() => isLoading = false);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final newProduct = jsonDecode(response.body);
          showDialog(
            context: context,
            builder: (_) => Center(
              child: AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 300),
                child: AlertDialog(
                  title: const Text("🎉 Product Created" ,style: const TextStyle(color: Colors.black87),),
                  content: Text("ID: ${newProduct['id']}\nTitle: ${newProduct['title']}",style: const TextStyle(color: Colors.black87),),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => ProductListPage()),
                        );
                      },
                      child: const Text("OK"),
                    )
                  ],
                ),
              ),
            ),
          );
        } else {
          throw Exception("Failed to simulate product creation.");
        }
      } catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Widget _buildTextField(String label, Function(String) onSaved,
      {bool isNumeric = false, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        validator: (value) => value == null || value.isEmpty ? 'Required field' : null,
        onSaved: (value) => onSaved(value!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Product")),
      body: SingleChildScrollView(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField("Title", (v) => title = v, icon: Icons.title),
                _buildTextField("Description", (v) => description = v, icon: Icons.description),
                _buildTextField("Category", (v) => category = v, icon: Icons.category),
                _buildTextField("Tags (comma-separated)", (v) => tags = v, icon: Icons.tag),
                _buildTextField("Price", (v) => price = v, isNumeric: true, icon: Icons.attach_money),
                _buildTextField("Rating", (v) => rating = v, isNumeric: true, icon: Icons.star),
                _buildTextField("Thumbnail URL", (v) => thumbnail = v, icon: Icons.image),
                _buildTextField("Images (comma-separated URLs)", (v) => images = v, icon: Icons.image_outlined),
                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Create Product"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _submitProduct,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
