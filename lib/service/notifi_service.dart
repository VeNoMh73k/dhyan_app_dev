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
      { int? id, String? title, String? body, String? payLoad}) async {
    return notificationsPlugin.show(
        id ?? 0, title, body, await notificationDetails());
  }

  Future<void> scheduleWeeklyNotifications(
      List<int> weekdays,
      TimeOfDay time,
      Map<int, String> dayUuidMap,
      ) async {
    for (var entry in dayUuidMap.entries) {
      int weekday = entry.key; // Day index (0 = Sunday, 1 = Monday, ...)
      String uuid = entry.value; // Corresponding UUID
      print("uuid$uuid");
      print("uuidWithHashcode${uuid.hashCode}");
      print("weekday$weekday");

      if (weekdays.contains(weekday)) {
        var scheduleDate = DateTime.now();
        scheduleDate = _getNextWeekday(scheduleDate, weekday, time);
        scheduleDate = DateTime(
          scheduleDate.year,
          scheduleDate.month,
          scheduleDate.day,
          time.hour,
          time.minute,
        );

        var androidDetails = const AndroidNotificationDetails(
          'weekly_notification_channel',
          'Weekly Notifications',
          channelDescription: 'This channel is for weekly notifications.',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
        );

        var platformDetails = NotificationDetails(android: androidDetails);


        try {
          await notificationsPlugin.zonedSchedule(
            uuid.hashCode, // Use UUID hash as unique ID
            'Hi Meditator!',
            "Let's Start Meditation, Your daily meditation time is started.",
            tz.TZDateTime.from(scheduleDate, tz.local),
            platformDetails,
            androidAllowWhileIdle: true,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            payload: 'weekly_reminder',
            uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
          );
        } catch (e) {
          print("Error scheduling notification: $e");
        }
      }
    }
  }

  DateTime _getNextWeekday(DateTime currentDate, int weekday, TimeOfDay targetTime) {
    print("weekDay$weekday");
    int daysToAdd = (weekday - currentDate.weekday) % 7;

    // Check if today is the target day
    if (daysToAdd == 0) {
      DateTime todayWithTargetTime = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        targetTime.hour,
        targetTime.minute,
      );
      if (currentDate.isBefore(todayWithTargetTime)) {
        // If the target time has not passed, return today
        print("Scheduling_for_today$todayWithTargetTime");
        return todayWithTargetTime;
      } else {
        daysToAdd = 7;
        print("SevenDayAdded for next week");
      }
    } else if (daysToAdd < 0) {
      daysToAdd += 7;
      print("SevenDayAdded");
    }

    // Add the required days to get the next weekday
    DateTime scheduleDate = currentDate.add(Duration(days: daysToAdd));
    return DateTime(
      scheduleDate.year,
      scheduleDate.month,
      scheduleDate.day,
      targetTime.hour,
      targetTime.minute,
    );
  }


// Cancel daily notifications
  Future<void> cancelNotifications(String id) async {
    print("cancelId${id.hashCode}");
    await notificationsPlugin.cancel(id.hashCode);

  }
}