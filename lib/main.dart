import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:study_hub/auth/login_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

/// ===============================
/// GLOBAL NAV KEY (IMPORTANT)
/// ===============================
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,

      debugShowCheckedModeBanner: false,

      // ================= THEME =================
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),

      themeMode: ThemeMode.system,

      // ================= ROUTES =================
      initialRoute: "/",

      routes: {
        "/": (context) => const SplashScreen(),
        "/auth": (context) => const AuthGate(),
        "/login": (context) => const LoginScreen(),
        "/home": (context) => const MainApp(),
      },
    );
  }
}

/// ===============================
/// AUTH GATE (SMART FLOW)
/// ===============================
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }

        if (snapshot.hasError) {
          return const ErrorScreen();
        }

        if (snapshot.hasData) {
          // auto redirect
          Future.microtask(() {
            navigatorKey.currentState!.pushReplacementNamed("/home");
          });
        } else {
          Future.microtask(() {
            navigatorKey.currentState!.pushReplacementNamed("/login");
          });
        }

        return const Scaffold();
      },
    );
  }
}

/// ===============================
/// MAIN APP (DASHBOARD BASE)
/// ===============================
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int index = 0;

  final pages = const [
    Center(child: Text("🏠 Home")),
    Center(child: Text("📚 Courses")),
    Center(child: Text("🏆 Leaderboard")),
    Center(child: Text("👤 Profile")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Study Hub"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              navigatorKey.currentState!.pushReplacementNamed("/login");
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: pages[index],

      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          setState(() => index = i);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.book), label: "Courses"),
          NavigationDestination(
            icon: Icon(Icons.emoji_events),
            label: "Ranking",
          ),
          NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

/// ===============================
/// LOADING SCREEN (UX POLISH)
/// ===============================
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

/// ===============================
/// ERROR SCREEN (UX SAFE)
/// ===============================
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "Something went wrong.\nPlease restart the app.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
