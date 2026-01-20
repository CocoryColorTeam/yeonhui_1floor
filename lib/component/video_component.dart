import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

import '../common/const/size.dart';

class VideoComponent extends StatefulWidget {
  const VideoComponent({Key? key}) : super(key: key);

  @override
  State<VideoComponent> createState() => _VideoComponentState();
}

class _VideoComponentState extends State<VideoComponent> {
  List<VideoPlayerController> _controllers = [];
  int _currentIndex = 0; // 현재 비디오 인덱스

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayers();
  }

  @override
  void dispose() {
    _controllers.forEach((controller) {
      controller.dispose();
    });
    super.dispose();
  }

  void _initializeVideoPlayers() {
    List<String> videoAssets = [
      'assets/video/1.mp4',
      'assets/video/2.mp4',
      'assets/video/3.mp4',
    ];
    for (var videoAsset in videoAssets) {
      VideoPlayerController controller =
          VideoPlayerController.asset(videoAsset);
      controller.initialize().then((_) {
        setState(() {}); // 비디오 로드 완료 후 UI 갱신
        if (_controllers.isEmpty) {
          controller.play(); // 첫 번째 비디오 자동 재생
        }
      });
      controller.addListener(() {
        _checkVideoEnd(controller);
      });
      _controllers.add(controller);
    }
  }

  void _checkVideoEnd(VideoPlayerController controller) {
    if (controller.value.position == controller.value.duration) {
      _playNextVideo();
    }
  }

  void _playNextVideo() {
    int nextIndex = (_currentIndex + 1) % _controllers.length;
    setState(() {
      _currentIndex = nextIndex;
    });
    _controllers[_currentIndex].play();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
          width: CocorySize.width(1920),
          height: CocorySize.width(1080),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(CocorySize.width(65)),
          ),
          child: Stack(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(CocorySize.width(65)),
                  child: Container(
                      width: CocorySize.width(1920),
                      height: CocorySize.width(1080),
                      child: VideoPlayer(_controllers[_currentIndex]))),
              InkWell(
                child: Container(
                  width: CocorySize.width(1920),
                  height: CocorySize.width(1080),
                  color: Colors.transparent,
                ),
                onTap: () {
                  if (_controllers[_currentIndex].value.isPlaying == true) {
                  } else {
                    _controllers[_currentIndex].play();
                  }
                },
              )
            ],
          )),
    );
  }
}
