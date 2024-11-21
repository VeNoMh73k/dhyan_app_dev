import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/theme/theme_manager.dart';
import 'package:meditationapp/feature/home/provider/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class AudioPlayerPage extends StatefulWidget {
  final String imgUrl;
  final String filePath;
  final String audioTitle;

  const AudioPlayerPage({
    super.key,
    required this.imgUrl,
    required this.filePath,
    required this.audioTitle,
  });

  @override
  _AudioPlayerPageState createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  final audioPlayer = AudioPlayer();
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/video/background.mp4")
      ..initialize().then((_) {
        _controller.play();
        _controller.setLooping(true);
        setState(() {});
      });

    audioPlayer.durationStream.listen((duration) {
      setState(() {});
    });

    audioPlayer.positionStream.listen((position) {
      setState(() {});
    });
  }

  Future<void> playAudio() async {
    await audioPlayer.setFilePath(widget.filePath);
    _controller.play(); // Keep video playing
    await audioPlayer.play();
  }

  Future<void> pauseAudio() async {
    await audioPlayer.pause();
    _controller.pause(); // Pause video if needed
  }

  @override
  void dispose() {
    _controller.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        elevation: 0,
        forceMaterialTransparency: false,
        automaticallyImplyLeading: false,
        leading: Container(
          margin: const EdgeInsets.only(left: 12, bottom: 0, right: 0),
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.arrow_back,
            color: AppColors.whiteColor,
          ),
        ),
        actions: [
          Icon(
            Icons.info,
            color: AppColors.whiteColor,
            size: 26,
          ),
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: Stack(
        children: [
          // Background Video or Loading Indicator
          SizedBox.expand(
            child: _controller.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),

          // Bottom Overlay
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Left Column: Text and Slider
                Container(
                  width: MediaQuery.of(context).size.width / 1.3,
                  margin: EdgeInsets.only(bottom: 36),
                  // color: Colors.red,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 21),
                        child: AppUtils.commonTextWidget(
                          text: "Breath & Relax",
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          textColor: AppColors.whiteColor,
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Column(
                        children: [
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 5,
                              thumbColor: AppColors.primaryColor,
                              inactiveTrackColor:
                                  AppColors.whiteColor.withOpacity(0.5),
                              activeTrackColor: AppColors.primaryColor,
                              minThumbSeparation: 0,
                            ),
                            child: Slider(
                              value: 2.0,
                              min: 0.0,
                              max: 5.0,
                              onChanged: (value) {},
                              onChangeEnd: (value) {
                                // Handle slider value change end
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 21),
                                child: AppUtils.commonTextWidget(
                                  text: "12:45",
                                  textColor: AppColors.whiteColor,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 21),
                                child: AppUtils.commonTextWidget(
                                  text: "12:45",
                                  textColor: AppColors.whiteColor,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),

                // Right Column: Icon
                Padding(
                  padding: const EdgeInsets.only(bottom: 36, right: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          // Handle favorite button click
                        },
                        icon: Icon(
                          Icons.favorite,
                          color: AppColors.whiteColor,
                          size: 40,
                        ),
                      ),
                      const SizedBox(
                        height: 36,
                      ),
                      GestureDetector(
                        onTap: () {
                          // Handle favorite button click
                        },
                        child: AppUtils.commonContainer(
                          height: 55,
                          width: 55,
                          decoration: AppUtils.commonBoxDecoration(
                              shape: BoxShape.circle, color: getPrimaryColor()),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.blackColor,
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
