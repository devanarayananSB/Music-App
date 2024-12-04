import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'package:lottie/lottie.dart';
import 'package:spotify_clone/views/home.dart';

// Import the LikedSongsManager for managing liked songs

class MusicPlayerPage extends StatefulWidget {
  final FileSystemEntity file;
  final AudioPlayer audioPlayer;
  final ValueNotifier<Duration> currentPositionNotifier;
  final List<FileSystemEntity> audioFiles;
  final VoidCallback onPlayNext;
  final VoidCallback onPlayPrevious;

  MusicPlayerPage({
    required this.file,
    required this.audioPlayer,
    required this.currentPositionNotifier,
    required this.audioFiles,
    required this.onPlayNext,
    required this.onPlayPrevious,
  });

  @override
  _MusicPlayerPageState createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> with SingleTickerProviderStateMixin {
  bool isPlaying = false;
  bool isFavorited = false;
  bool isMuted = false;
  double previousVolume = 1.0;
  Duration totalDuration = Duration.zero;
  late AnimationController _animationController;
  double _backgroundOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: Duration(seconds: 10), vsync: this)
      ..forward()
      ..repeat();

    // Initialize total duration and listen for position updates
    widget.audioPlayer.onDurationChanged.listen((duration) {
      print(duration);
      setState(() {
        totalDuration = duration;
      });
    });
    widget.audioPlayer.onPositionChanged.listen((position) {
      widget.currentPositionNotifier.value = position;
    });

    // Start audio playback and background fade effect
    playAudio();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _backgroundOpacity = 1.0;
      });
    });

    // Check if song is already favorited
    isFavorited = LikedSongsManager.likedSongs.contains(widget.file);
  }

  @override
  void dispose(){
    super.dispose();
  }

  Future<void> playAudio() async {
    await widget.audioPlayer.setSourceDeviceFile(widget.file.path);
    await widget.audioPlayer.resume();
    setState(() {
      isPlaying = true;
    });
  }

  Future<void> _playPause() async {
    if (isPlaying) {
      await widget.audioPlayer.pause();
      _animationController.stop();
    } else {
      await widget.audioPlayer.resume();
      _animationController.forward();
      _animationController.repeat();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void _toggleMute() {
    setState(() {
      if (isMuted) {
        widget.audioPlayer.setVolume(previousVolume);
      } else {
        previousVolume = widget.audioPlayer.volume;
        widget.audioPlayer.setVolume(0.0);
      }
      isMuted = !isMuted;
    });
  }

  void _toggleFavorite() {
    setState(() {
      isFavorited = !isFavorited;
      if (isFavorited) {
        LikedSongsManager.likedSongs.add(widget.file);
      } else {
        LikedSongsManager.likedSongs.remove(widget.file);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple.shade800,
        title: Text("MusicHub"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Image with Fade Effect
          AnimatedOpacity(
            opacity: _backgroundOpacity,
            duration: Duration(seconds: 2),
            child: Container(
              height: double.infinity,
              width: double.infinity,
              child: Image.asset(
                'assets/image1.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Lottie.asset(
                        'assets/Animation - 1730948028861.json',
                        controller: _animationController,
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: ValueListenableBuilder<Duration>(
                          valueListenable: widget.currentPositionNotifier,
                          builder: (context, position, child) {
                            return CircularProgressIndicator(
                              value: totalDuration.inMilliseconds > 0
                                  ? position.inMilliseconds / totalDuration.inMilliseconds
                                  : 0,
                              backgroundColor: Colors.grey[300],
                              color: Colors.purple,
                              strokeWidth: 5,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  iconSize: 64,
                  icon: Icon(
                    isPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: Colors.purple,
                  ),
                  onPressed: _playPause,
                ),
                SizedBox(height: 20),
                Text(
                  widget.file.path.split('/').last,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Listen Music",
                  style: TextStyle(color: Colors.purple, fontSize: 14),
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.skip_previous),
                      iconSize: 40,
                      onPressed: widget.onPlayPrevious,
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      icon: Icon(isFavorited ? Icons.favorite : Icons.favorite_border),
                      iconSize: 40,
                      color: Colors.red,
                      onPressed: _toggleFavorite,
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
                      iconSize: 40,
                      color: Colors.blue,
                      onPressed: _toggleMute,
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      icon: Icon(Icons.skip_next),
                      iconSize: 40,
                      onPressed: widget.onPlayNext,
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
}
