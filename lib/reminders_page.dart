import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wins/main.dart';
import 'package:wins/notifcation_service.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  // Theme Colors
  final Color primaryNeon = const Color(0xFF13EC5B);
  final Color darkBg = const Color(0xFF102216);
  final Color lightBg = const Color(0xFFF6F8F6);
  final Color secondaryGreen = const Color(0xFF4C9A66);

  // State Variables
  bool _isReminderEnabled = true;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  int _selectedMessageIndex = 0;

  final List<String> _messages = [
    "What made you smile today?",
    "Time to record a win!",
    "One small victory from today?",
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings(); //Load data as soon as the screen starts
  }

  // Load from disk
  Future<void> _loadSettings() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isReminderEnabled = prefs.getBool('reminder_enabled') ?? true;
      _selectedMessageIndex = prefs.getInt('message_index') ?? 0;

      final savedHour = prefs.getInt('reminder_hour') ?? 9;
      final savedMinute = prefs.getInt('reminder_minute') ?? 0;
      _selectedTime = TimeOfDay(hour: savedHour, minute: savedMinute);
    });
  }

  // Save to disk
  Future<void> _saveSettings() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder_enabled', _isReminderEnabled);
    await prefs.setInt('message_index', _selectedMessageIndex);
    await prefs.setInt('reminder_hour', _selectedTime.hour);
    await prefs.setInt('reminder_minute', _selectedTime.minute);

   if (_isReminderEnabled) {
    await NotificationService.scheduleDailyNotification(
      _selectedTime.hour,
      _selectedTime.minute,
      _messages[_selectedMessageIndex],
    );
  } else {
    // If they turned it off, cancel all pings
    await FlutterLocalNotificationsPlugin().cancelAll();
  }

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Reminder set successfully! 🚀")),
    );
  }
}

void _requestPermissions() async {
  // For Android 13+ (API 33+)
  final androidImplementation = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  
  if (androidImplementation != null) {
    await androidImplementation.requestNotificationsPermission();
  }

  // For iOS
  final iosImplementation = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      
  if (iosImplementation != null) {
    await iosImplementation.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0D1B12), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Settings", style: TextStyle(color: Color(0xFF0D1B12), fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome, color: primaryNeon, size: 32),
                  const SizedBox(height: 12),
                  const Text("Build Your Habit", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.1)),
                  const SizedBox(height: 8),
                  Text(
                    "Consistency is the key to seeing your wins grow. Set a time that works for you.",
                    style: TextStyle(color: secondaryGreen, fontSize: 16),
                  ),
                ],
              ),
            ),

            // Main Toggle
            _buildSectionContainer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Daily Reminders", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Get a gentle nudge to record a win.", style: TextStyle(color: secondaryGreen, fontSize: 14)),
                    ],
                  ),
                  Switch.adaptive(
                    value: _isReminderEnabled,
                    activeColor: primaryNeon,
                    onChanged: (val) => setState(() => _isReminderEnabled = val),
                  ),
                ],
              ),
            ),

            // Time Picker Section
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Text("Remind me at", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildSectionContainer(
              child: InkWell(
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedTime);
                  if (picked != null) setState(() => _selectedTime = picked);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _timeUnit(_selectedTime.hourOfPeriod.toString().padLeft(2, '0'), "HOUR"),
                    const Text(" : ", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    _timeUnit(_selectedTime.minute.toString().padLeft(2, '0'), "MINUTE"),
                    const SizedBox(width: 20),
                    Column(
                      children: [
                        _periodBadge("PM", _selectedTime.period == DayPeriod.pm),
                        const SizedBox(height: 4),
                        _periodBadge("AM", _selectedTime.period == DayPeriod.am),
                      ],
                    )
                  ],
                ),
              ),
            ),

            // Message Options
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Text("Notification Message", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: List.generate(_messages.length, (index) => _buildMessageOption(index)),
              ),
            ),

            // Preview Section
            _buildPreview(),

            // Save Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryNeon,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("Save Settings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCFE7D7)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _timeUnit(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: secondaryGreen, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _periodBadge(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: active ? primaryNeon.withOpacity(0.2) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: active ? Colors.black : Colors.grey[400])),
    );
  }

  Widget _buildMessageOption(int index) {
    bool isSelected = _selectedMessageIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMessageIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? primaryNeon.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? primaryNeon : Colors.grey[200]!, width: 2),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? primaryNeon : Colors.grey[300]),
            const SizedBox(width: 12),
            Text(_messages[index], style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF0F4F1), borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Text("PREVIEW", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: secondaryGreen, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Container(
                  height: 40, width: 40,
                  decoration: BoxDecoration(color: primaryNeon, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.emoji_events, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Daily Win Tracker", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          Text("now", style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                        ],
                      ),
                      Text(_messages[_selectedMessageIndex], style: const TextStyle(fontSize: 12, color: Color(0xFF444444))),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}