import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/commnon_widget/common_tip_dialog_widget.dart';
import 'package:meditationapp/core/constants.dart';
import 'package:meditationapp/core/image_path.dart';
import 'package:meditationapp/core/storage/preference_helper.dart';
import 'package:meditationapp/core/theme/theme_manager.dart';
import 'package:meditationapp/feature/feedback/view/thankyou_for_tip_screen.dart';
import 'package:meditationapp/feature/home/view/home_screen.dart';
import 'package:meditationapp/feature/subscription/view/subscription_screen.dart';
import 'package:onepref/onepref.dart';

class FeedbackScreen extends StatefulWidget {
  String titleName;
  String trackId;

  FeedbackScreen({super.key, required this.trackId, required this.titleName});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  late StreamSubscription feedbackStream;

  IApEngine iApEngine = IApEngine();

  late final List<ProductId> productId = [
    ProductId(id: tip1, isConsumable: true, isOneTimePurchase: false),
    ProductId(id: tip2, isConsumable: true, isOneTimePurchase: false),
    ProductId(id: tip3, isConsumable: true, isOneTimePurchase: false),
  ];

  List<ProductDetails> inAppProductList = [];

  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    feedbackStream = iApEngine.inAppPurchase.purchaseStream.listen(
      (list) {
        listenPurchaseStream(list);
      },
    );

    getInitialFav();

    getTipData();
  }

  listenPurchaseStream(List<PurchaseDetails> listenPurchaseDetails) {
    if (listenPurchaseDetails.isNotEmpty) {
      for (PurchaseDetails purchase in listenPurchaseDetails) {
        for (var id in productId) {
          if (id.id == purchase.productID) {
            if (purchase.status == PurchaseStatus.purchased) {
              iApEngine.inAppPurchase.completePurchase(purchase);
              feedbackStream.cancel();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ThankYouForTipScreen(
                      isFromHome: false,
                    ),
                  ));
            } else if (purchase.status == PurchaseStatus.canceled) {
              AppUtils.snackBarFnc(
                  ctx: context, contentText: "Your Purchase has been canceled");
              feedbackStream.cancel();
            } else if (purchase.status == PurchaseStatus.pending) {
              AppUtils.snackBarFnc(
                  ctx: context, contentText: "Your Purchase is pending");
              feedbackStream.cancel();
            }
          }
        }
      }
    }
  }

  getTipData() {
    setState(() {
      isLoading = true;
    });

    iApEngine.getIsAvailable().then(
      (value) {
        if (value) {
          iApEngine.queryProducts(productId).then(
            (res) {
              print("responseData${res.productDetails.length}");
              setState(() {
                inAppProductList = res.productDetails;
              });
            },
          );
        }
      },
    );
    setState(() {
      isLoading = false;
    });

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
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    feedbackStream.cancel();
    super.dispose();
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
          leading: AppUtils.backButton(
            color: getTextColor(),
            onTap: () {
              goBack();
            },
          ),
        ),
        body: isLoading ?  AppUtils.loaderWidget():Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top banner

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  adImage,
                  fit: BoxFit.cover,
                  width: size.width,
                  height: size.height * 0.2,
                ),
              ),

              const SizedBox(height: 20),

              // Main content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      AppUtils.successImage(
                          height: 60, width: 60, iconsSize: 40),
                      const SizedBox(height: 20),
                      AppUtils.commonTextWidget(
                        text: "You have completed meditation of",
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        textColor: getTextColor(),
                      ),
                      const SizedBox(height: 8),
                      AppUtils.commonTextWidget(
                        text: widget.titleName,
                        fontWeight: FontWeight.w700,
                        maxLines: 2,
                        fontSize: 24,
                        textColor: getTextColor(),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
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
                          padding: const EdgeInsets.only(top: 11, bottom: 11),
                          child: AppUtils.commonTextWidget(
                            text: "Provide Your Feedback",
                            textColor: getTextColor(),
                            fontWeight: FontWeight.w500,
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
                          color: savedFavVar
                              ? getPrimaryColor()
                              : AppColors.greyColor)),
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
                          text: "Give Tip",
                          onPressed: () {
                            showTipDialogBox(context, inAppProductList);
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
                                  builder: (context) => SubscriptionScreen(),
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
                              margin: const EdgeInsets.only(right: 15, top: 15),
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
                          const SizedBox(height: 12),
                          AppUtils.commonTextWidget(
                            text: "Provide your feedback so we can improve it.",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          const SizedBox(height: 18),
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
                                left: 0, right: 0, top: 20, bottom: 24),
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
                                hintText: "Type here..",
                                // Optional hint text
                                hintStyle: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color:
                                        AppColors.feedBackTextFieldHintColor),
                              ),
                            ),
                          ),
                          AppUtils.commonElevatedButton(
                            bottomMargin: 30,
                            leftPadding: 25,
                            rightPadding: 25,
                            buttonWidth: 170,
                            topPadding: 12,
                            bottomPadding: 12,
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

  void showTipDialogBox(BuildContext context, List<ProductDetails> list) {
    showDialog(
      context: context,
      builder: (context) {
        return CommonDialog(
          title: "Tip Us",
          description:
              "Tip us to provide more free track, Select the amount you want to tip us.",
          options: list.map((e) => e.price).toList(),
          onSubmit: (selectedIndex) {
            final selectedSubscription = list[selectedIndex];
            iApEngine.handlePurchase(selectedSubscription, productId);

            print("Selected Tip Amount: ${selectedSubscription.price}");
          },
        );
      },
    );
  }
}
