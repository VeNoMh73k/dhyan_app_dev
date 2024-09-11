import 'package:flutter/material.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/feature/home/home_provider.dart';
import 'package:meditationapp/feature/home/models/home_model.dart';
import 'package:meditationapp/feature/home/audio_player_page.dart';
import 'package:meditationapp/feature/settings/settings_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<HomeModel> homeModelList = [];
  bool isLoadingHome = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        fillModel();
      },
    );
  }

  fillModel() async {
    setState(() {
      isLoadingHome = true;
    });
    homeModelList.add(HomeModel(
        audioTitle: 'Track 1',
        audioId: "123",
        audioUrl: "https://www2.cs.uic.edu/~i101/SoundFiles/StarWars60.wav",
        filePath: await AppUtils.doesExitFile(123),
        isDownloaded: await AppUtils.doesExitFile(123) == null ? false : true,
        isDownloading: false));
    homeModelList.add(HomeModel(
        audioTitle: 'Track 2',
        audioId: "456",
        audioUrl:
            "https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3",
        filePath: await AppUtils.doesExitFile(456),
        isDownloaded: await AppUtils.doesExitFile(456) == null ? false : true,
        isDownloading: false));
    homeModelList.add(HomeModel(
        audioTitle: 'Track 3',
        audioId: "789",
        audioUrl:
            "https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Sevish_-__nbsp_.mp3",
        filePath: await AppUtils.doesExitFile(789),
        isDownloaded: await AppUtils.doesExitFile(789) == null ? false : true,
        isDownloading: false));

    setState(() {
      isLoadingHome = false;
    });
  }

  callDownloadAudioApi(HomeProvider provider, url, audioId) async {
    setState(() {
      homeModelList
          .firstWhere((element) => element.audioId == audioId)
          .isDownloading = true;
    });
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/${audioId}cached_audio.mp3';
    provider.downloadAudio(context, url, filePath).then(
      (value) {
        setState(() {
          if (value) {
            homeModelList
                .firstWhere((element) => element.audioId == audioId)
                .isDownloaded = true;
            homeModelList
                .firstWhere((element) => element.audioId == audioId)
                .filePath = filePath;
          }
          homeModelList
              .firstWhere((element) => element.audioId == audioId)
              .isDownloading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);
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
      body: isLoadingHome
          ? AppUtils.loaderWidget()
          : ListView.builder(
              itemCount: homeModelList.length,
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey)),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(child: Text(homeModelList[index].audioTitle)),
                      homeModelList[index].isDownloading
                          ? AppUtils.loaderWidget(strokeAlign: 0,strokeWidth: 2)
                          : IconButton(
                              onPressed: () {
                                if (homeModelList[index].isDownloaded) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AudioPlayerPage(
                                          audioId: homeModelList[index].audioId,
                                          audioTitle:
                                              homeModelList[index].audioTitle,
                                          filePath:
                                              homeModelList[index].filePath ??
                                                  '',
                                        ),
                                      ));
                                } else {
                                  callDownloadAudioApi(
                                      provider,
                                      homeModelList[index].audioUrl,
                                      homeModelList[index].audioId);
                                }
                              },
                              icon: homeModelList[index].isDownloaded
                                  ? Icon(Icons.play_arrow)
                                  : Icon(Icons.download)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
