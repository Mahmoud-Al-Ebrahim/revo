import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/common/loader.dart';

class MYVideoPlayer extends StatefulWidget {
  const MYVideoPlayer({Key? key, this.videoUrl, this.videoFile})
      : super(key: key);
  final String? videoUrl;
  final File? videoFile;

  @override
  State<MYVideoPlayer> createState() => _MYVideoPlayerState();
}

class _MYVideoPlayerState extends State<MYVideoPlayer> {
  late VideoPlayerController _controller;
  Duration? videoDuration;

  late Future<void> initializeVideo;

  @override
  void initState() {
    if (widget.videoFile != null) {
      _controller = VideoPlayerController.file(widget.videoFile!);
      initializeController();
    } else {
      _controller = VideoPlayerController.contentUri(
        Uri.parse(widget.videoUrl!),
      );
      initializeController();
    }
    _controller.setLooping(false);
    super.initState();
  }

  void initializeController() {

    initializeVideo = _controller.initialize();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String getPosition() {
    final Duration duration;
    if (_controller.value.isPlaying) {
      duration = Duration(
          milliseconds: _controller.value.position.inMilliseconds.round());
    } else {
      duration = Duration(
          milliseconds: _controller.value.duration.inMilliseconds.round());
    }

    return [duration.inHours, duration.inMinutes, duration.inSeconds]
        .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
        .join(':')
        .padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.value.position == _controller.value.duration) {
      _controller.seekTo(Duration.zero);
    }
    // If the VideoPlayerController has finished initialization, use
    // the data it provides to limit the aspect ratio of the video.
    return FutureBuilder(
        future: initializeVideo,
        builder: (context, snapShot) {
          if (snapShot.connectionState == ConnectionState.done) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    // Use the VideoPlayer widget to display the video.
                    child: VideoPlayer(_controller),
                  ),
                  _controller.value.isPlaying
                      ? Container()
                      : const Icon(Icons.play_arrow,
                          size: 50, color: Colors.white),
                  buildSpeed(),
                  Positioned(
                    left: 8,
                    bottom: 28,
                    child: Text(
                      getPosition(),
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      height: 16,
                      child: VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                            bufferedColor: Colors.deepOrange.withOpacity(0.2),
                            playedColor: Colors.deepOrange,
                            backgroundColor: Colors.white.withOpacity(0.3)),
                      ),
                    ),
                  )
                ],
              ),
            );
          }
          return Center(child: Loader());
        });
  }

  Widget buildSpeed() {
    const allSpeeds = <double>[0.25, 0.5, 1, 1.5, 2, 3, 5, 10];
    return Positioned(
      top: 0,
      right: 0,
      child: PopupMenuButton<double>(
        initialValue: _controller.value.playbackSpeed,
        tooltip: 'Playback speed',
        onSelected: _controller.setPlaybackSpeed,
        itemBuilder: (context) => allSpeeds
            .map<PopupMenuEntry<double>>((speed) => PopupMenuItem(
                  value: speed,
                  child: Text(
                    '${speed}x',
                    style: TextStyle(color: Colors.deepOrange),
                  ),
                ))
            .toList(),
        child: Container(
          color: Colors.white38,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text(
            '${_controller.value.playbackSpeed}x',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
