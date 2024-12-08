import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/commnon_widget/common_drawer_widget.dart';
import 'package:meditationapp/core/commnon_widget/common_tip_dialog_widget.dart';
import 'package:meditationapp/core/constants.dart';
import 'package:meditationapp/core/storage/preference_helper.dart';
import 'package:meditationapp/core/theme/icon_path.dart';
import 'package:meditationapp/core/theme/theme_manager.dart';
import 'package:meditationapp/feature/feedback/view/thankyou_for_tip_screen.dart';
import 'package:meditationapp/feature/home/provider/home_provider.dart';
import 'package:meditationapp/feature/home/view/music_list_screen.dart';
import 'package:onepref/onepref.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:meditationapp/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver{
  final _advancedDrawerController = AdvancedDrawerController();
  IApEngine iApEngine = IApEngine();
  late HomeProvider homeProvider;

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
    WidgetsBinding.instance.addObserver(this);
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
  void didChangePlatformBrightness() {
    print("----------------------");
    setState(() {
      var brightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      // brightness = View.of(context).platformDispatcher.platformBrightness;
      brightness == Brightness.dark
          ? currentTheme = ThemeData.dark()
          : currentTheme = ThemeData.light();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
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
      backdropColor: getScaffoldColor(),
      backdrop: currentTheme == ThemeData.dark() ? null : AppUtils.commonContainer(
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
      child: Scaffold(
        backgroundColor: getScaffoldColor(),
        appBar: currentTheme == ThemeData.dark() ? customAppBarWithRoundedCornersForBlackTheme(context) :  customAppBarWithRoundedCorners(context),
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
                                    print("onReturnFromMusicListScreen");
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
                                  color: getScaffoldColor(),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                                  child: Stack(
                                    children: [
                                      // Image
                                      AppUtils.cacheImage(
                                        imageUrl: homeProvider.categories[index].imageUrl ?? "",
                                        width: double.infinity,
                                        fit: BoxFit.cover,
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
            if(currentTheme == ThemeData.light())
              bottomWidget(),
          ],
        ),
      ),
    );
  }

  showTipDialogBox(
      BuildContext context, List<ProductDetails> subscriptionList) {

    return showDialog(
      context: context,
      builder: (context) {
        return TipDialogBox(subscriptionList: subscriptionList, onSubmit: onSubmit);
      },
    );
  }

  onSubmit(ProductDetails productDetail){
    iApEngine.handlePurchase(productDetail, productId);
  }

  Widget bottomWidget(){
    return AppUtils.commonContainer(
      width: double.infinity,
      padding: const EdgeInsets.only(
          top: 10, bottom: 10, left: 10, right: 10),
      decoration: BoxDecoration(
        color: getBottomCountContainerColor(),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16),bottomRight: Radius.circular(16)),
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
    );
  }

  PreferredSizeWidget customAppBarWithRoundedCorners(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: Container(
        decoration: BoxDecoration(
          color: getScaffoldColor(),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: getElevationColor(), // Adjust opacity for shadow
              blurRadius: 10, // Blur radius for the shadow
              offset: const Offset(0, 4), // Position of the shadow
            ),
          ],
        ),
        child: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor:Colors.transparent,
          // Make the AppBar background transparent
          elevation: 0,
          // Remove AppBar's default elevation
          toolbarHeight: 70,
          centerTitle: true,
          leading: ClipRRect(
            borderRadius:
                const BorderRadius.only(bottomLeft: Radius.circular(16)),
            child: GestureDetector(
              onTap: () {
                _advancedDrawerController.showDrawer();
              },
              child: AppUtils.commonContainer(
                color: getScaffoldColor(),
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
                showTipDialogBox(context, subscriptionList,);
              },
              child: AppUtils.commonContainer(
                padding: const EdgeInsets.all(8),
                color: getScaffoldColor(),
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

  PreferredSizeWidget customAppBarWithRoundedCornersForBlackTheme(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(140),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: getScaffoldColor(),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),

            ),
            child:AppBar(
              surfaceTintColor: Colors.transparent,
              backgroundColor:Colors.transparent,
              // Make the AppBar background transparent
              elevation: 0,
              // Remove AppBar's default elevation
              toolbarHeight: 70,
              centerTitle: true,
              leading: ClipRRect(
                borderRadius:
                const BorderRadius.only(bottomLeft: Radius.circular(16)),
                child: GestureDetector(
                  onTap: () {
                    _advancedDrawerController.showDrawer();
                  },
                  child: AppUtils.commonContainer(
                    color: getScaffoldColor(),
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
                    color: getScaffoldColor(),
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
          
          bottomWidget()


        ],
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
