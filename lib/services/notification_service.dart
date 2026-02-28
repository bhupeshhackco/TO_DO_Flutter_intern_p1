import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
// Hide our local Priority so it doesn't conflict with flutter_local_notifications Priority
import '../models/todo.dart' hide Priority;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    if (kIsWeb) return;
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Use named parameters for initialize as required by latest version
    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tapped logic here
      },
    );
  }

  static Future<void> scheduleTodoNotification(Todo todo) async {
    if (kIsWeb) return;
    if (todo.dueDate == null) return;
    
    // Check if due date is in the future
    if (todo.dueDate!.isBefore(DateTime.now())) return;

    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'todo_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for upcoming tasks',
      importance: Importance.max,
      priority: Priority.high, // This uses flutter_local_notifications Priority because we hid local Priority
      icon: '@mipmap/ic_launcher',
    );
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Use named parameters for zonedSchedule
    await _notificationsPlugin.zonedSchedule(
      id: todo.id.hashCode,
      title: 'Task Reminder',
      body: 'Your task "${todo.title}" is due!',
      scheduledDate: tz.TZDateTime.from(todo.dueDate!, tz.local),
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancelNotification(String todoId) async {
    if (kIsWeb) return;
    await _notificationsPlugin.cancel(id: todoId.hashCode);
  }
}
