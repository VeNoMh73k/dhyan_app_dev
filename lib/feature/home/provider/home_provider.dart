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

  ValueNotifier<double> progress = ValueNotifier(0.0);



  void freshProgress(Tracks track){
    track.downloadProgress?.value = 0.0;
  }

  void updateProgress(double value,Tracks track) {
    track.downloadProgress?.value = value;
  }

  Future<bool> downloadAudio(BuildContext context, url, filePath,Tracks track) async {
    try {
      if (await AppUtils.checkInterAvailability()) {
        debugPrint('baseUrl--$filePath');
        final response = await Dio().download(
          url,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              double progress = (received / total) * 100;
              updateProgress(progress,track);
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

  Future<bool> deleteAudioCache(String audioUrl) async {
    try {
      // Load existing cached data
      if (PreferenceHelper.containsKey('downloadedFiles')) {
        Map<String, String> downloads = Map<String, String>.from(
          jsonDecode(PreferenceHelper.getString('downloadedFiles')!),
        );

        // Check if the audioUrl exists in the downloaded cache
        if (downloads.containsKey(audioUrl)) {

          String filePath = downloads[audioUrl]!;

          print("FilePath$filePath");

          // Delete the file from storage
          final file = File(filePath);
          if (await file.exists()) {
            await file.delete();
            debugPrint('File deleted: $filePath');
          } else {
            debugPrint('File not found at: $filePath');
          }

          // Remove the entry from SharedPreferences
          downloads.remove(audioUrl);

          // Save updated map back to SharedPreferences
          await PreferenceHelper.setString(
            'downloadedFiles',
            jsonEncode(downloads),
          );

          return true;
        } else {
          debugPrint('Audio URL not found in cache.');
        }
      } else {
        debugPrint('No cached data exists.');
      }
    } catch (e) {
      debugPrint('Error while deleting audio cache: $e');
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

        getAllCategoryAndTracks =
            GetAllCategoryAndTracks.fromJson(response.data);
        categories.addAll(getAllCategoryAndTracks?.categories ?? []);
        tracks.addAll(getAllCategoryAndTracks?.tracks ?? []);

        if(isSubscribe == false){
          for(var track in tracks){
            if(track.isPaid == true){
              if(track.trackUrl != "" || track.trackUrl != null){
                deleteAudioCache(track.trackUrl ?? "");
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

}