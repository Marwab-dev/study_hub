import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title: const Text("🏆 Leaderboard"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingView();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const _EmptyView();
          }

          final users = snapshot.data!.docs;

          users.sort((a, b) {
            final aPoints = (a["points"] ?? 0) as num;
            final bPoints = (b["points"] ?? 0) as num;
            return bPoints.compareTo(aPoints);
          });

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 800));
            },
            child: Column(
              children: [
                const SizedBox(height: 10),

                /// 🥇 TOP 3
                SizedBox(
                  height: 170,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: users.length > 3 ? 3 : users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final name = user["name"] ?? "Unknown";
                      final points = user["points"] ?? 0;

                      final colors = [Colors.amber, Colors.grey, Colors.brown];

                      final medals = ["🥇", "🥈", "🥉"];

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: 150,
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              colors[index].withOpacity(0.9),
                              colors[index].withOpacity(0.4),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors[index].withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white,
                              child: Text(
                                medals[index],
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "$points pts",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                /// 📜 LIST
                Expanded(
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final name = user["name"] ?? "Unknown";
                      final points = user["points"] ?? 0;

                      final isTop1 = index == 0;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: isTop1
                              ? Colors.deepPurple.shade50
                              : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          border: isTop1
                              ? Border.all(color: Colors.deepPurple, width: 1.5)
                              : null,
                        ),
                        child: ListTile(
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.deepPurple,
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              if (index < 3)
                                Positioned(
                                  right: -2,
                                  bottom: -2,
                                  child: Text(
                                    ["🥇", "🥈", "🥉"][index],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("Points: $points"),
                          trailing: Icon(
                            Icons.emoji_events,
                            color: isTop1 ? Colors.amber : Colors.deepPurple,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("No users yet 😢", style: TextStyle(fontSize: 16)),
    );
  }
}
