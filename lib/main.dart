import 'package:flutter/material.dart';
import 'package:meditationapp/core/storage/preference_helper.dart';
import 'package:meditationapp/feature/home/view/home.dart';
import 'package:meditationapp/feature/home/provider/home_provider.dart';
import 'package:meditationapp/service/notifi_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:timezone/data/latest.dart' as tz;

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
List<SingleChildWidget> providers = [
  ChangeNotifierProvider<HomeProvider>(create: (_) => HomeProvider()),
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the timezone plugin
  NotificationService().initNotification();
  tz.initializeTimeZones();
  PreferenceHelper.load().then(
    (value) async {
      if (value?.containsKey(PreferenceHelper.isReminderOn) == false) {
        value?.setBool(PreferenceHelper.isReminderOn, true);
      }
      if (value?.containsKey(PreferenceHelper.reminderHour) == false ||
          value?.containsKey(PreferenceHelper.reminderHour)== false) {
        value?.setString(PreferenceHelper.reminderHour, '08');
        value?.setString(PreferenceHelper.reminderMin, '30');
        NotificationService().scheduleNotification(
            scheduledNotificationDateTime: DateTime(DateTime.now().year,
                DateTime.now().month, DateTime.now().day, 08, 30));
      }
    },
  );
  // Initialize notification plugin
  // await ReminderManager.initNotificationPlugin();
  runApp(
    MultiProvider(
      providers: providers,
      child: MaterialApp(
          builder: (context, child) {
            final MediaQueryData data = MediaQuery.of(context);
            return MediaQuery(
              data: data.copyWith(
                  alwaysUse24HourFormat: false,
                  textScaler: TextScaler.linear(
                      data.textScaleFactor > 1.0 ? 1.0 : data.textScaleFactor)),
              child: child ?? Container(),
            );
          },
          debugShowCheckedModeBanner: false,
          home: const MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meditation App',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
