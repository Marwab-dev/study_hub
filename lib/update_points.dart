import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class XPService {
  final users = FirebaseFirestore.instance.collection("users");

  Future<void> addXP(String userId, int amount) async {
    await users.doc(userId).update({"points": FieldValue.increment(amount)});
  }
}

class XPControlScreen extends StatefulWidget {
  final String userId;

  const XPControlScreen({super.key, required this.userId});

  @override
  State<XPControlScreen> createState() => _XPControlScreenState();
}

class _XPControlScreenState extends State<XPControlScreen>
    with SingleTickerProviderStateMixin {
  final XPService service = XPService();

  OverlayEntry? _overlayEntry;

  void _showFloatingXP(String text) {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height / 3,
        left: MediaQuery.of(context).size.width / 2 - 40,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) {
            return Opacity(
              opacity: 1 - value,
              child: Transform.translate(
                offset: Offset(0, -50 * value),
                child: child,
              ),
            );
          },
          child: Material(
            color: Colors.transparent,
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 26,
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    Future.delayed(const Duration(milliseconds: 900), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  int _level(int xp) => (xp / 100).floor();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("🎮 XP Game Center"),
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final points = data["points"] ?? 0;
          final level = _level(points);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// 🏆 LEVEL CARD
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.deepPurple, Colors.purpleAccent],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Your Level",
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        "LV $level",
                        style: const TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      LinearProgressIndicator(
                        value: (points % 100) / 100,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),

                      const SizedBox(height: 5),
                      Text(
                        "$points XP",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                /// 🎮 ACTIONS
                _actionButton(
                  title: "Complete Lesson +10 XP",
                  color: Colors.green,
                  onTap: () async {
                    await service.addXP(widget.userId, 10);
                    _showFloatingXP("+10 XP");
                  },
                ),

                _actionButton(
                  title: "Like Content +2 XP",
                  color: Colors.blue,
                  onTap: () async {
                    await service.addXP(widget.userId, 2);
                    _showFloatingXP("+2 XP");
                  },
                ),

                _actionButton(
                  title: "Comment +3 XP",
                  color: Colors.orange,
                  onTap: () async {
                    await service.addXP(widget.userId, 3);
                    _showFloatingXP("+3 XP");
                  },
                ),

                const SizedBox(height: 20),

                /// 🏆 ACHIEVEMENTS
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "🏆 Achievements",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 10,
                  children: [
                    _badge("First XP", Colors.amber),
                    _badge("100 XP", Colors.green),
                    _badge("Streak 3🔥", Colors.red),
                  ],
                ),

                const SizedBox(height: 20),

                /// 🎯 DAILY MISSION
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.flag, color: Colors.deepPurple),
                      SizedBox(width: 10),
                      Expanded(child: Text("Daily Mission: Earn 20 XP today")),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _actionButton({
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.flash_on, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
