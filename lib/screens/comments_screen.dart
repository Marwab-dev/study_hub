import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;

  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController commentController = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  void sendComment() async {
    if (commentController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection("posts")
        .doc(widget.postId)
        .collection("comments")
        .add({
          "text": commentController.text.trim(),
          "userId": currentUserId,
          "likes": 0,
          "createdAt": FieldValue.serverTimestamp(),
        });

    commentController.clear();
  }

  Future<Map<String, dynamic>?> getUser(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .get();

    return doc.data();
  }

  void likeComment(String commentId, int currentLikes) {
    FirebaseFirestore.instance
        .collection("posts")
        .doc(widget.postId)
        .collection("comments")
        .doc(commentId)
        .update({"likes": currentLikes + 1});
  }

  void deleteComment(String commentId) {
    FirebaseFirestore.instance
        .collection("posts")
        .doc(widget.postId)
        .collection("comments")
        .doc(commentId)
        .delete();
  }

  Widget _buildComment(Map<String, dynamic> data, String id) {
    final isMe = data["userId"] == currentUserId;

    return FutureBuilder(
      future: getUser(data["userId"]),
      builder: (context, snapshot) {
        final user = snapshot.data ?? {};

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxWidth: 300),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👤 user info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: user["image"] != null
                          ? NetworkImage(user["image"])
                          : null,
                      child: user["image"] == null
                          ? const Icon(Icons.person, size: 16)
                          : null,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      user["name"] ?? "User",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  data["text"] ?? "",
                  style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    GestureDetector(
                      onTap: () => likeComment(id, data["likes"] ?? 0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.favorite,
                            size: 16,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text("${data["likes"] ?? 0}"),
                        ],
                      ),
                    ),

                    const Spacer(),

                    if (isMe)
                      GestureDetector(
                        onTap: () => deleteComment(id),
                        child: const Icon(
                          Icons.delete,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: "Write a comment...",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: sendComment,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),

      appBar: AppBar(title: const Text("Comments"), centerTitle: true),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("posts")
                  .doc(widget.postId)
                  .collection("comments")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final comments = snapshot.data!.docs;

                if (comments.isEmpty) {
                  return const Center(child: Text("No comments yet 💬"));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final data = comments[index].data() as Map<String, dynamic>;

                    return _buildComment(data, comments[index].id);
                  },
                );
              },
            ),
          ),

          _inputBar(),
        ],
      ),
    );
  }
}
