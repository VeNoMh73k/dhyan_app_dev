// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
//
// Future<String> downloadAndCacheAudio(String url, audioId) async {
//   debugPrint('url : $url');
//   debugPrint('audioId : $audioId');
//   final dir = await getApplicationDocumentsDirectory();
//   final filePath = '${dir.path}/${audioId}cached_audio.mp3';
//   try {
//     Dio dio = Dio();
//     final response = await dio.download(url, filePath);
//     if (response.statusCode == 200) {
//       debugPrint("Audio cached at: $filePath");
//       return filePath;
//     } else {
//       return filePath;
//     }
//   } catch (e) {
//     debugPrint("Error downloading audio: $e");
//     return filePath;
//   }
// }
