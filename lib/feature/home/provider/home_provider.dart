import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/network/api_constants.dart';
import 'package:meditationapp/core/network/network_repository.dart';
import 'package:meditationapp/core/storage/preference_helper.dart';
import 'package:meditationapp/feature/home/models/get_all_category_and_track.dart';
import 'package:meditationapp/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class HomeProvider with ChangeNotifier {
  // List<Get>? audioListModel;
  bool isLoading = true;
  late VideoPlayerController videoPlayerController;
  GetAllCategoryAndTracks? getAllCategoryAndTracks;
  List<Categories> categories = [];
  List<Tracks> tracks = [];

  TextEditingController feedBackController = TextEditingController();

  ValueNotifier<double> progress = ValueNotifier(0.0);

  void freshProgress(Tracks track) {
    track.downloadProgress?.value = 0.0;
  }

  void updateProgress(double value, Tracks track) {
    track.downloadProgress?.value = value;
  }

  Future<bool> downloadAudio(
      BuildContext context, url, filePath, Tracks track) async {
    try {
      if (await AppUtils.checkInterAvailability()) {
        debugPrint('baseUrl--$filePath');
        final response = await Dio().download(
          url,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              double progress = (received / total) * 100;
              updateProgress(progress, track);
              // updateProgress(progress);
            }
          },
        );
        if (response.statusCode == 200) {
          freshProgress(track);
          // var responseInBool = await callDownloadMethod(filePath, url,);
          AppUtils.snackBarFnc(
              ctx: context, contentText: 'Downloaded Successfully');
          return true;
        } else {
          freshProgress(track);
          notifyListeners();
          return false;
        }
      } else {
        freshProgress(track);
        noInterNetPopUp();
        return false;
      }
    } catch (e) {
      freshProgress(track);
      debugPrint('catch at downloadAudio $e');
    }

    return false;
  }


  Future<GetAllCategoryAndTracks?> callGetAllCategoryAndTrack() async {
    isLoading = true;
    notifyListeners();
    categories = [];
    tracks = [];
    try {
      Response<dynamic> response = await callPostMethodApi(getAudioListApi);
      if (response.statusCode == 200) {

        getAllCategoryAndTracks = GetAllCategoryAndTracks.fromJson(response.data);
        categories.addAll(getAllCategoryAndTracks?.categories ?? []);
        tracks.addAll(getAllCategoryAndTracks?.tracks ?? []);

        if (isSubscribe == false) {
          for (var track in tracks) {
            if (track.isPaid == true) {
              if (track.trackUrl != "" || track.trackUrl != null) {
                final dir = await getApplicationDocumentsDirectory();
                final filePath = '${dir.path}/${track.id}_cached_audio.mp3';
                if (await File(filePath).exists()) {
                  File(filePath).delete();
                }
                // deleteAudioCache(track.trackUrl ?? "");
                if (PreferenceHelper.containsKey('downloadedFiles')) {
                  Map<String, String> downloads = Map<String, String>.from(
                    jsonDecode(PreferenceHelper.getString('downloadedFiles')!),
                  );
                  downloads.remove(track.filePath);
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print("catch at homeProvider$e");
    }
    isLoading = false;
    notifyListeners();
    return getAllCategoryAndTracks;
  }


  noDataFound(){
    getAllCategoryAndTracks = null;
    categories = [];
    tracks  =[];
    notifyListeners();
  }

  Future callFeedBackApi(int rating, int trackId)async{

    isLoading = true;
    notifyListeners();

    Map<String,dynamic> body = {
      "p_track_id" : trackId,
      "p_comment" : feedBackController.text,
      "p_rating" :rating,
    };

    try{
      print("body$body");
      Response<dynamic> response = await callPostMethodWithBodyApi(postFeedBackApi,body);
      bool?  isSuccess = checkStatusCode(response.statusCode);
      if(isSuccess == true){
        print("success");
        feedBackController.clear();
        AppUtils.snackBarFnc(ctx: navigatorKey.currentState!.context,contentText: "Thank you for your valuable feedback");
      }else{
        print("fail");
        feedBackController.clear();
        AppUtils.snackBarFnc(ctx: navigatorKey.currentState!.context,contentText: "Something went wrong, please try again!");
      }

    }catch(e){
      print("error$e");
    }



  }

}

bool checkStatusCode(int? statusCode) {
  if (statusCode == null) {
    return false; // statusCode is null, so return false
  }

  // Check if the statusCode is in the success range (200-299)
  return statusCode >= 200 && statusCode < 300;
}

