import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/commnon_widget/common_webview_widget.dart';
import 'package:meditationapp/core/image_path.dart';
import 'package:meditationapp/core/theme/theme_manager.dart';
import 'package:meditationapp/feature/feedback/view/thankyou_for_tip_screen.dart';
import 'package:meditationapp/feature/home/provider/home_provider.dart';
import 'package:meditationapp/feature/home/view/music_list_screen.dart';
import 'package:meditationapp/feature/information/view/about_us_screen.dart';
import 'package:meditationapp/feature/reminder/view/reminder_screen.dart';
import 'package:meditationapp/feature/subscription/view/subscription_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _advancedDrawerController = AdvancedDrawerController();
  late HomeProvider homeProvider;

  List<String> imageList = [
    image1Path,
    image2Path,
    image3Path,
    image1Path,
    image2Path,
    image3Path
  ];

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
  }

  callHomeApi(HomeProvider homeProvider) {
    homeProvider.callGetAllCategoryAndTrack();
  }

  @override
  Widget build(BuildContext context) {
    homeProvider = Provider.of<HomeProvider>(context);
    return AdvancedDrawer(
      controller: _advancedDrawerController,
      rtlOpening: false,
      animationDuration: Duration(milliseconds: 300),
      backdropColor: AppColors.whiteThemeBackgroundColor,
      backdrop: AppUtils.commonContainer(
          child: Image.asset(
        "assets/drawer_background.png",
      )),
      drawer: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 60, left: 16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  _advancedDrawerController.hideDrawer();
                },
                child: Icon(
                  Icons.close,
                  color: getTextColor(),
                  size: 26,
                ),
              ),
              const SizedBox(
                height: 60,
              ),
              commonRow(
                "assets/subscription_icon.png",
                "Subscription",
                () {
                  //Navigate to Subscription Page
                  _advancedDrawerController.hideDrawer();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SubscriptionScreen(),
                      ));
                },
              ),
              const SizedBox(
                height: 30,
              ),
              commonRow(
                "assets/reminder.png",
                "Reminder",
                () {
                  //Navigate to Reminder,
                  _advancedDrawerController.hideDrawer();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReminderScreen(),
                      ));
                },
              ),
              const SizedBox(
                height: 30,
              ),
              commonRow(
                "assets/rating.png",
                "Rate Our App",
                () {
                  //Navigate to RatingPage,
                  _advancedDrawerController.hideDrawer();
                },
              ),
              const SizedBox(
                height: 30,
              ),
              commonRow(
                "assets/about_us.png",
                "About Us",
                () {
                  //navigate to about us page
                  _advancedDrawerController.hideDrawer();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutUsScreen(),
                      ));
                },
              ),
              const SizedBox(
                height: 30,
              ),
              commonRow(
                "assets/t&c.png",
                "Terms & Conditions",
                () {
                  //navigate to term And Condition Page
                  _advancedDrawerController.hideDrawer();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CommonWebViewWidget(
                                title: "Terms & Conditions",
                                url: "https://www.google.com/",
                              )));
                },
              ),
              const SizedBox(
                height: 30,
              ),
              commonRow(
                "assets/privacy_policy.png",
                "Privacy Policy",
                () {
                  //navigate to privacy policy
                  _advancedDrawerController.hideDrawer();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CommonWebViewWidget(
                                title: "Privacy Policy",
                                url: "https://www.google.com/",
                              )));
                },
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: AppUtils.commonTextWidget(
                    text: "Version 1.1.0",
                    textColor: AppColors.primaryColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 14),
              )
            ],
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: getScaffoldColor(),
        appBar: AppBar(
          surfaceTintColor: getScaffoldColor(),
          backgroundColor: getScaffoldColor(),
          centerTitle: true,
          leading: GestureDetector(
            onTap: () {
              _advancedDrawerController.showDrawer();
            },
            child: Icon(
              Icons.menu,
              color: getTextColor(),
            ),
          ),
          title: Image.asset(
            "assets/logo_light.png",
            height: 32,
            width: 32,
            color: getLogoColor(),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                showTipDialogBox();
              },
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                child: Image.asset("assets/tip_icon.png",
                    width: 26, height: 26, color: getTipIconColor()),
              ),
            ),
          ],
        ),
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
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MusicListScreen(
                                        imageUrl: homeProvider.getAllCategoryAndTracks?.categories?[index].imageUrl,
                                        trackId: homeProvider.getAllCategoryAndTracks?.categories?[index].trackIds,
                                        categoryName: homeProvider.getAllCategoryAndTracks?.categories?[index].title,
                                        categoryId: homeProvider
                                            .getAllCategoryAndTracks
                                            ?.categories?[index]
                                            .id,
                                      ),
                                    ));
                              },
                              child: Container(
                                height: 120,
                                width: double.infinity,
                                margin: EdgeInsets.only(
                                    bottom:
                                        index == imageList.length - 1 ? 0 : 16,
                                    left: 12,
                                    right: 12),
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                  color: Colors.grey,
                                ),
                                child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    child: AppUtils.networkImage(
                                        imageUrl: homeProvider.categories[index]
                                                .bannerImageUrl ??
                                            "",
                                        height: 120,
                                        width: double.infinity)),
                              ),
                            );
                          },
                        ),
            ),

            // Bottom container (fixed)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  top: 10, bottom: 10, left: 10, right: 10),
              decoration: BoxDecoration(
                color: getBottomCountContainerColor(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  bottomCustomRow(105.toString(), "Min of Meditation"),
                  bottomCustomRow(20.toString(), "Session Completed"),
                  bottomCustomRow(10.toString(), "Days of Meditation"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int selectedValue = 1;

  showTipDialogBox() {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
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
                          text: "Tip Us",
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                        const SizedBox(height: 14),
                        AppUtils.commonTextWidget(
                            text:
                                "Tip us to provide more free tracks. Select the amount you want to tip us.",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            maxLines: 2,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Column(
                          children: [
                            RadioListTile<int>(
                              tileColor: AppColors.greyColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: AppColors.greyColor)),
                              title: Text("\₹100"),
                              value: 1,
                              groupValue: selectedValue,
                              activeColor: getPrimaryColor(),
                              onChanged: (value) {
                                setState(() {
                                  selectedValue = value!;
                                });
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            RadioListTile<int>(
                              tileColor: AppColors.greyColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: AppColors.greyColor)),
                              title: Text("\₹500"),
                              value: 2,
                              groupValue: selectedValue,
                              activeColor: getPrimaryColor(),
                              onChanged: (value) {
                                setState(() {
                                  selectedValue = value!;
                                });
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            RadioListTile<int>(
                              tileColor: AppColors.greyColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: AppColors.greyColor)),
                              title: Text("\₹1000"),
                              value: 3,
                              groupValue: selectedValue,
                              activeColor: getPrimaryColor(),
                              onChanged: (value) {
                                print(value);
                                setState(() {
                                  selectedValue = value!;
                                });
                                print(selectedValue);
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            AppUtils.commonElevatedButton(
                              bottomMargin: 30,
                              leftPadding: 25,
                              rightPadding: 25,
                              buttonWidth: 170,
                              text: "Provide Tip",
                              onPressed: () {
                                // Close pop-up after submission
                                Navigator.of(context).pop();
                                //navigate to Thank you page
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ThankYouForTipScreen(),
                                    ));
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget bottomCustomRow(String? number, String? text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 5, left: 8, right: 8, bottom: 5),
          decoration: BoxDecoration(
              color: getBottomRowContainerColor(),
              borderRadius: BorderRadius.all(Radius.circular(4))),
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

  commonRow(String? icon, String title, Function()? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            icon ?? '',
          ),
          const SizedBox(
            width: 8,
          ),
          AppUtils.commonTextWidget(
              text: title ?? "",
              fontWeight: FontWeight.w400,
              fontSize: 16,
              textColor: AppColors.blackColor)
        ],
      ),
    );
  }
}
