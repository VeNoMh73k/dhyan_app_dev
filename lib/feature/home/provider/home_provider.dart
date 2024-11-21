import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/network/api_constants.dart';
import 'package:meditationapp/core/network/network_repository.dart';
import 'package:meditationapp/feature/home/models/audio_list_model.dart';
import 'package:video_player/video_player.dart';

class HomeProvider with ChangeNotifier {
  List<AudioListModel>? audioListModel;
  bool isLoading = true;
  late VideoPlayerController videoPlayerController;

  Future<bool> downloadAudio(BuildContext context, url, filePath) async {
    try {
      var responseInBool = await callDownloadMethod(filePath, url);
      AppUtils.snackBarFnc(
          ctx: context, contentText: 'Downloaded Successfully');
      notifyListeners();
      return responseInBool;
    } catch (e) {
      debugPrint('catch at downloadAudio $e');
    }

    return false;
  }

  Future<List<AudioListModel>?> callGetAudioListApi(
      BuildContext context) async {
    // try {
    isLoading = true;
    notifyListeners();
    Response<dynamic> response = await callGetMethod(getAudioListApi);
    if (response.statusCode == 200) {
      audioListModel = (response.data as List)
          .map((item) => AudioListModel.fromJson(item))
          .toList();
    }
    // } catch (e) {
    //   debugPrint('catch at callGetAudioListApi $e');
    // }
    isLoading = false;
    notifyListeners();
    return audioListModel;
  }
}
