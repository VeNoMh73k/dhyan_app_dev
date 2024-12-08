import 'package:flutter/material.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/theme/theme_manager.dart';
import 'package:meditationapp/feature/home/view/home_screen.dart';
import 'package:meditationapp/feature/home/view/music_list_screen.dart';

class ThankYouForTipScreen extends StatefulWidget {

  bool? isFromHome;
  ThankYouForTipScreen({super.key,this.isFromHome});

  @override
  State<ThankYouForTipScreen> createState() => _ThankYouForTipScreenState();
}

class _ThankYouForTipScreenState extends State<ThankYouForTipScreen> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async{
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: getScaffoldColor(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppUtils.successImage(),
                const SizedBox(height: 24,),
                AppUtils.commonTextWidget(
                  text: "Thank you for Tip!",
                  fontWeight: FontWeight.w700,
                  fontSize: 20,

                ),
                const SizedBox(height: 10,),
                AppUtils.commonTextWidget(
                  text: "Thank you for your generosity! 🙏",
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                const SizedBox(height: 10,),
                AppUtils.commonTextWidget(
                  text: "Your support makes a difference and helps us continue our mission.",
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10,),
                AppUtils.commonTextWidget(
                  text: "We appreciate your kindness!",
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30,),
                AppUtils.commonElevatedButton(
                  buttonWidth: double.infinity,
                  leftMargin: width * 0.2,
                  rightMargin: width * 0.2,
                  text: "Continue Meditation",
                  onPressed: () {
                    Navigator.pop(context);

                  },

                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
