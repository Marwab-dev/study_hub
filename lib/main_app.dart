import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/login_screen.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int index = 0;
  bool isDark = false;

  final user = FirebaseAuth.instance.currentUser;

  int xp = 1200;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDark ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.grey[100],

        // ================= APP BAR =================
        appBar: AppBar(
          title: Text("Study Hub 🚀"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() => isDark = !isDark);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isDark ? "Dark Mode ON 🌙" : "Light Mode ☀️"),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                if (!mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),

        // ================= BODY =================
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _profileHeader(),
              const SizedBox(height: 20),
              _xpCard(),
              const SizedBox(height: 20),
              _statsRow(),
              const SizedBox(height: 20),
              _actionsGrid(),
            ],
          ),
        ),
      ),
    );
  }

  // ================= PROFILE =================

  Widget _profileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.blue, Colors.indigo]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Text(
              (user?.email ?? "U")[0].toUpperCase(),
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? "Student",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? "",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= XP SYSTEM =================

  Widget _xpCard() {
    double progress = (xp % 1000) / 1000;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Level Progress",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),

          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
          ),

          const SizedBox(height: 10),

          Text("XP: $xp", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ================= STATS =================

  Widget _statsRow() {
    return Row(
      children: [
        _stat("Posts", "34", Icons.post_add),
        const SizedBox(width: 10),
        _stat("Likes", "89", Icons.favorite),
        const SizedBox(width: 10),
        _stat("Rank", "#12", Icons.emoji_events),
      ],
    );
  }

  Widget _stat(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // ================= ACTIONS =================

  Widget _actionsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: const [
        _ActionTile(Icons.book, "Courses"),
        _ActionTile(Icons.note_add, "Add Note"),
        _ActionTile(Icons.emoji_events, "Leaderboard"),
        _ActionTile(Icons.person, "Profile"),
      ],
    );
  }
}

// ================= ACTION TILE =================

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ActionTile(this.icon, this.title);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$title opened")));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 35, color: Colors.blue),
            const SizedBox(height: 10),
            Text(title),
          ],
        ),
      ),
    );
  }
}
