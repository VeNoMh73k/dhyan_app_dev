import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerPage extends StatefulWidget {
  final String filePath;
  final String audioId;
  final String audioTitle;

  const AudioPlayerPage(
      {super.key,
      required this.filePath,
      required this.audioId,
      required this.audioTitle});

  @override
  _AudioPlayerPageState createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  final audioPlayer = AudioPlayer();

  // bool isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Listen for duration changes
    audioPlayer.durationStream.listen((duration) {
      if (!mounted) return;
      setState(() {
        _duration = duration ?? Duration.zero;
      });
    });

    // Listen for position changes
    audioPlayer.positionStream.listen((position) {
      if (!mounted) return;
      setState(() {
        _position = position;
      });
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> playAudio() async {
    await audioPlayer.setFilePath(widget.filePath);
    await audioPlayer.play();
  }

  Future<void> pauseAudio() async {
    await audioPlayer.pause();
  }

  void togglePlayPause() {
    audioPlayer.playing ? pauseAudio() : playAudio();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Player'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Album Art
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(
                      'https://images.pexels.com/photos/220118/pexels-photo-220118.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              children: [
                SizedBox(height: 30),

                // Audio Title and Artist
                Text(
                  widget.audioTitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30),

                // Slider for seek bar
                Slider(
                  min: 0.0,
                  max: _duration.inSeconds.toDouble(),
                  value: _position.inSeconds
                      .toDouble()
                      .clamp(0.0, _duration.inSeconds.toDouble()),
                  onChanged: (value) {
                    // Seek to the selected position
                    // audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                  activeColor: Colors.deepPurple,
                  inactiveColor: Colors.deepPurple[100],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatDuration(_position)),
                    Text(formatDuration(_duration)),
                  ],
                ),
                SizedBox(height: 20),

                // Play / Pause / Next / Previous controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                        onTap: () async {
                          await audioPlayer.seek(Duration(
                              seconds: audioPlayer.position.inSeconds - 15));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            'assets/back.png',
                            height: 40,
                          ),
                        )),
                    IconButton(
                      icon: !audioPlayer.playing
                          ? Icon(Icons.play_circle_fill)
                          : Icon(Icons.pause_circle_filled),
                      iconSize: 64,
                      onPressed: () {
                        togglePlayPause();
                      },
                    ),
                    InkWell(
                        onTap: () async {
                          await audioPlayer.seek(Duration(
                              seconds: audioPlayer.position.inSeconds + 15));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            'assets/next.png',
                            height: 40,
                          ),
                        )),
                  ],
                ),
                SizedBox(height: 20),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Helper function to format the duration
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
