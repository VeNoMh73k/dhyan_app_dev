import 'package:flutter/material.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/feature/home/view/home_screen.dart';

class ThankYouSubscriptionScreen extends StatelessWidget {
  const ThankYouSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppUtils.successImage(),
              const SizedBox(
                height: 24,
              ),
              AppUtils.commonTextWidget(
                text: "Subscription Subscribed Successfully!",
                fontWeight: FontWeight.w700,
                fontSize: 20,
                textColor: AppColors.blackColor,
                maxLines: 2
              ),
              const SizedBox(
                height: 10,
              ),

              AppUtils.commonTextWidget(
                text:
                    "Your premium access is now active. You can now get all exclusive content and ad-free experience.",
                fontWeight: FontWeight.w400,
                fontSize: 16,
                maxLines: 3,
                textAlign: TextAlign.center,
                textColor: AppColors.blackColor,
              ),
              const SizedBox(
                height: 30,
              ),

              AppUtils.commonElevatedButton(
                buttonWidth: double.infinity,
                leftMargin: 90,
                rightMargin: 90,
                text: "Continue Meditation",
                onPressed: () {
                  //move to list Screen
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen(),));
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
