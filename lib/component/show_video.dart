import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ShowVideoComponent extends StatefulWidget {
  ShowVideoComponent(
      {Key? key, required this.controllers, required this.currentIndex})
      : super(key: key);

  final controllers;

  final currentIndex;

  @override
  State<ShowVideoComponent> createState() => _ShowVideoComponentState();
}

class _ShowVideoComponentState extends State<ShowVideoComponent> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    playController();
  }

  void playController() {
    Future.delayed(Duration(seconds: 2), () {
      widget.controllers.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return VideoPlayer(widget.controllers[widget.currentIndex]);
  }
}
