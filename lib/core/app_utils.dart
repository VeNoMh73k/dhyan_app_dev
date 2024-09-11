import 'dart:io';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
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
}
