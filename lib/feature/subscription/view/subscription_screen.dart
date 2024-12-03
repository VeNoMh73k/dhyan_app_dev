import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/storage/preference_helper.dart';
import 'package:meditationapp/core/theme/theme_manager.dart';
import 'package:meditationapp/feature/home/view/home_screen.dart';
import 'package:meditationapp/feature/subscription/view/thankyou_subscription_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool? isSubscribe;

  final InAppPurchase _iap = InAppPurchase.instance;
  static const String _subscriptionProductId = 'com.dhyanlife.app.subscription';
  // static const String _subscriptionProductId = 'com.dhyanlife.app.subscription.monthly';
  // static const String _subscriptionProductId = 'com.dhyanlife.app.subscription.yearly';
  ProductDetails? _subscriptionProduct;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isSubscribe = PreferenceHelper.getBool(PreferenceHelper.isSubscribe);
    _initializePurchaseUpdates();
    _getSubscriptionProduct();
  }


  Future<void> _getSubscriptionProduct() async {
    final ProductDetailsResponse response =
    await _iap.queryProductDetails({_subscriptionProductId});

    if (response.notFoundIDs.isNotEmpty) {
      // Handle product not found
      print('Product not found: ${response.notFoundIDs}');
      return;
    }

    print("response${response.productDetails}");
    setState(() {
      _subscriptionProduct = response.productDetails.last;
      print("_subscriptionProduct${_subscriptionProduct?.id}");
    });
  }

  void _initializePurchaseUpdates() {
    _iap.purchaseStream.listen((purchaseDetailsList) {
      for (var purchase in purchaseDetailsList) {
        if (purchase.productID == _subscriptionProductId &&
            purchase.status == PurchaseStatus.purchased) {
          _verifyAndApplySubscription(purchase);
        } else if (purchase.status == PurchaseStatus.error) {
          // Handle errors
          print('Purchase error: ${purchase.error}');
        }
      }
    });
  }


  Future<void> _verifyAndApplySubscription(PurchaseDetails purchase) async {
    // Verify purchase with backend (optional)
    // Apply subscription status locally
    if (purchase.status == PurchaseStatus.purchased) {
      // Save subscription status in your app state
      setState(() {
        isSubscribe = true;
        PreferenceHelper.setBool(PreferenceHelper.isSubscribe, true);
      });

      // Complete the purchase
      await _iap.completePurchase(purchase);
    }
  }

  // Future<void> _checkSubscriptionStatus() async {
  //   final QueryPurchaseDetailsResponse response = await _iap.queryPastPurchases();
  //
  //   for (var purchase in response.pastPurchases) {
  //     if (purchase.productID == _subscriptionProductId &&
  //         purchase.status == PurchaseStatus.purchased) {
  //       setState(() {
  //         isSubscribe = true;
  //         PreferenceHelper.setBool(PreferenceHelper.isSubscribe, true);
  //       });
  //     }
  //   }
  // }


  void _subscribe() {
    if (_subscriptionProduct == null) return;

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: _subscriptionProduct!);
    print("purchaseParam${purchaseParam.productDetails.id}");
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getScaffoldColor(),
      appBar: AppBar(
        backgroundColor: getScaffoldColor(),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ));
          },
          child: Container(
            margin: const EdgeInsets.only(left: 12, bottom: 0, right: 0),
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.arrow_back,
              color: AppColors.blackColor,
            ),
          ),
        ),
        title: AppUtils.commonTextWidget(
          text: "Subscription",
          textColor: AppColors.blackColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          children: [
            AppUtils.commonTextWidget(
                text:
                    "Unlock exclusive track and continue meditation with a premium track!",
                maxLines: 2,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                textColor: AppColors.blackColor,
                textAlign: TextAlign.center),
            const SizedBox(
              height: 34,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/subscription_icon.png",
                  width: 25,
                  height: 25,
                ),
                const SizedBox(
                  width: 5,
                ),
                AppUtils.commonTextWidget(
                    text: "Benefits of Premium",
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    textColor: AppColors.blackColor)
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppUtils.successImage(
                    height: 20, width: 20, color: Colors.green, iconsSize: 14),
                const SizedBox(
                  width: 5,
                ),
                AppUtils.commonTextWidget(
                    text: "Ad-Free Experience",
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    textColor: AppColors.blackColor)
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppUtils.successImage(
                    height: 20, width: 20, color: Colors.green, iconsSize: 14),
                const SizedBox(
                  width: 5,
                ),
                AppUtils.commonTextWidget(
                    text: "Exclusive Content",
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    textColor: AppColors.blackColor)
              ],
            ),
            const SizedBox(
              height: 32,
            ),
            AppUtils.commonTextWidget(
                text: "Choose Your Plan",
                fontWeight: FontWeight.w700,
                fontSize: 18,
                textColor: AppColors.blackColor),
            const SizedBox(
              height: 10,
            ),
            AppUtils.commonContainer(
                padding: const EdgeInsets.only(
                    top: 16, left: 16, right: 16, bottom: 16),
                decoration: AppUtils.commonBoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.whiteColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppUtils.commonTextWidget(
                            text: "Monthly Plan",
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            textColor: AppColors.blackColor),
                        AppUtils.commonTextWidget(
                            text: "₹100.00 / Month",
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            textColor: AppColors.primaryColor),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    AppUtils.commonTextWidget(
                      text: "Billed monthly, cancel anytime.",
                      textColor: AppColors.darkGreyColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    isSubscribe == true
                        ? Center(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                side: BorderSide(
                                    color: Colors.red), // Border color
                              ),
                              onPressed: () {
                                //show pop Up
                                showCancelSubscriptionPopUp();
                              },
                              child: AppUtils.commonTextWidget(
                                text: "Cancel Subscription",
                                textColor: Colors.red,
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : AppUtils.commonElevatedButton(
                            text: "Subscribe Now",
                            onPressed: () {
                              print("testttttt");
                              _subscribe();
                              // PreferenceHelper.setBool(
                              //     PreferenceHelper.isSubscribe, true);
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) =>
                              //           const ThankYouSubscriptionScreen(),
                              //     ));
                            },
                            buttonWidth: double.infinity,
                            leftMargin: 80,
                            rightMargin: 80),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  showCancelSubscriptionPopUp() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: getPopUpColor(),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Dynamically adjusts height
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
                  padding:
                      const EdgeInsets.only(left: 32, right: 32, bottom: 16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.block,
                        size: 90,
                        color: AppColors.cancelColor,
                      ),
                      AppUtils.commonTextWidget(
                        text: "Cancel Subscription",
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                      const SizedBox(height: 14),
                      AppUtils.commonTextWidget(
                          text:
                              "Are you sure you want to cancel it? After cancelling you can’t access premium track.",
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          maxLines: 2,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          AppUtils.commonElevatedButton(
                            backgroundColor: AppColors.cancelColor,
                            leftMargin: 40,
                            rightMargin: 40,
                            text: "Cancel",
                            textColor: AppColors.whiteColor,
                            buttonWidth: double.infinity,
                            onPressed: () {
                              PreferenceHelper.setBool(
                                  PreferenceHelper.isSubscribe, false);
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomeScreen(),
                                  ));
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: AppUtils.commonTextWidget(
                                  text: "Close",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  textColor: AppColors.darkGreyColor))
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
