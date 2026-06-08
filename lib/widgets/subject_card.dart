import 'package:flutter/material.dart';
import '../screens/subject_screen.dart';

class SubjectCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final double progress; // 0 → 1
  final bool isNew;
  final bool isLocked;
  final int level;
  final int xp;
  final int streak;

  const SubjectCard({
    super.key,
    required this.title,
    required this.icon,
    this.progress = 0,
    this.isNew = false,
    this.isLocked = false,
    this.level = 1,
    this.xp = 0,
    this.streak = 0,
  });

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard> {
  double scale = 1;

  void openSubject() {
    if (widget.isLocked) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SubjectScreen(title: widget.title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.isLocked;

    return GestureDetector(
      onTapDown: (_) => setState(() => scale = 0.97),
      onTapUp: (_) => setState(() => scale = 1),
      onTapCancel: () => setState(() => scale = 1),
      onTap: openSubject,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: scale,
        child: Container(
          width: 170,
          margin: const EdgeInsets.only(right: 15),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),

            /// 🎨 Locked style effect
            gradient: LinearGradient(
              colors: isLocked
                  ? [Colors.grey.shade600, Colors.grey.shade800]
                  : [const Color(0xff4F46E5), const Color(0xff7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),

          child: Opacity(
            opacity: isLocked ? 0.6 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔝 TOP ROW
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// ICON
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(widget.icon, size: 26, color: Colors.white),
                    ),

                    /// BADGES
                    Row(
                      children: [
                        if (widget.isNew) _badge("NEW", Colors.orange),

                        if (widget.streak > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: _badge(
                              "🔥 ${widget.streak}",
                              Colors.redAccent,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// TITLE
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                /// LEVEL + XP
                Text(
                  "Level ${widget.level} • ${widget.xp} XP",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),

                const Spacer(),

                /// PROGRESS BAR
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: widget.progress,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${(widget.progress * 100).toInt()}% completed",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// LOCKED LABEL
                if (isLocked)
                  Row(
                    children: const [
                      Icon(Icons.lock, color: Colors.white, size: 14),
                      SizedBox(width: 5),
                      Text(
                        "Locked",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
