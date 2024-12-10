import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meditationapp/core/storage/preference_helper.dart';
import 'package:meditationapp/feature/home/provider/home_provider.dart';
import 'package:meditationapp/feature/splash/view/spash_screen.dart';
import 'package:meditationapp/firebase_options.dart';
import 'package:meditationapp/service/fcm_notification_service.dart';
import 'package:meditationapp/service/notifi_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:timezone/data/latest.dart' as tz;

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//Global Variables
bool isSubscribe = false;
String subscriptionId = "";
int savedMinutes = 0;
int daysOfMeditation = 0;
int sessions = 0;
PurchaseDetails?  purchaseDetails;

List<SingleChildWidget> providers = [
  ChangeNotifierProvider<HomeProvider>(create: (_) => HomeProvider()),
];

ThemeData? currentTheme = ThemeData.dark();



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (Platform.isAndroid) {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
  await PushNotificationService().initializePushNotification();
  // Initialize the timezone plugin
  NotificationService().initNotification();
  tz.initializeTimeZones();
  PreferenceHelper.load().then(
    (value) async {
      if (value?.containsKey(PreferenceHelper.isReminderOn) == false) {
        value?.setBool(PreferenceHelper.isReminderOn, true);
      }
      if (value?.containsKey(PreferenceHelper.reminderHour) == false ||
          value?.containsKey(PreferenceHelper.reminderHour) == false) {
        value?.setString(PreferenceHelper.reminderHour, '08');
        value?.setString(PreferenceHelper.reminderMin, '30');
      }
    },
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MultiProvider(providers: providers, child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    getFcmToken();
    var brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    brightness == Brightness.dark
        ? currentTheme = ThemeData.dark()
        : currentTheme = ThemeData.light();
    print("currentTheme$currentTheme");
    setState(() {});

  }


  getFcmToken()async{
   String? fcmToken = PreferenceHelper.getString("FCM_TOKEN") ?? "";
   if(fcmToken == ""){
     fcmToken = await FirebaseMessaging.instance.getToken();
   }else{
     return fcmToken;
   }
   print("FCMToke$fcmToken");
   return fcmToken;
  }


  @override
  void didChangePlatformBrightness() {
    setState(() {
      var brightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      brightness = View.of(context).platformDispatcher.platformBrightness;
      brightness == Brightness.dark
          ? currentTheme = ThemeData.dark()
          : currentTheme = ThemeData.light();
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: navigatorKey,
        theme: currentTheme,
        builder: (context, child) {
          final MediaQueryData data = MediaQuery.of(context);
          var brightness =
              SchedulerBinding.instance.platformDispatcher.platformBrightness;
          brightness == Brightness.dark
              ? currentTheme = ThemeData.dark()
              : currentTheme = ThemeData.light();
          return MediaQuery(
            data: data.copyWith(
                alwaysUse24HourFormat: false,
                textScaler: TextScaler.linear(
                    data.textScaleFactor > 1.0 ? 1.0 : data.textScaleFactor)),
            child: child ?? Container(),
          );
        },
        debugShowCheckedModeBanner: false,
        home: const SplashScreen());
  }
}
