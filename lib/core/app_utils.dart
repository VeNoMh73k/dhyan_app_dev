import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
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

  static void snackBarFnc(
      {required BuildContext ctx, String? contentText}) {
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
          color: Colors.deepPurple,
          strokeWidth: strokeWidth ?? 4,
          strokeAlign: strokeAlign ?? 0,
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

  static cacheImage(imageUrl){
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) =>
      const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, strokeAlign: -0.5)),
      fit: BoxFit.cover,
      errorWidget: (context, url, error) => Image.asset(
          "assets/ic_placeholder.jpeg",
          fit: BoxFit.cover),
    );
  }

  static Widget commonTextWidget({
    String? text,
    // TextStyle? style,
    double? fontSize,
    FontWeight? fontWeight,
    Color? textColor,
    TextAlign? textAlign,
    int? maxLines,
    double? letterSpacing,
    TextOverflow? overflow,
  }) {
    return Text(
      text ?? "",  // Default text is an empty string if no text is provided
      style:  TextStyle(
        fontSize: fontSize ?? 14, // Default font size
        fontWeight: fontWeight ?? FontWeight.normal, // Default font weight
        color: textColor ?? getTextColor(),
        letterSpacing: letterSpacing ?? 0.1// Default text color
      ),
      textAlign: textAlign ?? TextAlign.start, // Default alignment is start
      maxLines: maxLines, // Optional parameter for max lines
      overflow: overflow ?? TextOverflow.ellipsis, // Default overflow behavior

    );
  }
}
