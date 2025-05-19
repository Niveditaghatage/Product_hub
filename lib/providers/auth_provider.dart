import 'dart:convert';

import 'package:api_products/models/UserModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  Future<bool> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('https://dummyjson.com/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"username": username, "password": password}),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data['token'] != null) {
      _user = UserModel.fromJson(data);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      notifyListeners();
      return true;
    } else {
      // Check if message exists; else show fallback
      final errorMsg = data['message'] ?? 'Unknown login error';
      debugPrint("Login failed: $errorMsg");
      Fluttertoast.showToast(msg: errorMsg);  // <- show error toast
      return false;
    }
  }


  Future<void> logout() async {
    _user = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }
}
