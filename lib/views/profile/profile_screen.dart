import 'package:api_products/api_service_profile.dart';
import 'package:api_products/models/UserModel.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void loadProfile() async {
    final fetchedUser = await ApiService.getUserProfile();
    setState(() {
      user = fetchedUser;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
          ? const Center(child: Text('Failed to load profile.'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user!.image),
              radius: 50,
            ),
            const SizedBox(height: 16),
            Text('${user!.firstName} ${user!.lastName}',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(user!.email,
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('User ID: ${user!.id}'),
          ],
        ),
      ),
    );
  }
}
