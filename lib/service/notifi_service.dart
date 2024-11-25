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

  Future<void> scheduleNotification({
    int id = 0,
    String? payLoad,
    required DateTime selectedTime, // The time user selected
    required List<bool> selectedDays, // Array of days (Mon-Sun)
  }) async {
    final now = DateTime.now();
    final tz.TZDateTime tzNow = tz.TZDateTime.now(tz.local);

    // Loop through all days of the week and schedule notifications for the selected days
    for (int i = 0; i < 7; i++) {
      if (selectedDays[i]) {
        // Calculate the difference between today and the selected day (i)
        int dayDifference = (i - tzNow.weekday + 7) % 7;
        tz.TZDateTime scheduledDate = tzNow.add(Duration(days: dayDifference));

        // Set the correct time on the scheduled date
        scheduledDate = tz.TZDateTime(
          tz.local,
          scheduledDate.year,
          scheduledDate.month,
          scheduledDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        // Schedule the notification for the calculated date and time
        await notificationsPlugin.zonedSchedule(
          id,
          'Reminder',
          'It\'s time for your meditation!',
          scheduledDate,
          await notificationDetails(),
          matchDateTimeComponents: DateTimeComponents.time,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  // Cancel daily notifications
  Future<void> cancelNotifications() async {
    await notificationsPlugin.cancel(0);
  }
}
