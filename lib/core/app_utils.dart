import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/theme/theme_manager.dart';
import 'package:meditationapp/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUtils {
  static Future<String?> doesExitFile(audioId) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/${audioId}cached_audio.mp3';
    if (File(filePath).existsSync()) {
      return filePath;
    } else {
      return null;
    }
  }

  static Future<bool> checkInterAvailability() async {
    final isConnected = await InternetConnectionChecker().hasConnection;
    return isConnected;
  }

  static void snackBarFnc({required BuildContext ctx, String? contentText}) {
    if (contentText != null && contentText != '') {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        duration: const Duration(milliseconds: 1000),
        content: Text(
          contentText ?? '',
        ),
      ));
    }
  }

  static Widget loaderWidget(
      {Color? color, double? strokeAlign, double? strokeWidth}) {
    return Center(
        child: CircularProgressIndicator(
      color: AppColors.blackColor,
      strokeWidth: strokeWidth ?? 2,
      strokeAlign: strokeAlign ?? 0,
      strokeCap: StrokeCap.round,
    ));
  }

  static Future<void> launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  static cacheImage(imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(strokeWidth: 2, strokeAlign: -0.5)),
      fit: BoxFit.cover,
      errorWidget: (context, url, error) =>
          Image.asset("assets/ic_placeholder.jpeg", fit: BoxFit.cover),
    );
  }

  static Widget commonContainer({
    double? height,
    double? width,
    Alignment? alignment,
    BoxDecoration? decoration,
    EdgeInsets? margin,
    EdgeInsets? padding,
    Widget? child,
    Color? color,
  }) {
    return Container(
      height: height,
      width: width,
      alignment: alignment,
      decoration: decoration,
      margin: margin,
      padding: padding,
      color: color,
      child: child,
    );
  }

  static BoxDecoration commonBoxDecoration(
      {Color? color,
      BoxBorder? border,
      Gradient? gradient,
      BoxShape? shape,
      List<BoxShadow>? boxShadow,
      DecorationImage? image,
      BorderRadiusGeometry? borderRadius}) {
    return BoxDecoration(
      image: image,
      shape: shape ?? BoxShape.rectangle,
      color: color,
      boxShadow: boxShadow,
      border: border,
      gradient: gradient,
      borderRadius: borderRadius,
    );
  }

  static Widget commonTextWidget(
      {String? text,
      // TextStyle? style,
      double? fontSize,
      FontWeight? fontWeight,
      Color? textColor,
      TextAlign? textAlign,
      int? maxLines,
      double? letterSpacing,
      TextOverflow? overflow,
      TextDecoration? decoration}) {
    return Text(
      text ?? "", // Default text is an empty string if no text is provided
      style: TextStyle(
          fontSize: fontSize ?? 14,
          // Default font size
          fontWeight: fontWeight ?? FontWeight.normal,
          // Default font weight
          color: textColor ?? getTextColor(),
          letterSpacing: letterSpacing ?? 0.1,
          decoration: decoration ?? TextDecoration.none),
      textAlign: textAlign ?? TextAlign.start, // Default alignment is start
      maxLines: maxLines, // Optional parameter for max lines
      overflow: overflow ?? TextOverflow.ellipsis, // Default overflow behavior
    );
  }

  static String getDate({required String date, required String format}) {
    print("uuuuuuuuu $date");
    String parseDate = '';
    if (date != '') {
      try {
        parseDate = DateFormat(format).format(DateTime.parse(date));
      } catch (e) {
        return parseDate;
      }
    }
    return parseDate;
  }

  static commonElevatedButton({
    String? text,
    Function()? onPressed,
    double? leftMargin,
    double? rightMargin,
    double? topMargin,
    double? bottomMargin,
    double? leftPadding,
    double? rightPadding,
    double? topPadding,
    double? bottomPadding,
    double? buttonWidth,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return AppUtils.commonContainer(
      width: buttonWidth ?? 0,
      margin: EdgeInsets.only(
          left: leftMargin ?? 0,
          right: rightMargin ?? 0,
          bottom: bottomMargin ?? 0,
          top: topMargin ?? 0),

      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? getPrimaryColor(),
              elevation: 0,
              padding: EdgeInsets.only(
                  left: leftPadding ?? 0,
                  right: rightPadding ?? 0,
                  bottom: bottomPadding ?? 0,
                  top: topPadding ?? 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              )),
          onPressed: onPressed,
          child: AppUtils.commonTextWidget(
            text: text,
            textColor: textColor ?? AppColors.blackColor,
            fontWeight: FontWeight.w400,
            fontSize: 16,
          )),
    );
  }

  static Future<void> showFeedBackPopUp({
    required BuildContext context,
    String? title,
    String? subTitle,
    required List<Widget> widgetList,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: getPopUpColor(),
          insetPadding: const EdgeInsets.symmetric(horizontal: 0),
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
                        onTap: () => Navigator.of(context).pop(), // Close on tap
                        child: AppUtils.commonContainer(
                          margin: const EdgeInsets.only(right: 12, top: 12),
                          height: 30,
                          width: 30,
                          decoration: AppUtils.commonBoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.blackColor,
                          ),
                          child:  Icon(
                            Icons.close_rounded,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 32,right: 32),
                  child: Column(
                    children: [
                      AppUtils.commonTextWidget(
                        text: title,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                      const SizedBox(height: 14),
                      AppUtils.commonTextWidget(
                        text: subTitle,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      const SizedBox(height: 16),
                      ...widgetList,
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

  static successImage(
  {
    double? height,
    double? width,
    Color? color,
    double? iconsSize

  }
      ){
    return  AppUtils.commonContainer(
      height: height ?? 80,
      width: width ?? 80,
      decoration: AppUtils.commonBoxDecoration(
        color: color ?? getPrimaryColor(),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.done,
        color: AppColors.whiteColor,
        size: iconsSize ??60,
      ),
    );
  }
}





