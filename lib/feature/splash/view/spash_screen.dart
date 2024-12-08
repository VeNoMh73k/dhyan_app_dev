import 'dart:async'; // Needed for StreamSubscription

import 'package:flutter/material.dart';
import 'package:meditationapp/core/storage/preference_helper.dart';
import 'package:meditationapp/core/theme/theme_manager.dart';
import 'package:meditationapp/feature/home/view/home_screen.dart';
import 'package:onepref/onepref.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  IApEngine iApEngine = IApEngine();
  late StreamSubscription splashStream;

  @override
  void initState() {
    super.initState();
    print("returned");
    saveDate();
    restoreSubscription();
    splashStream = iApEngine.inAppPurchase.purchaseStream.listen(
          (list) {
            print("datatest");
        if (list.isNotEmpty) {
          // Restore the subscription
          updateSubscriptionStatus(true);
          print("SubscriptionData: ${list.first.verificationData.localVerificationData}");
          _navigateToHomeScreen();
        } else {
          // Not subscribed
          updateSubscriptionStatus(false);
          print("NotSubscribed");
          _navigateToHomeScreen();
        }
      },
    );
  }

  // Save the current date to preferences
  void saveDate() {
    DateTime todayDate = DateTime.now();
    print("todayDate: ${todayDate.toString()}");
    PreferenceHelper.setString("todayDate", todayDate.toString());
  }

  // Restore subscriptions
  Future<void> restoreSubscription() async {
    await iApEngine.inAppPurchase.restorePurchases();
  }

  // Update subscription status in preferences
  void updateSubscriptionStatus(bool isSubscribed) {
    PreferenceHelper.setBool(PreferenceHelper.isSubscribe, isSubscribed);
  }

  // Navigate to the HomeScreen
  void _navigateToHomeScreen() {
    Future.delayed(const Duration(milliseconds: 2500), () {
      splashStream.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });

  }

  @override
  void dispose() {
    // TODO: implement dispose
    splashStream.cancel();
    super.dispose();


  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getSplashScreenBackground(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image.asset("assets/logo_dhyan_light.png"),
          ),
        ],
      ),
    );
  }
}
