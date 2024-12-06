import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:meditationapp/service/notifi_service.dart';

// Define the global variable
// String? fcmToken;

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("title: ${message.notification?.title}");
  print("body: ${message.notification?.body}");
  print("data: ${message.data}");
}

Future<void> handleMessage(RemoteMessage? message) async {
  if (message == null) return;
  print("title: ${message.notification?.title}");
  print("body: ${message.notification?.body}");
  print("data: ${message.data}");
}

Future<void> initPushNotification() async {
  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
  FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  FirebaseMessaging.onMessage.listen((event) {
    NotificationService().showNotification(
      id: event.notification.hashCode,
      title: event.notification?.title ?? "",
      body: event.notification?.body ?? "",
    );
  });
}

class PushNotificationService {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initializePushNotification() async {
    await firebaseMessaging.requestPermission();


    await initPushNotification();
  }
}
