import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class NoteDetailsScreen extends StatefulWidget {
  final String title;

  const NoteDetailsScreen({super.key, required this.title});

  @override
  State<NoteDetailsScreen> createState() => _NoteDetailsScreenState();
}

class _NoteDetailsScreenState extends State<NoteDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool isFavorite = false;

  final String markdownData =
      """
# 📘 $title

## ✨ Overview
This is a **professional note screen** with Markdown support.

---

## 📌 Features
- Clean UI/UX design
- Better reading experience
- Markdown rendering
- Image support (coming below)
- Smooth animations

---

## 🧠 Explanation
You can now structure notes like real apps:

### Example:
- Headings
- Lists
- Bold / Italic text
- Sections

---

## 🖼️ Image Example
![Flutter](https://flutter.dev/assets/homepage/carousel/slide_1-layer_0-2x.png)

---

## 🚀 Conclusion
This makes your notes app feel like **Notion / Medium level UI**.
""";

  static get title => null;

  void scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),

      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() => isFavorite = !isFavorite);
            },
          ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: "top",
            backgroundColor: Colors.grey.shade800,
            onPressed: scrollToTop,
            child: const Icon(Icons.arrow_upward),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "edit",
            backgroundColor: Colors.deepPurple,
            onPressed: () {},
            child: const Icon(Icons.edit),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0, end: 1),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Markdown(
              controller: _scrollController,
              data: markdownData,
              styleSheet: MarkdownStyleSheet(
                h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                p: const TextStyle(fontSize: 15, height: 1.6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
