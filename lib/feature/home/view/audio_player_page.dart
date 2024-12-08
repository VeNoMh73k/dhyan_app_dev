import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/storage/preference_helper.dart';
import 'package:meditationapp/core/theme/theme_manager.dart';
import 'package:meditationapp/feature/feedback/view/feedback_screen.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:video_player/video_player.dart';

class AudioPlayerPage extends StatefulWidget {
  final String imgUrl;
  final String filePath;
  final String audioTitle;
  final String trackId;
  final String audioDescription;

  final num minutes;

  const AudioPlayerPage(
      {super.key,
      required this.imgUrl,
      required this.trackId,
      required this.filePath,
      required this.audioTitle,
      required this.minutes,
      required this.audioDescription});

  @override
  _AudioPlayerPageState createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  bool showInfo = false;
  final audioPlayer = AudioPlayer();
  late VideoPlayerController _controller;
  final sliderValueNotifier = ValueNotifier<Duration>(Duration.zero);
  Duration? audioDuration;
  bool isPushed = false;
  VideoPlayerOptions videoPlayerOptions = VideoPlayerOptions(
    mixWithOthers: true,
  );

  @override
  void initState() {
    super.initState();
    showInfo = false;
    getInitialFav();

    _controller = VideoPlayerController.asset("assets/video/background.mp4",
        videoPlayerOptions: videoPlayerOptions)
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();

        setState(() {});
      });

    // Audio player setup
    audioPlayer.setFilePath(widget.filePath).then((_) {
      audioDuration = audioPlayer.duration;
      playAudio();
    });

    audioPlayer.durationStream.listen((duration) {
      if (!mounted) return;
      setState(() {
        audioDuration = duration ?? Duration.zero;
      });
    });
    audioPlayer.playerStateStream.listen(
      (event) {
        if (event.processingState == ProcessingState.completed) {
          if (!isPushed) {
            isPushed = true;
            saveMinutesInPref();
            saveSessionCompleted();
            pauseAudio();
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => FeedbackScreen(
                    trackId: widget.trackId,
                    titleName: widget.audioTitle,
                  ),
                ));
          }
        }
      },
    );

    // Listen to audio position changes
    audioPlayer.positionStream.listen((position) {
      sliderValueNotifier.value = position;
    });
  }

  bool savedFavVar = false;

  getInitialFav() async {
    final key = 'isFav_${widget.trackId}'; // Use unique ID for each item
    savedFavVar = PreferenceHelper.getBool(key);
    setState(() {});
  }

  toggleFav() async {
    final key = 'isFav_${widget.trackId}'; // Use unique ID for each item
    savedFavVar = PreferenceHelper.getBool(key);
    final newValue = savedFavVar ? false : true;
    await PreferenceHelper.setBool(key, newValue);
    savedFavVar = newValue;
    setState(() {});
  }

  saveMinutesInPref() {
    int savedTime = PreferenceHelper.getInt('totalPlayedTime') ?? 0;
    num? totalTime = savedTime + widget.minutes;
    PreferenceHelper.setInt("totalPlayedTime", int.parse(totalTime.toString()));
  }

  saveSessionCompleted(){
    int savedSessionCount = PreferenceHelper.getInt("sessionCount") ?? 0;
    int totalSession = savedSessionCount + 1;
    PreferenceHelper.setInt("sessionCount", totalSession);
  }

  void saveDaysOfMeditation() {
    final now = DateTime.now();
    final today = "${now.year}-${now.month}-${now.day}"; // Format: YYYY-MM-DD

    // Retrieve saved date and daysOfMeditation
    String savedDate = PreferenceHelper.getString("todayDate") ?? "";
    int daysOfMeditation = PreferenceHelper.getInt("daysOfMeditation") ?? 0;

    if (savedDate != today) {
      // If the saved date is before today, increment daysOfMeditation
      final savedDateParsed = DateTime.tryParse(savedDate) ?? DateTime(0);
      if (savedDateParsed.isBefore(DateTime(now.year, now.month, now.day))) {
        daysOfMeditation += 1;
      }

      // Save the current date and updated daysOfMeditation
      PreferenceHelper.setString("todayDate", today);
      PreferenceHelper.setInt("daysOfMeditation", daysOfMeditation);
    }
  }

  Future<void> playAudio() async {
    audioPlayer.setFilePath(widget.filePath);
    audioPlayer.play();
    saveDaysOfMeditation();
    setState(() {});
  }

  Future<void> pauseAudio() async {
    audioPlayer.pause();
    setState(() {});
    // _controller.pause(); // Pause video if needed
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
    return WillPopScope(
      onWillPop: () async{
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FeedbackScreen(
                trackId: widget.trackId,
                titleName: widget.audioTitle,
              ),
            ));
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          elevation: 0,
          forceMaterialTransparency: false,
          automaticallyImplyLeading: false,
          leading: AppUtils.backButton(
            color: AppColors.whiteColor,
            onTap: () {
              pauseAudio();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeedbackScreen(
                      titleName: widget.audioTitle,
                      trackId: widget.trackId,
                    ),
                  ));
            },
          ), /*GestureDetector(
            onTap: () {
              pauseAudio();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeedbackScreen(
                      titleName: widget.audioTitle,
                      trackId: widget.trackId,
                    ),
                  ));
            },
            child: Container(
              // margin: const EdgeInsets.only(left: 0, bottom: 0, right: 0),
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.whiteColor,
              ),
            ),
          ),*/
          actions: [
            GestureDetector(
              onTap: () {
                //show info onScreen

                setState(() {
                  showInfo = !showInfo;
                });
              },
              child: Icon(
                showInfo ? Icons.cancel : Icons.info,
                color: getAudioPlayerIntroductionAndCloseIconColor(),
                size: 26,
              ),
            ),
            const SizedBox(
              width: 12,
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
                  : AppUtils.loaderWidget(),
            ),

            // Bottom Overlay (Audio Player)
            if (showInfo == false)
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Left Column: Text and Slider
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppUtils.commonTextWidget(
                            text: widget.audioTitle ?? "Breath & Relax",
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                            textColor: AppColors.whiteColor,
                            maxLines: 2,
                          ),
                          GestureDetector(
                            onTap: () {
                              toggleFav();
                            },
                            child: Icon(
                              Icons.favorite,
                              color: savedFavVar == true
                                  ? getPrimaryColor()
                                  : AppColors.whiteColor,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Slider and Play Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ValueListenableBuilder<Duration>(
                          valueListenable: sliderValueNotifier,
                          builder: (_, sliderValue, __) {
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 30),
                                child: Column(
                                  children: [
                                    SfSliderTheme(
                                      data: const SfSliderThemeData(
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
                                        edgeLabelPlacement:
                                            EdgeLabelPlacement.inside,
                                        min: 0.0,
                                        max:
                                            audioDuration?.inSeconds.toDouble() ??
                                                1.0,
                                        value: sliderValueNotifier.value.inSeconds
                                            .toDouble()
                                            .clamp(
                                                0.0,
                                                audioDuration?.inSeconds
                                                        .toDouble() ??
                                                    0),
                                        showLabels: false,
                                        labelFormatterCallback: (dynamic value,
                                            String formattedText) {
                                          if (value == 0) return '00:00';
                                          if (value == audioDuration?.inSeconds) {
                                            return _formatDuration(
                                                audioDuration!);
                                          }
                                          return formattedText;
                                        },
                                        onChanged: (value) {
                                          seekAudio(value);
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          AppUtils.commonTextWidget(
                                            text: _formatDuration(
                                                sliderValueNotifier.value),
                                            textColor: AppColors.whiteColor,
                                          ),
                                          AppUtils.commonTextWidget(
                                            text: _formatDuration(
                                                audioDuration ?? Duration()),
                                            textColor: AppColors.whiteColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
            if (showInfo == true)
              SafeArea(
                child: AnimatedContainer(
                  margin: EdgeInsets.only(left: 16, right: 16, top: 30),
                  duration: Duration(milliseconds: 600),
                  curve: Curves.decelerate,
                  decoration: AppUtils.commonBoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppUtils.commonTextWidget(
                        text: "Brief Introduction",
                        textColor: AppColors.whiteColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: AppUtils.commonTextWidget(
                          text: widget.audioDescription ?? "",
                          textColor: AppColors.whiteColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

// Formatting function for displaying the duration
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
