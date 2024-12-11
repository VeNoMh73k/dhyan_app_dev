import 'dart:async';
import 'package:dio/dio.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:meditationapp/core/constants.dart';
import 'package:meditationapp/main.dart';

Future<bool> callDownloadMethod(String filePath, String url) async {
  if (await AppUtils.checkInterAvailability()) {
    debugPrint('baseUrl--$filePath');
    final response = await Dio().download(url, filePath);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } else {
    noInterNetPopUp();
    return false;
  }
}

Future<dynamic> callPostMethodApi(String url) async {

  if (await AppUtils.checkInterAvailability()) {
    final response = await Dio().post(url, options: Options(headers: header));
    if (kDebugMode) {
      print(response);
    }

    return response;
  } else {
    noInterNetPopUp();
    return null;
  }
}

Future<dynamic> callPostMethodWithBodyApi(String url, Map<String, dynamic>? body) async {
  try {
    // Check for internet connectivity
    if (await AppUtils.checkInterAvailability()) {
      // Make the API call using Dio
      final response = await Dio().post(
        url,
        options: Options(headers: header),
        data: body,
      );

      // Debug print for the response
      if (kDebugMode) {
        print('Response: ${response}');
      }

      return response;
    } else {
      // Show no internet popup
      noInterNetPopUp();
      return null;
    }
  } catch (e) {
    // Handle and print errors for debugging
    if (kDebugMode) {
      print('Error during API call: $e');
    }

    // Optionally, handle specific Dio errors
    if (e is DioError) {
      return e.response?.data ?? {'error': 'An error occurred', 'details': e.message};
    }

    // Return a generic error if not a DioError
    return {'error': 'An unexpected error occurred', 'details': e.toString()};
  }
}





void noInterNetPopUp() {
  AppUtils.snackBarFnc(
    ctx: navigatorKey.currentState!.context,
    contentText: 'Internet Is not available!',
  );
}
