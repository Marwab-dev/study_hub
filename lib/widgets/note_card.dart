import 'package:flutter/material.dart';
import 'package:study_hub/screens/note_details_screen.dart';

class NoteCard extends StatefulWidget {
  final String title;
  final int likes;
  final int comments;
  final int views;
  final String? imageUrl;

  const NoteCard({
    super.key,
    required this.title,
    required this.likes,
    required this.comments,
    required this.views,
    this.imageUrl,
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  bool isLiked = false;

  void openDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteDetailsScreen(title: widget.title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTrending = widget.likes >= 50;

    return Dismissible(
      key: UniqueKey(),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: Colors.blue,
        child: const Icon(Icons.share, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: openDetails,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🖼️ Image (optional)
              if (widget.imageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: Image.network(
                    widget.imageUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔥 Top Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "NOTE",
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        if (isTrending)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "🔥 Trending",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        const Spacer(),

                        const Icon(Icons.bookmark_border, size: 20),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// 📌 Title
                    Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// 🧠 Description
                    const Text(
                      "Tap to read full explanation and deep breakdown of this note.",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),

                    const SizedBox(height: 12),

                    /// 📊 Stats
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isLiked = !isLiked;
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.grey,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text("${widget.likes + (isLiked ? 1 : 0)}"),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        Row(
                          children: [
                            const Icon(Icons.comment, size: 18),
                            const SizedBox(width: 4),
                            Text("${widget.comments}"),
                          ],
                        ),

                        const SizedBox(width: 16),

                        Row(
                          children: [
                            const Icon(Icons.visibility, size: 18),
                            const SizedBox(width: 4),
                            Text("${widget.views}"),
                          ],
                        ),

                        const Spacer(),

                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
