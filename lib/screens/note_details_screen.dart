import 'package:flutter/material.dart';

class NoteDetailsScreen extends StatelessWidget {
  final String title;

  const NoteDetailsScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 600),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            "This is a detailed explanation of $title.\n\nHere you can show full notes, images, PDFs, etc.",
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}