import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> scheduleDailyNotification(int hour, int minute, String message) async {
    // 1. Clear any existing scheduled notifications
    await _notifications.cancelAll();

    // 2. Set the time
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // 3. Schedule using NAMED parameters (Required in v20+)
    await _notifications.zonedSchedule(
      id: 0, // Fix 1: Named 'id'
      title: 'Time to log a win!', // Fix 2: Named 'title'
      body: message, // Fix 3: Named 'body'
      scheduledDate: scheduledDate, // Fix 4: Named 'scheduledDate'
      notificationDetails: const NotificationDetails( // Fix 5: Named 'notificationDetails'
        android: AndroidNotificationDetails(
          'wins_channel', 
          'Daily Wins',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Fix 6: 'uiLocalNotificationDateInterpretation' is no longer required in v20
      matchDateTimeComponents: DateTimeComponents.time, 
    );
  }
}