import 'package:api_products/views/HomePage.dart';
import 'package:api_products/Services/api_service.dart';
import 'package:api_products/views/auth/login_screen.dart';
import 'package:flutter/material.dart';

import 'views/SplashScreen.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> isLoggedIn() async {
    final token = await AuthService().getToken();
    return token != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.deepPurple[50], // 🌈 Set your background color here
        primarySwatch: Colors.deepPurple,
        textTheme: ThemeData.dark().textTheme,
      ),
      home: FutureBuilder<bool>(
        future: isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return snapshot.data == true ? const HomeScreen() : const LoginPage();
        },
      ),
    );
  }
}
