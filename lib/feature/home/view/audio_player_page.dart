    import 'package:flutter/material.dart';
    import 'package:just_audio/just_audio.dart';
    import 'package:meditationapp/core/app_colors.dart';
    import 'package:meditationapp/core/app_utils.dart';
    import 'package:meditationapp/core/theme/theme_manager.dart';
import 'package:meditationapp/feature/feedback/view/feedback_screen.dart';
    import 'package:syncfusion_flutter_core/theme.dart';
    import 'package:syncfusion_flutter_sliders/sliders.dart';
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
      final sliderValueNotifier = ValueNotifier<double>(0.0);
      Duration? audioDuration;

      @override
      void initState() {
        super.initState();
        _controller = VideoPlayerController.asset("assets/video/background.mp4")
          ..initialize().then((_) {
            _controller.play();
            _controller.setLooping(true);
            setState(() {});
          });

        audioPlayer.setFilePath(widget.filePath).then((_) {
          audioDuration = audioPlayer.duration;
        });

        // Listen to audio position
        audioPlayer.positionStream.listen((position) {
          sliderValueNotifier.value = position.inSeconds.toDouble();
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
      void seekAudio(double value) {
        audioPlayer.seek(Duration(seconds: value.toInt()));
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
            leading: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackScreen(),));

              },
              child: Container(
                margin: const EdgeInsets.only(left: 12, bottom: 0, right: 0),
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.whiteColor,
                ),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Text and Slider
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppUtils.commonTextWidget(
                            text: "Breath & Relax",
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                            textColor: AppColors.whiteColor,
                            maxLines: 2,
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Icon(
                              Icons.favorite,
                              color: AppColors.whiteColor,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ValueListenableBuilder<double>(
                          valueListenable: sliderValueNotifier,
                          builder: (_, sliderValue, __) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 30),
                              width: 320 ,
                              child: SfSliderTheme(
                                data: SfSliderThemeData(
                                  activeTrackHeight: 10,
                                  inactiveTrackHeight: 10,
                                  activeLabelStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400),
                                  inactiveLabelStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400),
                                ),
                                child: SfSlider(
                                  inactiveColor: Colors.white,
                                  activeColor: getPrimaryColor(),
                                  edgeLabelPlacement: EdgeLabelPlacement.inside,
                                  min: 0.0,
                                  max: audioDuration?.inSeconds.toDouble() ?? 1.0,
                                  value: sliderValue,
                                  showLabels: true,
                                  labelFormatterCallback:
                                      (dynamic value, String formattedText) {
                                    if (value == 0) return '0:00';
                                    if (value == audioDuration?.inSeconds) {
                                      return _formatDuration(audioDuration!);
                                    }
                                    return formattedText;
                                  },
                                  onChanged: (value) {
                                    seekAudio(value);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (audioPlayer.playing) {
                              await pauseAudio();
                            } else {
                              await playAudio();
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 16),
                            height: 55,
                            width: 55,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: getPrimaryColor(),
                            ),
                            child: Icon(
                              audioPlayer.playing
                                  ? Icons.pause
                                  : Icons.play_arrow_rounded,
                              color: Colors.black,
                              size: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      String _formatDuration(Duration duration) {
        String twoDigits(int n) => n.toString().padLeft(2, '0');
        final minutes = twoDigits(duration.inMinutes.remainder(60));
        final seconds = twoDigits(duration.inSeconds.remainder(60));
        return "$minutes:$seconds";
      }
    }
