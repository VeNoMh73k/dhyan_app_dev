import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/network/api_constants.dart';
import 'package:meditationapp/core/network/network_repository.dart';
import 'package:meditationapp/feature/home/models/get_all_category_and_track.dart';
import 'package:video_player/video_player.dart';

class HomeProvider with ChangeNotifier {
  // List<Get>? audioListModel;
  bool isLoading = true;
  late VideoPlayerController videoPlayerController;
  GetAllCategoryAndTracks? getAllCategoryAndTracks;
  List<Categories> categories = [];
  List<Tracks> tracks = [];

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
  Future<GetAllCategoryAndTracks?> callGetAllCategoryAndTrack()async{
    isLoading =true;
    notifyListeners();
     categories = [];
     tracks = [];
    try{
      Response<dynamic>  response = await callPostMethodApi(getAudioListApi);
      if (response.statusCode == 200) {
        getAllCategoryAndTracks = GetAllCategoryAndTracks.fromJson(response.data);
        categories.addAll(getAllCategoryAndTracks?.categories ?? []);
        tracks.addAll(getAllCategoryAndTracks?.tracks ?? []);



      }
    }catch(e){
      print("catch at homeProvider");
    }
    isLoading =false;
    notifyListeners();
    return getAllCategoryAndTracks;
  }


  Future<List<Tracks>> findTracksFromCategoryId(int? categoryId) async{
    List<Tracks> filteredTracks = [];

    // Iterate through each track in the homeProvider
    for (var track in tracks) {
      // Check if the track's categoryIds contains the targetCategoryId
      if(track.categoryIds != null){
        if (track.categoryIds!.contains(categoryId)) {
          filteredTracks.add(track);
        }
      }

    }
    return filteredTracks;
  }
}
