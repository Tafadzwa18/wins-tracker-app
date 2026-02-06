import 'package:flutter/material.dart';
import 'package:wins/win_timeline.dart';
import 'add_win_page.dart';

void main() {
  // Ensure Flutter bindings are initialized before database work
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PersonalWinsApp());
}

class PersonalWinsApp extends StatelessWidget {
  const PersonalWinsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wins App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Defining our "Calm & Positive" palette
        scaffoldBackgroundColor: const Color(0xFFFAFAF8),
        primaryColor: const Color(0xFF6B8E23),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B8E23),
          primary: const Color(0xFF6B8E23),
          secondary: const Color(0xFF8DA45C),
        ),
        // Applying a clean, lightweight font style
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.w300),
          bodyLarge: TextStyle(color: Colors.black12, fontSize: 16),
        ),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // We start on the Timeline (Index 0)
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    WinTimelineScreen(),
    AddWinPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_mosaic_outlined),
            selectedIcon: Icon(Icons.auto_awesome_mosaic),
            label: 'Timeline',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'New Win',
          ),
        ],
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF6B8E23).withOpacity(0.2),
      ),
    );
  }
}