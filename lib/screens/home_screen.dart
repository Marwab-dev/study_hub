import 'package:flutter/material.dart';
import 'package:study_hub/screens/profile_screen.dart';
import 'search_screen.dart';
import '../widgets/subject_card.dart';
import '../widgets/note_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final pages = const [
    _HomeBody(),
    SearchScreen(),
    Center(child: Text("Add Post")),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() => currentIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: "Home"),
          NavigationDestination(icon: Icon(Icons.search), label: "Search"),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: "Post",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Header(),
          const SizedBox(height: 20),
          _searchBar(),
          const SizedBox(height: 20),

          const Text(
            "Subjects",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                SubjectCard(title: "Math", icon: Icons.calculate),
                SubjectCard(title: "Physics", icon: Icons.science),
                SubjectCard(title: "Chemistry", icon: Icons.biotech),
                SubjectCard(title: "Programming", icon: Icons.code),
              ],
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            "Latest Notes",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          const NoteCard(title: "Flutter Basics", likes: 120, comments: 30),
          const SizedBox(height: 12),
          const NoteCard(title: "Physics Notes", likes: 80, comments: 14),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search notes...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          "Hello, Student",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        CircleAvatar(radius: 24, child: Icon(Icons.person_outline)),
      ],
    );
  }
}
