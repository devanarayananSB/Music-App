import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'MusicPlayerPage.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<FileSystemEntity> _audioFiles = [];
  final ValueNotifier<Duration> _currentPositionNotifier = ValueNotifier(Duration.zero);
  final AudioPlayer _audioPlayer = AudioPlayer(); // AudioPlayer instance shared between both screens
  bool _isPlaying = false;
  int _currentIndex = -1;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    requestPermissions();

    _audioPlayer.onPositionChanged.listen((position) {
      _currentPositionNotifier.value = position;
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _totalDuration = duration;
      });
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      _playNext(); // Auto-play next song
    });
  }

  Future<void> requestPermissions() async {
    await Permission.storage.request();
    if (await Permission.storage.isGranted) {
      fetchAudioFiles();
    }
  }

  Future<void> fetchAudioFiles() async {
    List<FileSystemEntity> files = [];
    List<FileSystemEntity> music = Directory('/storage/emulated/0/Music').listSync(recursive: true);
    List<FileSystemEntity> download = Directory('/storage/emulated/0/Download').listSync(recursive: true);
    files.addAll([...music, ...download]);
    List<FileSystemEntity> audioFiles = files.where((file) {
      final path = file.path.toLowerCase();
      return path.endsWith('.mp3') || path.endsWith('.wav') || path.endsWith('.m4a') || path.endsWith('.aac');
    }).toList();

    setState(() {
      _audioFiles = audioFiles;
    });
  }

  Future<void> _playAudio(int index) async {
    if (index >= 0 && index < _audioFiles.length) {
      final file = _audioFiles[index];
      await _audioPlayer.play(DeviceFileSource(file.path));
      setState(() {
        _isPlaying = true;
        _currentIndex = index;
      });
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_currentIndex == -1 && _audioFiles.isNotEmpty) {
        await _playAudio(0);
      } else {
        await _audioPlayer.resume();
      }
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  Future<void> _playNext() async {
    if (_currentIndex + 1 < _audioFiles.length) {
      await _playAudio(_currentIndex + 1);
    }
  }

  Future<void> _playPrevious() async {
    if (_currentIndex - 1 >= 0) {
      await _playAudio(_currentIndex - 1);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("MusicHub", style: TextStyle(color: Colors.white, fontSize: 24)),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 7, 7, 7), const Color.fromARGB(255, 45, 6, 112)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _audioFiles.isNotEmpty
                  ? ListView.builder(
                      itemCount: _audioFiles.length,
                      itemBuilder: (context, index) {
                        final file = _audioFiles[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                          color: Colors.white.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.music_note, color: Colors.white),
                            title: Text(
                              file.path.split('/').last,
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              _playAudio(index);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MusicPlayerPage(
                                    file: file,
                                    audioPlayer: _audioPlayer,
                                    currentPositionNotifier: _currentPositionNotifier,
                                    audioFiles: [],
                                    onPlayNext: _playNext,
                                    onPlayPrevious: _playPrevious,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    )
                  : Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
            // Playback Progression and Controls
            if (_audioFiles.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ValueListenableBuilder<Duration>(
                  valueListenable: _currentPositionNotifier,
                  builder: (context, position, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _totalDuration.inMilliseconds > 0
                            ? position.inMilliseconds / _totalDuration.inMilliseconds
                            : 0,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.skip_previous, color: Colors.white),
                      iconSize: 40,
                      onPressed: _playPrevious,
                    ),
                    GestureDetector(
                      onTap: _togglePlayPause,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.purple,
                          size: 50,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_next, color: Colors.white),
                      iconSize: 40,
                      onPressed: _playNext,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
class LikedSongsManager {
  static List<FileSystemEntity> likedSongs = [];
}
