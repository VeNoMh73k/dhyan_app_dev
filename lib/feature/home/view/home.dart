import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/feature/home/provider/home_provider.dart';
import 'package:meditationapp/feature/home/models/home_model.dart';
import 'package:meditationapp/feature/home/view/audio_player_page.dart';
import 'package:meditationapp/feature/settings/view/settings_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // List<HomeModel> homeModelList = [];
  late HomeProvider homeProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        homeProvider = Provider.of<HomeProvider>(context, listen: false);
        callAudioListApi(homeProvider);
      },
    );
  }

  void callAudioListApi(HomeProvider provider) {
    provider.callGetAudioListApi(context);
  }

  callDownloadAudioApi(HomeProvider provider, audioUrl) async {
    setState(() {
      homeProvider.audioListModel
          ?.firstWhere((element) => element.audioUrl == audioUrl)
          .isDownloading = true;
    });
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/${audioUrl}cached_audio.mp3';
    provider.downloadAudio(context, audioUrl, filePath).then(
      (value) {
        setState(() {
          if (value) {
            homeProvider.audioListModel
                ?.firstWhere((element) => element.audioUrl == audioUrl)
                .isDownloaded = true;
            homeProvider.audioListModel
                ?.firstWhere((element) => element.audioUrl == audioUrl)
                .filePath = filePath;
          }
          homeProvider.audioListModel
              ?.firstWhere((element) => element.audioUrl == audioUrl)
              .isDownloading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    homeProvider = Provider.of<HomeProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Meditation App'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsPage(),
                    ));
              },
              icon: Icon(Icons.notifications_active))
        ],
      ),
      body: homeProvider.isLoading || homeProvider.audioListModel?.length == 0
          ? AppUtils.loaderWidget()
          : ListView.builder(
              itemCount: homeProvider.audioListModel?.length,
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              itemBuilder: (context, index) {
                return itemTile(index);
              },
            ),
    );
  }

  itemTile(index) {
    return Container(
      height: 140,
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blueGrey)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: 140,
              width: 90,
              child: AppUtils.cacheImage(
                  homeProvider.audioListModel?[index].imgUrl ?? ''),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          homeProvider.audioListModel?[index].title ?? '',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        homeProvider.audioListModel?[index].description ?? '',
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: InkWell(
                    onTap: () {
                      if (homeProvider.audioListModel?[index].isDownloaded ??
                          false) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AudioPlayerPage(
                                imgUrl: homeProvider
                                        .audioListModel?[index].imgUrl ??
                                    '',
                                audioTitle:
                                    homeProvider.audioListModel?[index].title ??
                                        '',
                                filePath: homeProvider
                                        .audioListModel?[index].filePath ??
                                    '',
                              ),
                            ));
                      } else {
                        callDownloadAudioApi(homeProvider,
                            homeProvider.audioListModel?[index].audioUrl ?? '');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 7, horizontal: 20),
                      decoration: BoxDecoration(
                          color: homeProvider
                                      .audioListModel?[index].isDownloaded ??
                                  false
                              ? Colors.deepPurple
                              : Colors.amberAccent,
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        homeProvider.audioListModel?[index].isDownloading ??
                                false
                            ? 'Downloading..'
                            : homeProvider
                                        .audioListModel?[index].isDownloaded ??
                                    false
                                ? 'Play'
                                : '+Add',
                        style: TextStyle(
                            fontSize: 16,
                            color: homeProvider
                                        .audioListModel?[index].isDownloaded ??
                                    false
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

// itemTileOld(index) {
//   return Container(
//     margin: EdgeInsets.symmetric(vertical: 5),
//     decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.grey)),
//     padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//     child: Row(
//       children: [
//         Expanded(
//             child: Text(homeProvider.audioListModel?[index].title ?? '')),
//         homeProvider.audioListModel?[index].isDownloading ?? false
//             ? AppUtils.loaderWidget(strokeAlign: 0, strokeWidth: 2)
//             : IconButton(
//                 onPressed: () {
//                   if (homeProvider.audioListModel?[index].isDownloaded ??
//                       false) {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => AudioPlayerPage(
//                             audioId: homeProvider
//                                     .audioListModel?[index].audioUrl ??
//                                 '',
//                             audioTitle:
//                                 homeProvider.audioListModel?[index].title ??
//                                     '',
//                             filePath: homeProvider
//                                     .audioListModel?[index].filePath ??
//                                 '',
//                           ),
//                         ));
//                   } else {
//                     callDownloadAudioApi(homeProvider,
//                         homeProvider.audioListModel?[index].audioUrl ?? '');
//                   }
//                 },
//                 icon:
//                     homeProvider.audioListModel?[index].isDownloaded ?? false
//                         ? Icon(Icons.play_arrow)
//                         : Icon(Icons.download)),
//       ],
//     ),
//   );
// }
}
