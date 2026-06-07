import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: "profilePic",
              child: CircleAvatar(
                radius: 60,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              user?.displayName ?? "No Name",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(user?.email ?? "No Email"),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
