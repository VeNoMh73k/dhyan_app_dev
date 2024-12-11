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
import 'package:meditationapp/feature/subscription/view/thankyou_subscription_screen.dart';
import 'package:meditationapp/main.dart';
import 'package:onepref/onepref.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

class SubscriptionScreen extends StatefulWidget {
  SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with WidgetsBindingObserver {
  //inAppPurchaseInstance
  IApEngine iApEngine = IApEngine();

  String title = "";

  //isLoading
  bool isLoading = false;

  //Stream
  late StreamSubscription _subscriptionStream;

  //ProductList
  List<ProductDetails> subscriptionList = [];

  //ProductsId
  static const String _monthlySubscriptionProductId =
      'com.dhyanlife.app.subscription.monthly';
  static const String _yearlySubscriptionProductId =
      'com.dhyanlife.app.subscription.yearly';
  static const String _lifeTimeSubscriptionProductId =
      'com.dhyanlife.app.product.lifetime';
  late final List<ProductId> productId = [
    ProductId(id: _monthlySubscriptionProductId, isConsumable: false),
    ProductId(id: _yearlySubscriptionProductId, isConsumable: false),
    ProductId(
        id: _lifeTimeSubscriptionProductId,
        isConsumable: false,
        isOneTimePurchase: true),
  ];

  //bool to ManageSubscription

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
    WidgetsBinding.instance.addObserver(this);

    isSubscribe = PreferenceHelper.getBool(PreferenceHelper.isSubscribe);
    print("isSubscribe$isSubscribe");

    _subscriptionStream = iApEngine.inAppPurchase.purchaseStream.listen(
          (listenPurchaseDetails) {
        //Listen Purchase Details
        print("PurchaseStream");
        listenPurchase(listenPurchaseDetails);
      },
    );

    getSubscriptionList();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!mounted) return;
    setState(() {});
    debugPrint("AppLifecycleState changed to: $state");
  }

  listenPurchase(List<PurchaseDetails> listenPurchaseDetails) async {
    if (listenPurchaseDetails.isNotEmpty) {
      for (PurchaseDetails purchase in listenPurchaseDetails) {
        print("Purchase${purchase.purchaseID}");
        if (purchase.status == PurchaseStatus.restored ||
            purchase.status == PurchaseStatus.purchased) {
          Map purchaseData =
          json.decode(purchase.verificationData.localVerificationData);

          setState(() {});
          print(purchase.verificationData.localVerificationData);


          if (purchaseData['acknowledged']) {
            print("restorePurchase");

            updateSubscriptionStatus(true);
          } else {
            //its FirstTime Purchase
            print("firsTimePurchase");
            // if (Platform.isAndroid) {
            //   final InAppPurchaseAndroidPlatformAddition
            //       androidPlatformAddition = iApEngine.inAppPurchase
            //           .getPlatformAddition<
            //               InAppPurchaseAndroidPlatformAddition>();
            //
            //   await androidPlatformAddition.consumePurchase(purchase).then(
            //     (value) {
            //       subscriptionId = purchaseData["productId"];
            //       print("subscription$subscriptionId");
            //       updateSubscriptionStatus(
            //         true,
            //       );
            //       getSubscriptionList();
            //     },
            //   );
            // }

            if (purchase.pendingCompletePurchase) {
              await iApEngine.inAppPurchase.completePurchase(purchase).then(
                    (value) {
                  subscriptionId = purchaseData["productId"];

                  getSubscriptionList();
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
          getSubscriptionList();
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
              print("subscriptionId$subscriptionId");

              if (isSubscribe == true) {
                setState(() {
                  subscriptionList =
                      res.productDetails.where((element) => element.id ==
                          subscriptionId,).toList();
                  print("responseData${subscriptionList.first.title}");
                  isLoading = false;
                });
              } else {
                setState(() {
                  subscriptionList = res.productDetails;
                  subscriptionList.sort((a, b) =>
                      a.rawPrice.compareTo(b.rawPrice));
                  isLoading = false;
                });
              }
              print("Sorted subscriptionList$subscriptionList");
            },
          );
        } else {
          setState(() {
            isLoading = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _subscriptionStream.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getScaffoldColor(),
      appBar: AppBar(
          backgroundColor: getScaffoldColor(),
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          leading: AppUtils.backButton(
              onTap: () {
                Navigator.pop(context);
              },
              color: getTextColor()),
          title: AppUtils.commonTextWidget(
            text: "Subscription",
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          actions: [
            isSubscribe == true &&  subscriptionId == _lifeTimeSubscriptionProductId ?
            GestureDetector(
              onTap: () {
                isSubscribe == false ? AppUtils.snackBarFnc(ctx: context,
                    contentText: "You have not purchased Lifetime subscription plan yet, please select a plan to proceed."):
                    subscriptionId == _lifeTimeSubscriptionProductId ?
                showCancelLifetimeSubscriptionPopUp() : const SizedBox();
              },
              child: Icon(
                Icons.info,
                color: getTextColor(),
                size: 26,
              ),
            ) : const SizedBox(),
            const SizedBox(
              width: 12,
            )

          ]
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
                    color: getTextColor(),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  AppUtils.commonTextWidget(
                    text: "Benefits of Premium",
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  )
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
                  )
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
                  )
                ],
              ),
              const SizedBox(
                height: 32,
              ),
              AppUtils.commonTextWidget(
                text: isSubscribe == false
                    ? "Choose Your Plan"
                    : "Manage Your Plan",
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
              const SizedBox(
                height: 10,
              ),
              ListView.builder(
                itemCount: subscriptionList.length,
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final ProductDetails product = subscriptionList[index];
                  title = product.title.split(' (')[0];

                  print("title$title"); // Output: Yearly

                  // Categorize by price
                  String subscriptionType;
                  if (product.rawPrice ==
                      subscriptionList.first.rawPrice) {
                    subscriptionType = "Monthly";
                  } else if (product.rawPrice ==
                      subscriptionList.last.rawPrice) {
                    subscriptionType = "Lifetime";
                  } else {
                    subscriptionType = "Yearly";
                  }

                  return AppUtils.commonContainer(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.only(
                        top: 16, left: 16, right: 16, bottom: 16),
                    decoration: AppUtils.commonBoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: getMusicListTileColor(),
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
                                text: "$title Plan",
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                maxLines: 2,
                              ),
                            ),
                            const SizedBox(width: 10),
                            AppUtils.commonTextWidget(
                              text:
                              "${product.price} / $title",
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              textColor: AppColors.primaryColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        AppUtils.commonTextWidget(
                          text: title == "Lifetime"
                              ? "One-time payment, cancel anytime"
                              : "Billed $title, cancel anytime.",
                          textColor: AppColors.darkGreyColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        const SizedBox(height: 8),
                        PreferenceHelper.getBool(
                            PreferenceHelper.isSubscribe)
                            ? title == "Lifetime" ? AppUtils
                            .commonElevatedButton(
                          backgroundColor: getLifeTimePurchaseColorManager(),
                          text: "Subscribed",
                          onPressed: () async {
                            //this code is only for testing
                            // if (Platform.isAndroid && purchaseDetails != null) {
                            //   final InAppPurchaseAndroidPlatformAddition
                            //       androidPlatformAddition = iApEngine.inAppPurchase
                            //           .getPlatformAddition<
                            //               InAppPurchaseAndroidPlatformAddition>();
                            //
                            //   await androidPlatformAddition.consumePurchase(purchaseDetails!).then(
                            //     (value) {
                            //       // subscriptionId = purchaseDetails?.productID ?? '';
                            //       print("subscription$subscriptionId");
                            //       updateSubscriptionStatus(
                            //         false,
                            //       );
                            //       getSubscriptionList();
                            //     },
                            //   );
                            // }
                          },
                          buttonWidth: double.infinity,
                          leftMargin: 80,
                          rightMargin: 80,
                        ) : Center(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(4),
                              ),
                              side: const BorderSide(
                                color: Colors.red, // Border color
                              ),
                            ),
                            onPressed: () {
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
                                product, productId);
                          },
                          buttonWidth: double.infinity,
                          leftMargin: 80,
                          rightMargin: 80,
                        )
                      ],
                    ),
                  );
                },
              ),
              // if(kDebugMode)


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
                      const SizedBox(height: 16),
                      AppUtils.commonTextWidget(
                        text: "Cancel Subscription",
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                      const SizedBox(height: 12),
                      AppUtils.commonTextWidget(
                          text:
                          "Are you sure you want to cancel it? After cancelling you can’t access premium track.",
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          maxLines: 2,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 22),
                      Column(
                        children: [
                          AppUtils.commonElevatedButton(
                            backgroundColor: AppColors.cancelColor,
                            leftMargin: 60,
                            rightMargin: 60,
                            topPadding: 12,
                            bottomPadding: 12,
                            text: "Cancel",
                            textColor: AppColors.whiteColor,
                            buttonWidth: double.infinity,
                            onPressed: () {
                              Navigator.of(context).pop();
                              AppUtils.launchInBrowser(Uri.parse(
                                  "https://play.google.com/store/account/subscriptions?hl=en"));
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

  showCancelLifetimeSubscriptionPopUp() {
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
                      const SizedBox(height: 16),
                      AppUtils.commonTextWidget(
                        text: "Cancel Subscription",
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                      const SizedBox(height: 12),
                      AppUtils.commonTextWidget(
                          text:
                          "This pop-up is for testing of canceling lifetime subscriptions.",
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          maxLines: 2,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 22),
                      Column(
                        children: [
                          AppUtils.commonElevatedButton(
                            backgroundColor: AppColors.cancelColor,
                            leftMargin: 60,
                            rightMargin: 60,
                            topPadding: 12,
                            bottomPadding: 12,
                            text: "Cancel",
                            textColor: AppColors.whiteColor,
                            buttonWidth: double.infinity,
                            onPressed: () async {
                              Navigator.of(context).pop();
                              if (Platform.isAndroid &&
                                  purchaseDetails != null) {
                                final InAppPurchaseAndroidPlatformAddition
                                androidPlatformAddition = iApEngine
                                    .inAppPurchase
                                    .getPlatformAddition<
                                    InAppPurchaseAndroidPlatformAddition>();

                                await androidPlatformAddition.consumePurchase(
                                    purchaseDetails!).then(
                                      (value) {
                                    // subscriptionId = purchaseDetails?.productID ?? '';
                                    print("subscription$subscriptionId");
                                    updateSubscriptionStatus(
                                      false,
                                    );
                                    getSubscriptionList();
                                  },
                                );
                              }
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
