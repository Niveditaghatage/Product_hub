import 'dart:convert';
import 'package:api_products/models/UserModel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com/auth/me';
  static final storage = FlutterSecureStorage();

  static Future<User?> getUserProfile() async {
    final token = await storage.read(key: 'accessToken');

    if (token == null) return null;

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return User.fromJson(jsonData);
    } else {
      print('Failed to fetch profile: ${response.body}');
      return null;
    }
  }
}
