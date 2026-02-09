import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:wins/reminders_page.dart';
import 'package:wins/win_timeline.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  // Ensure Flutter bindings are initialized before database work
  WidgetsFlutterBinding.ensureInitialized();
  tz. initializeTimeZones();

  // 2. Android/iOS Settings
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

await flutterLocalNotificationsPlugin.initialize(
  settings: initializationSettings, 
  onDidReceiveNotificationResponse: (NotificationResponse details) {

    debugPrint("Notification tapped!");
  },
);

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
      useMaterial3: true,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF13EC5B),
        primary: const Color(0xFF13EC5B),
        surface: const Color(0xFFF6F8F6),
        onSurface: const Color(0xFF0D1B12),
      ),
      scaffoldBackgroundColor: const Color(0xFFF6F8F6),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF13EC5B),
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 64),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
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
    RemindersPage(),
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
            icon: Icon(Icons.notification_add_outlined),
            selectedIcon: Icon(Icons.notification_add_rounded),
            label: 'Settings',
          ),
        ],
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF6B8E23).withOpacity(0.2),
      ),
    );
  }
}