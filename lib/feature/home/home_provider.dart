import 'package:flutter/material.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/network/network_repository.dart';

class HomeProvider with ChangeNotifier {
  Future<bool> downloadAudio(BuildContext context, url, filePath) async {
    try {
      var responseInBool = await apicAll(filePath, url);
      AppUtils.snackBarFnc(
          ctx: context, contentText: 'Downloaded Successfully');
      notifyListeners();
      return responseInBool;
    } catch (e) {
      debugPrint('catch at downloadAudio $e');
    }

    return false;
  }
}
