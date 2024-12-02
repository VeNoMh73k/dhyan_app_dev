import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/commnon_widget/common_webview_widget.dart';
import 'package:meditationapp/core/theme/icon_path.dart';
import 'package:meditationapp/core/theme/theme_manager.dart';
import 'package:meditationapp/feature/information/view/about_us_screen.dart';
import 'package:meditationapp/feature/reminder/view/reminder_screen.dart';
import 'package:meditationapp/feature/subscription/view/subscription_screen.dart';

class CommonDrawerWidget extends StatefulWidget {
  AdvancedDrawerController? advancedDrawerController;

  CommonDrawerWidget({super.key, this.advancedDrawerController});

  @override
  State<CommonDrawerWidget> createState() => _CommonDrawerWidgetState();
}

class _CommonDrawerWidgetState extends State<CommonDrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 40, left: 16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                widget.advancedDrawerController?.hideDrawer();
              },
              child: AppUtils.commonContainer(
                padding: EdgeInsets.all(4),
                color: Colors.transparent,
                child: Icon(
                  Icons.close,
                  color: getTextColor(),
                  size: 26,
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            commonRow(
              subscriptionIcon,
              "Subscription",
                  () {
                //Navigate to Subscription Page
                widget.advancedDrawerController?.hideDrawer();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionScreen(),
                    ));
              },
            ),
            commonRow(
              reminderIcon,
              "Reminder",
                  () {
                //Navigate to Reminder,
                widget.advancedDrawerController?.hideDrawer();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReminderScreen(),
                    ));
              },
            ),
            commonRow(
              ratingIcon,
              "Rate Our App",
                  () {
                //Navigate to RatingPage,
                widget.advancedDrawerController?.hideDrawer();
              },
            ),
            commonRow(
              aboutUsIcon,
              "About Us",
                  () {
                //navigate to about us page
                widget.advancedDrawerController?.hideDrawer();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutUsScreen(),
                    ));
              },
            ),
            commonRow(
              termAndConditionIcon,
              "Terms & Conditions",
                  () {
                //navigate to term And Condition Page
                widget.advancedDrawerController?.hideDrawer();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CommonWebViewWidget(
                          title: "Terms & Conditions",
                          url: "https://www.freeprivacypolicy.com/live/f84e755a-037e-45a8-a494-1efea105c77b",
                        )));
              },
            ),
            commonRow(
              privacyAndPolicyIcon,
              "Privacy Policy",
                  () {
                //navigate to privacy policy
                widget.advancedDrawerController?.hideDrawer();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CommonWebViewWidget(
                          title: "Privacy Policy",
                          url: "https://www.freeprivacypolicy.com/live/a7f75c64-0f57-4e4c-a162-a1be30add0b7",
                        )));
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: AppUtils.commonTextWidget(
                  text: "Version 1.1.0",
                  textColor: AppColors.primaryColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 14),
            )
          ],
        ),
      ),
    );
  }

  commonRow(String? icon, String title, Function()? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Image.asset(
          icon ?? '',
          height: 24,
          width:  24,
        ),
        title: AppUtils.commonTextWidget(
            text: title ?? "",
            fontWeight: FontWeight.w400,
            fontSize: 16,
            textColor: AppColors.blackColor),
      ),
    );
  }
}