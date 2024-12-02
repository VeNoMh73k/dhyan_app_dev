import 'package:flutter/material.dart';
import 'package:meditationapp/core/storage/preference_helper.dart';
import 'package:meditationapp/feature/home/view/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saveDate();
    _navigateToHomeScreen();
  }

  saveDate(){
    DateTime todayDate =  DateTime.now();
    print("todayDate${todayDate.toString()}");
    PreferenceHelper.setString("todayDate", todayDate.toString());
  }

  void _navigateToHomeScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      // After 3 seconds, navigate to the HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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