// import 'dart:io';
//
// import 'package:flutter/cupertino.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
//
// class AdMobService{
//
//   static String? get bannerAdId{
//     if(Platform.isAndroid){
//       return 'ca-app-pub-3940256099942544~3347511713';
//     }else if(Platform.isIOS){
//       return 'IosAdId';
//     }
//     return null;
//   }
//
//
//   static final BannerAdListener bannerAdListener = BannerAdListener(
//     onAdLoaded: (ad) => print("AdIsLoaded"),
//     onAdFailedToLoad: (ad, error) {
//       ad.dispose();
//       print("AdError$error");
//     },
//     onAdOpened: (ad) {
//       print("ad_is_Open");
//     },
//     onAdClosed: (ad) {
//       print("ad_is_Close");
//     },
//   );
//
// }