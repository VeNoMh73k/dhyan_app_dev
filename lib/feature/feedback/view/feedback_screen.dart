import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/image_path.dart';
import 'package:meditationapp/core/storage/preference_helper.dart';
import 'package:meditationapp/core/theme/theme_manager.dart';
import 'package:meditationapp/feature/feedback/view/thankyou_for_tip_screen.dart';
import 'package:meditationapp/feature/home/view/home_screen.dart';
import 'package:meditationapp/feature/home/view/music_list_screen.dart';
import 'package:meditationapp/feature/subscription/view/subscription_screen.dart';

class FeedbackScreen extends StatefulWidget {
  String? titleName;
  String? trackId;

  FeedbackScreen({super.key, this.trackId, this.titleName});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getInitialFav();
  }
  bool savedFavVar = false;

  getInitialFav() async {
    final key = 'isFav_${widget.trackId}'; // Use unique ID for each item
    savedFavVar = PreferenceHelper.getBool(key);
    setState(() {});
  }

  toggleFav() async {
    final key = 'isFav_${widget.trackId}'; // Use unique ID for each item
    savedFavVar = PreferenceHelper.getBool(key);
    final newValue = savedFavVar ? false : true;
    await PreferenceHelper.setBool(key, newValue);
    savedFavVar = newValue;
    setState(() {});
  }


  goBack() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () {
        return goBack();
      },
      child: Scaffold(
        backgroundColor: getScaffoldColor(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: getScaffoldColor(),
          leading: GestureDetector(
            onTap: () {
              goBack();
            },
            child: Container(
              margin: const EdgeInsets.only(left: 0, bottom: 0, right: 0),
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

              Image.asset(
                adImage,
                fit: BoxFit.cover,
                width: size.width,
                height: size.height * 0.2,
              ),

              const SizedBox(height: 20),

              // Main content
              Expanded(
                child: SingleChildScrollView(
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
                        text: widget.titleName ?? "",
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        textColor: getTextColor(),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
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
              ),
              // const SizedBox(height: 0),

              // Favorites and Buttons
              Column(
                children: [
                  GestureDetector(
                      onTap: () {
                        toggleFav();
                      },
                      child: Icon(Icons.favorite,
                          size: 30,
                          color:
                          savedFavVar ? getPrimaryColor() : AppColors.greyColor)),
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
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SubscriptionScreen(),
                                ));
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
      ),
    );
  }

  shoFeedBackPopUpView() {
    double selectedRating = 3.0; // Default rating

    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: getPopUpColor(),
              insetPadding: const EdgeInsets.symmetric(horizontal: 0),
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  // Dynamically adjusts height
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            // Close on tap
                            child: AppUtils.commonContainer(
                              margin: const EdgeInsets.only(right: 12, top: 12),
                              height: 30,
                              width: 30,
                              decoration: AppUtils.commonBoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.blackColor,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                color: AppColors.whiteColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 32, right: 32),
                      child: Column(
                        children: [
                          AppUtils.commonTextWidget(
                            text: "Your Feedback",
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                          const SizedBox(height: 14),
                          AppUtils.commonTextWidget(
                            text: "Provide your feedback so we can improve it.",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          const SizedBox(height: 16),
                          StarRating(
                              rating: selectedRating,
                              size: 60,
                              allowHalfRating: false,
                              filledIcon: Icons.star_rounded,
                              // halfFilledIcon: Icons.favorite_border,
                              emptyIcon: Icons.star_rounded,
                              starCount: 5,
                              color: AppColors.ratingStarColor,
                              borderColor: AppColors.greyColor,
                              onRatingChanged: (rating) {
                                setState(() {
                                  print("rating$rating");
                                  selectedRating = rating;
                                  print("selectedRating$selectedRating");
                                });
                              }),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 0, right: 0, top: 20, bottom: 20),
                            child: TextField(
                              maxLines: 4,
                              decoration: InputDecoration(
                                enabled: true,
                                fillColor: AppColors.greyColor,
                                // Use your defined grey color
                                filled: true,
                                // This makes the background color visible
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  // Rounded corners
                                  borderSide: BorderSide.none, // No border
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  // Keep the same corners
                                  borderSide:
                                      BorderSide.none, // No border on focus
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
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        });
  }
}
