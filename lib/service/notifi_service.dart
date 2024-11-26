import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
    const AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName',
            importance: Importance.max),
        iOS: DarwinNotificationDetails());
  }

  Future showNotification(
      {int id = 0, String? title, String? body, String? payLoad}) async {
    return notificationsPlugin.show(
        id, title, body, await notificationDetails());
  }

  Future<void> scheduleWeeklyNotifications(List<int> weekdays,
      // Weekdays (1=Monday, 2=Tuesday, ..., 7=Sunday)
      TimeOfDay time, // Time to schedule the notification
      ) async {
    for (var weekday in weekdays) {
      var scheduleDate = DateTime.now();
      scheduleDate = _getNextWeekday(scheduleDate, weekday);
      scheduleDate = DateTime(scheduleDate.year, scheduleDate.month,
          scheduleDate.day, time.hour, time.minute);

      var androidDetails = AndroidNotificationDetails(
        'weekly_notification_channel',
        'Weekly Notifications',
        channelDescription: 'This channel is for weekly notifications.',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
      );

      var platformDetails = NotificationDetails(android: androidDetails);

      // Schedule the notification
      await notificationsPlugin.zonedSchedule(
        0, // Notification ID
        'Hi Meditator!', // Notification title
        "Let's Start Meditation, Your daily meditation time is started.", // Notification body
        tz.TZDateTime.from(scheduleDate, tz.local),
        // Time to trigger the notification
        platformDetails,
        androidAllowWhileIdle: true,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'weekly_reminder',
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
            .absoluteTime,
      );
    }
  }

  // Helper function to get the next weekday date
  DateTime _getNextWeekday(DateTime currentDate, int weekday) {
    int daysToAdd = (weekday - currentDate.weekday) % 7;
    if (daysToAdd <= 0) {
      daysToAdd += 7;
    }
    return currentDate.add(Duration(days: daysToAdd));
  }

// Cancel daily notifications
  Future<void> cancelNotifications() async {
    await notificationsPlugin.cancel(0);
  }
}