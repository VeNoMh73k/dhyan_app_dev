import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/storage/preference_helper.dart';
import 'package:meditationapp/feature/home/view/home.dart';
import 'package:meditationapp/feature/home/provider/home_provider.dart';
import 'package:meditationapp/feature/splash/view/spash_screen.dart';
import 'package:meditationapp/service/notifi_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:timezone/data/latest.dart' as tz;

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
List<SingleChildWidget> providers = [
  ChangeNotifierProvider<HomeProvider>(create: (_) => HomeProvider()),
];
ThemeData? currentTheme;

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
          value?.containsKey(PreferenceHelper.reminderHour) == false) {
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
        var brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
    currentTheme =
    brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light();
    var dispatcher = SchedulerBinding.instance.platformDispatcher;

    // This callback is called every time the brightness changes.
    dispatcher.onPlatformBrightnessChanged = () {
      print("change");
      var brightness = dispatcher.platformBrightness;

      // currentTheme =
      //     brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light();
      brightness == Brightness.dark
              ? currentTheme = ThemeData.dark()
              : currentTheme = ThemeData.light();
      print("currentTheme${currentTheme}");
      print("currentTheme${ThemeData.dark()}");
      print("currentTheme${currentTheme == ThemeData.dark()}");
      setState(() {

      });
    };

  }

  // @override
  // void didChangePlatformBrightness() {
  //   // This method is triggered when the system theme changes
  //   setState(() {
  //     // var brightness =
  //     //     SchedulerBinding.instance.platformDispatcher.platformBrightness;
  //     brightness = View.of(context).platformDispatcher.platformBrightness;
  //     brightness == Brightness.dark
  //         ? currentTheme = ThemeData.dark()
  //         : currentTheme = ThemeData.light();
  //   });
  // }

  listner(){

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: navigatorKey,
        theme: currentTheme,
        builder: (context, child) {
          final MediaQueryData data = MediaQuery.of(context);
          // var brightness =
          //     SchedulerBinding.instance.platformDispatcher.platformBrightness;
          // brightness == Brightness.dark
          //     ? currentTheme = ThemeData.dark()
          //     : currentTheme = ThemeData.light();
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
