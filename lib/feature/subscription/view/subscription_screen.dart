import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/storage/preference_helper.dart';
import 'package:meditationapp/core/theme/theme_manager.dart';
import 'package:meditationapp/feature/home/view/home_screen.dart';
import 'package:meditationapp/feature/subscription/view/thankyou_subscription_screen.dart';
import 'package:onepref/onepref.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  //inAppPurchaseInstance
  IApEngine iApEngine = IApEngine();

  //isLoading
  bool isLoading = false;

  //Stream
  late StreamSubscription _subscriptionStream;

  //ProductList
  List<ProductDetails> subscriptionList = [];

  //ProductsId
  static const String _subscriptionProductId = 'com.dhyanlife.app.subscription';
  late final List<ProductId> productId = [
    ProductId(id: _subscriptionProductId, isConsumable: false),
  ];

  //bool to ManageSubscription
  bool? isSubscribe;

  //ManageLocalSubscribe
  void updateSubscriptionStatus(bool isSubscribed) {
    setState(() {
      isSubscribe = isSubscribed;
      PreferenceHelper.setBool(PreferenceHelper.isSubscribe, isSubscribed);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //listen Purchase
    _subscriptionStream = iApEngine.inAppPurchase.purchaseStream.listen(
      (listenPurchaseDetails) {
        //Listen Purchase Details
        print("PurchaseStream");
        listenPurchase(listenPurchaseDetails);
      },
    );

    getSubscriptionList();
  }

  listenPurchase(List<PurchaseDetails> listenPurchaseDetails) async {
    if (listenPurchaseDetails.isNotEmpty) {
      getSubscriptionList();
      for (PurchaseDetails purchase in listenPurchaseDetails) {
        print("Purchase${purchase.purchaseID}");
        if (purchase.status == PurchaseStatus.restored ||
            purchase.status == PurchaseStatus.purchased) {
          print(purchase.verificationData.localVerificationData);

          Map purchaseData =
              json.decode(purchase.verificationData.localVerificationData);

          if (purchaseData['acknowledged']) {
            print("restorePurchase");
            updateSubscriptionStatus(true);
          } else {
            //its FirstTime Purchase
            print("firsTimePurchase");
            if (Platform.isAndroid) {
              final InAppPurchaseAndroidPlatformAddition
                  androidPlatformAddition = iApEngine.inAppPurchase
                      .getPlatformAddition<
                          InAppPurchaseAndroidPlatformAddition>();

              await androidPlatformAddition.consumePurchase(purchase).then(
                (value) {
                  updateSubscriptionStatus(
                    true,
                  );
                },
              );
            }

            if (purchase.pendingCompletePurchase) {
              await iApEngine.inAppPurchase.completePurchase(purchase).then(
                (value) {
                  updateSubscriptionStatus(
                    true,
                  );
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ThankYouSubscriptionScreen(),
                      ));
                },
              );
            }
          }
        } else if (purchase.status == PurchaseStatus.pending ||
            purchase.status == PurchaseStatus.canceled) {
          _subscriptionStream.cancel();
        }
      }
    } else {
      //set Subscription false
      updateSubscriptionStatus(false);
    }
  }

  getSubscriptionList() async {
    setState(() {
      isLoading = true;
    });
    await iApEngine.getIsAvailable().then(
      (value) {
        if (value) {
          //query for products
          iApEngine.queryProducts(productId).then(
            (res) {
              subscriptionList.clear();
              print("Response${res.productDetails.length}");
              double rawPrice = PreferenceHelper.getDouble("rawPrice") ?? 0.0;
              if (rawPrice != 0.0) {
                print("rowPrice$rawPrice");
                setState(() {
                  subscriptionList = res.productDetails
                      .where(
                        (element) => element.rawPrice == rawPrice,
                      )
                      .toList();
                  isSubscribe =
                      PreferenceHelper.getBool(PreferenceHelper.isSubscribe);
                });
                print("subscriptionList$subscriptionList");
              } else {
                print("responselength${res.productDetails.length}");

                setState(() {
                  subscriptionList = res.productDetails;
                  isSubscribe =
                      PreferenceHelper.getBool(PreferenceHelper.isSubscribe);
                });
                print("subscriptionList$subscriptionList");
              }
            },
          );
        }
      },
    );
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _subscriptionStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getScaffoldColor(),
      appBar: AppBar(
        backgroundColor: getScaffoldColor(),
        centerTitle: true,
        leading: AppUtils.backButton(
            onTap: () {
              Navigator.pop(context);
            },
            color: AppColors.blackColor),
       /* GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.only(left: 12, bottom: 0, right: 0),
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.arrow_back,
              color: AppColors.blackColor,
            ),
          ),
        ),*/
        title: AppUtils.commonTextWidget(
          text: "Subscription",
          textColor: AppColors.blackColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: isLoading == true
          ? AppUtils.loaderWidget()
          : SingleChildScrollView(
              child: Padding(
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
                            height: 20,
                            width: 20,
                            color: Colors.green,
                            iconsSize: 14),
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
                            height: 20,
                            width: 20,
                            color: Colors.green,
                            iconsSize: 14),
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
                    ListView.builder(
                      itemCount: subscriptionList.length,
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return AppUtils.commonContainer(
                            margin: const EdgeInsets.only(bottom: 16),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: AppUtils.commonTextWidget(
                                          text: subscriptionList[index].title,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          textColor: AppColors.blackColor,
                                          maxLines: 2),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    AppUtils.commonTextWidget(
                                        text:
                                            "${subscriptionList[index].price} /${subscriptionList[index] == subscriptionList.last ? 'Year' : 'Month'}",
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        textColor: AppColors.primaryColor),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                AppUtils.commonTextWidget(
                                  text:
                                      "Billed ${subscriptionList[index] == subscriptionList.last ? 'Yearly' : 'Monthly'}, cancel anytime.",
                                  textColor: AppColors.darkGreyColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                PreferenceHelper.getBool(
                                        PreferenceHelper.isSubscribe)
                                    ? Center(
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            side: BorderSide(
                                                color:
                                                    Colors.red), // Border color
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
                                          iApEngine.handlePurchase(
                                              subscriptionList[index],
                                              productId);
                                          PreferenceHelper.setDouble("rawPrice",
                                              subscriptionList[index].rawPrice);
                                        },
                                        buttonWidth: double.infinity,
                                        leftMargin: 80,
                                        rightMargin: 80),
                              ],
                            ));
                      },
                    )
                  ],
                ),
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
                        onTap: () {
                          Navigator.of(context).pop();
                        },
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
                              // PreferenceHelper.setBool(
                              //     PreferenceHelper.isSubscribe, false);
                              // Navigator.pushReplacement(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) => const HomeScreen(),
                              //     ));
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
