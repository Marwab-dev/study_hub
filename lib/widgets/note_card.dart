import 'package:flutter/material.dart';
import 'package:study_hub/screens/note_details_screen.dart';

class NoteCard extends StatelessWidget {
  final String title;
  final int likes;
  final int comments;

  const NoteCard({
    super.key,
    required this.title,
    required this.likes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => NoteDetailsScreen(title: title),
            transitionsBuilder: (_, animation, __, child) {
              return SlideTransition(
                position: Tween(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text("Complete study notes."),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.favorite_border),
                  Text("$likes"),
                  const Spacer(),
                  const Icon(Icons.comment),
                  Text("$comments"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
