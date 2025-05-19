import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final storage = const FlutterSecureStorage();
  final String baseUrl = 'https://dummyjson.com/auth/login';

  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
       // 'expiresInMins': 30,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      await storage.write(key: 'accessToken', value: data['accessToken']);
      await storage.write(key: 'refreshToken', value: data['refreshToken']);
      return true;
    } else {
      return false;
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'refreshToken');
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'accessToken');
  }
}
