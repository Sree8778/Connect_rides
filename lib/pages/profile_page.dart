import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/signin_page.dart';
import 'package:users_connect_app/auth/signin_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SigninPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text("User Profile", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20.0),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("John Doe"),
            subtitle: const Text("Student"),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text("john.doe@example.com"),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text("+123 456 7890"),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              _logout(context);
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
