import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_hub/auth/login_screen.dart';
import 'package:study_hub/services/auth_services.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final AuthService _auth = AuthService();

  Future<Map<String, dynamic>?> getUserData() async {
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    return doc.data();
  }

  void logout() async {
    await _auth.logout();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<int> getPostsCount() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("posts")
        .where("userId", isEqualTo: user!.uid)
        .get();

    return snapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),

      body: FutureBuilder(
        future: getUserData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),

                const SizedBox(height: 15),

                Text(
                  data["name"] ?? "User",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  data["email"] ?? "",
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 25),

                FutureBuilder<int>(
                  future: getPostsCount(),
                  builder: (context, snap) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat(
                          "Posts",
                          snap.data?.toString() ?? "0",
                        ),
                        _buildStat("Likes", "0"),
                        _buildStat("Saved", "0"),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 40),

                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text("Settings"),
                  onTap: () {},
                ),

                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Logout"),
                  onTap: logout,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStat(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(title),
      ],
    );
  }
}