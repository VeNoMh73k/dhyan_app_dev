import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/theme/theme_manager.dart';
import 'package:meditationapp/feature/feedback/view/thankyou_for_tip_screen.dart';
import 'package:meditationapp/feature/home/view/music_list_screen.dart';
import 'package:meditationapp/feature/subscription/view/subscription_screen.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  double? rating;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: getScaffoldColor(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: getScaffoldColor(),
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MusicListScreen(),
                ));
          },
          child: Container(
            margin: const EdgeInsets.only(left: 12, bottom: 0, right: 0),
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.arrow_back,
              color: getTextColor(),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top banner
            Container(
              width: size.width,
              height: size.height * 0.2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.greyColor,
              ),
            ),
            const SizedBox(height: 20),

            // Main content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppUtils.successImage(),
                  const SizedBox(height: 20),
                  AppUtils.commonTextWidget(
                    text: "You have completed meditation of",
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    textColor: getTextColor(),
                  ),
                  const SizedBox(height: 8),
                  AppUtils.commonTextWidget(
                    text: "Breath & Relax",
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    textColor: getTextColor(),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MusicListScreen(),
                        ),
                      );
                    },
                    child: AppUtils.commonTextWidget(
                      text: "Start New Track",
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      textColor: getTextColor(),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: () {
                      shoFeedBackPopUpView();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: AppUtils.commonTextWidget(
                        text: "Provide Your Feedback",
                        textColor: getTextColor(),
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 0),

            // Favorites and Buttons
            Column(
              children: [
                Icon(Icons.favorite, size: 30, color: getPrimaryColor()),
                const SizedBox(height: 4),
                AppUtils.commonTextWidget(
                  text: "Favorites",
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  textColor: getTextColor(),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AppUtils.commonElevatedButton(
                        text: "Tip₹${100.00}",
                        onPressed: () {
                          //Navigate to Thank you page
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ThankYouForTipScreen(),
                              ));
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppUtils.commonElevatedButton(
                        text: "Get Subscription",
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SubscriptionScreen(),));
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  shoFeedBackPopUpView() {
    return AppUtils.showFeedBackPopUp(
        context: context,
        title: "Your Feedback",
        subTitle: 'Provide your feedback so we can improve it.',
        widgetList: [
          StarRating(
              rating: 3.0,
              size: 60,
              allowHalfRating: false,
              filledIcon: Icons.star_rounded,
              // halfFilledIcon: Icons.favorite_border,
              emptyIcon: Icons.star_rounded,
              starCount: 5,
              color: AppColors.ratingStarColor,
              borderColor: AppColors.greyColor,
              onRatingChanged: (rating) {}),
          Padding(
            padding:
                const EdgeInsets.only(left: 0, right: 0, top: 20, bottom: 20),
            child: TextField(
              maxLines: 4,
              decoration: InputDecoration(
                enabled: true,
                fillColor: AppColors.greyColor,
                // Use your defined grey color
                filled: true,
                // This makes the background color visible
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                  borderSide: BorderSide.none, // No border
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  // Keep the same corners
                  borderSide: BorderSide.none, // No border on focus
                ),
                hintText: "Typing here..", // Optional hint text
              ),
            ),
          ),
          AppUtils.commonElevatedButton(
            bottomMargin: 30,
            leftPadding: 25,
            rightPadding: 25,
            buttonWidth: 170,
            text: "Submit",
            onPressed: () {
              //submit

              //close pop
              Navigator.of(context).pop();
            },
          )
        ]);
  }
}
