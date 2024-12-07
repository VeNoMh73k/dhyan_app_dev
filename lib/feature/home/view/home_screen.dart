import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/commnon_widget/common_drawer_widget.dart';
import 'package:meditationapp/core/constants.dart';
import 'package:meditationapp/core/storage/preference_helper.dart';
import 'package:meditationapp/core/theme/icon_path.dart';
import 'package:meditationapp/core/theme/theme_manager.dart';
import 'package:meditationapp/feature/feedback/view/thankyou_for_tip_screen.dart';
import 'package:meditationapp/feature/home/provider/home_provider.dart';
import 'package:meditationapp/feature/home/view/music_list_screen.dart';
import 'package:onepref/onepref.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _advancedDrawerController = AdvancedDrawerController();
  IApEngine iApEngine = IApEngine();
  late HomeProvider homeProvider;
  int savedMinutes = 0;
  int daysOfMeditation = 0;
  int sessions = 0;
  late StreamSubscription homeStream;
  bool _isActive = true;

  //Id

  //ProductIdList
  late final List<ProductId> productId = [
    ProductId(id: tip1, isConsumable: true, isOneTimePurchase: false),
    ProductId(id: tip2, isConsumable: true, isOneTimePurchase: false),
    ProductId(id: tip3, isConsumable: true, isOneTimePurchase: false),
  ];

  //ProductListForBiding
  List<ProductDetails> subscriptionList = [];

  //initialValue
  int? selectedValue;

  //listener for homeScreen
  listenPurchaseStream(List<PurchaseDetails> listenPurchaseDetails)async {
    print("Mount$mounted");
    if(!mounted){
      return;
    }
    print("not_Mount$mounted");
    if (listenPurchaseDetails.isNotEmpty) {
      for (PurchaseDetails purchase in listenPurchaseDetails) {
            if (purchase.status == PurchaseStatus.purchased) {
              await iApEngine.inAppPurchase.completePurchase(purchase).then((value) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ThankYouForTipScreen(
                        isFromHome: true,
                      ),
                    )).then((value) {
                      homeStream.resume();
                    },);
                homeStream.pause();
              },);

            } else if (purchase.status == PurchaseStatus.canceled) {
              AppUtils.snackBarFnc(
                  ctx: context, contentText: "Your Purchase has been canceled");
            } else if (purchase.status == PurchaseStatus.pending) {
              AppUtils.snackBarFnc(
                  ctx: context, contentText: "Your Purchase is pending");
            }

      }
    }
  }

  getTipData() {
    iApEngine.getIsAvailable().then(
      (value) {
        if (value) {
          iApEngine.queryProducts(productId).then(
            (res) {
              print("responseData${res.productDetails.length}");
              setState(() {
                subscriptionList = res.productDetails;
              });
            },
          );
        }
      },
    );
  }

  callHomeApi(HomeProvider homeProvider) {
    savedMinutes = PreferenceHelper.getInt('totalPlayedTime') ?? 0;
    daysOfMeditation = PreferenceHelper.getInt("daysOfMeditation") ?? 0;
    sessions = PreferenceHelper.getInt("sessionCount") ?? 0;
    homeProvider.callGetAllCategoryAndTrack();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        homeProvider = Provider.of<HomeProvider>(context, listen: false);
        callHomeApi(homeProvider);
      },
    );
    homeStream = iApEngine.inAppPurchase.purchaseStream.listen(
      (list) {
          listenPurchaseStream(list);
      },
    );
    getTipData();
  }

  FutureOr streamResumeFnc(){
    print("streamResumeFnc");
    homeStream.resume();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    homeStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    homeProvider = Provider.of<HomeProvider>(context);
    return AdvancedDrawer(
      childDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      animateChildDecoration: true,
      disabledGestures: true,
      controller: _advancedDrawerController,
      rtlOpening: false,
      animationDuration: const Duration(milliseconds: 300),
      backdropColor: AppColors.whiteThemeBackgroundColor,
      backdrop: AppUtils.commonContainer(
          child: Image.asset(
        drawerBackground,
      )),
      drawer: CommonDrawerWidget(
        advancedDrawerController: _advancedDrawerController,
        streamSubscription: homeStream,
        onItemClick: (){
          print("onItemClick");
          homeStream.cancel();
        },
        onReturnFromItem: (){
          print("onReturnFromItem");
          homeStream = iApEngine.inAppPurchase.purchaseStream.listen(
                (list) {
              listenPurchaseStream(list);
            },
          );
          getTipData();
        },
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: getScaffoldColor(),
          appBar: customAppBarWithRoundedCorners(context),
          body: Column(
            children: [
              // ListView for images
              Expanded(
                child: homeProvider.isLoading
                    ? AppUtils.loaderWidget()
                    : homeProvider.getAllCategoryAndTracks == null
                        ? AppUtils.commonTextWidget(text: "No Data Found")
                        : ListView.builder(
                            itemCount: homeProvider.categories.length,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  homeStream.cancel();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MusicListScreen(
                                          bannerImageUrl: homeProvider
                                              .getAllCategoryAndTracks
                                              ?.categories?[index]
                                              .bannerImageUrl,
                                          trackId: homeProvider
                                              .getAllCategoryAndTracks
                                              ?.categories?[index]
                                              .trackIds,
                                          categoryName: homeProvider
                                              .getAllCategoryAndTracks
                                              ?.categories?[index]
                                              .title,
                                          categoryId: homeProvider
                                              .getAllCategoryAndTracks
                                              ?.categories?[index]
                                              .id,
                                        ),
                                      )).then(
                                    (value) {
                                      homeStream = iApEngine.inAppPurchase.purchaseStream.listen(
                                            (list) {
                                          listenPurchaseStream(list);
                                        },
                                      );
                                      getTipData();
                                      savedMinutes = PreferenceHelper.getInt(
                                              'totalPlayedTime') ??
                                          0;
                                      daysOfMeditation = PreferenceHelper.getInt(
                                              "daysOfMeditation") ??
                                          0;
                                      sessions = PreferenceHelper.getInt(
                                              "sessionCount") ??
                                          0;
                                      setState(() {});
                                    },
                                  );
                                },
                                child: Container(
                                  height: 110,
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 16, left: 12, right: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                                    color: AppColors.darkGreyColor,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                                    child: Stack(
                                      children: [
                                        // Image
                                        AppUtils.cacheImage(
                                          imageUrl: homeProvider.categories[index].imageUrl ?? "",
                                          width: double.infinity,
                                        ),
                                        // Gradient overlay
                                        homeProvider.categories[index].textSide == "left" ? Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,

                                            ),
                                          ),
                                        ) :Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [ Colors.black.withOpacity(0.3),Colors.transparent,],
                                              begin: Alignment.centerRight,
                                              end: Alignment.centerLeft,

                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                ,
                              );
                            },
                          ),
              ),

              // Bottom container (fixed)
              AppUtils.commonContainer(
                width: double.infinity,
                padding: const EdgeInsets.only(
                    top: 10, bottom: 10, left: 10, right: 10),
                decoration: BoxDecoration(
                  color: getBottomCountContainerColor(),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      // Adjust opacity for shadow
                      blurRadius: 10,
                      // Blur radius for the shadow
                      offset: const Offset(4, 0), // Position of the shadow
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    bottomCustomRow(savedMinutes.toString().padLeft(2, '0'),
                        "Min of Meditation"),
                    bottomCustomRow(
                        sessions.toString().padLeft(2, '0'), "Session Completed"),
                    bottomCustomRow(daysOfMeditation.toString().padLeft(2, '0'),
                        "Days of Meditation"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  showTipDialogBox(
      BuildContext context, List<ProductDetails> subscriptionList) {
    int selectedIndex = 0; // Default to the first item being selected

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: getPopUpColor(),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16),
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Close button
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: AppUtils.commonContainer(
                          margin: const EdgeInsets.only(right: 15, top: 15),
                          height: 28,
                          width: 28,
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
                    // Title and description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          AppUtils.commonTextWidget(
                            text: "Tip Us",
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                          const SizedBox(height: 12),
                          AppUtils.commonTextWidget(
                            text:
                                "Tip us to provide more free track, Select amount you want to tip us.",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          // Dynamically generated tip options
                          ...List.generate(subscriptionList.length, (index) {
                            final subscription = subscriptionList[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Theme(
                                data: ThemeData(
                                  unselectedWidgetColor:
                                      AppColors.textFieldColor,
                                ),
                                child: RadioListTile<int>(
                                  fillColor: MaterialStateProperty.resolveWith(
                                      (states) {
                                    if (states
                                        .contains(MaterialState.selected)) {
                                      return getPrimaryColor();
                                    }
                                    return AppColors.greyColor;
                                  }),
                                  tileColor: AppColors.textFieldColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  title: AppUtils.commonTextWidget(
                                    text: subscription.price,
                                    textColor: AppColors.blackColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                  value: index,
                                  groupValue: selectedIndex,
                                  activeColor: AppColors.secondaryColor,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedIndex = value!;
                                    });
                                  },
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 26),
                          // Submit button
                          AppUtils.commonElevatedButton(
                            bottomMargin: 30,
                            leftPadding: 25,
                            rightPadding: 25,
                            buttonWidth: 170,
                            topPadding: 12,
                            bottomPadding: 12,
                            text: "Provide Tip",
                            fontWeight: FontWeight.w500,
                            onPressed: () {
                              // Perform action with the selected index
                              final selectedSubscription =
                                  subscriptionList[selectedIndex];
                              iApEngine.handlePurchase(
                                  selectedSubscription, productId);
                              Navigator.of(context).pop();

                              print(
                                  "Selected Tip Amount: ${selectedSubscription.price}");
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget customAppBarWithRoundedCorners(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Adjust opacity for shadow
              blurRadius: 10, // Blur radius for the shadow
              offset: const Offset(0, 4), // Position of the shadow
            ),
          ],
        ),
        child: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          // Make the AppBar background transparent
          elevation: 0,
          // Remove AppBar's default elevation
          toolbarHeight: 60,
          centerTitle: true,
          leading: ClipRRect(
            borderRadius:
                const BorderRadius.only(bottomLeft: Radius.circular(16)),
            child: GestureDetector(
              onTap: () {
                _advancedDrawerController.showDrawer();
              },
              child: AppUtils.commonContainer(
                color: AppColors.whiteColor,
                child: Icon(
                  Icons.menu,
                  size: 30,
                  color: getTextColor(),
                ),
              ),
            ),
          ),
          title: Image.asset(
            dhyanLogoLight,
            height: 32,
            width: 32,
            color: getLogoColor(),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                showTipDialogBox(context, subscriptionList);
              },
              child: AppUtils.commonContainer(
                padding: const EdgeInsets.all(8),
                color: AppColors.whiteColor,
                margin: const EdgeInsets.only(right: 16),
                child: Image.asset(
                  tipIcon,
                  width: 26,
                  height: 26,
                  color: getTipIconColor(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomCustomRow(String? number, String? text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 5, left: 8, right: 8, bottom: 5),
          decoration: BoxDecoration(
              color: getBottomRowContainerColor(),
              borderRadius: const BorderRadius.all(Radius.circular(4))),
          child: AppUtils.commonTextWidget(
            text: number,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            textColor: getTextColor(),
          ),
        ),
        Container(
            // height: 28,
            width: 80,
            padding:
                const EdgeInsets.only(top: 5, left: 8, right: 8, bottom: 5),
            child: AppUtils.commonTextWidget(
                text: text,
                fontWeight: FontWeight.w500,
                fontSize: 12,
                textColor: AppColors.blackColor,
                overflow: TextOverflow.visible)),
      ],
    );
  }
}
