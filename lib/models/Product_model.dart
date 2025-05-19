class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price; // changed from int to double
  final double rating;
  final List<String> images;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price, // changed from int to double
    required this.rating,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      price: (json['price'] as num).toDouble(), // ensure double
      rating: (json['rating'] as num).toDouble(),
      images: List<String>.from(json['images']),
    );
  }
}
