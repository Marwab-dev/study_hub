import 'package:flutter/material.dart';

class SubjectScreen extends StatelessWidget {
  final String title;

  const SubjectScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: List.generate(10, (i) {
          return Hero(
            tag: "note$i",
            child: Card(
              child: ListTile(
                title: Text("$title Note ${i + 1}"),
                subtitle: const Text("Tap to open details"),
                onTap: () {},
              ),
            ),
          );
        }),
      ),
    );
  }
}
