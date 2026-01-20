import 'dart:async';

import 'package:flutter/material.dart';

import '../common/const/size.dart';

class ChangeNowComponent extends StatefulWidget {
  ChangeNowComponent({Key? key, required this.nowList}) : super(key: key);
  List nowList;

  @override
  State<ChangeNowComponent> createState() => _ChangeNowComponentState();
}

class _ChangeNowComponentState extends State<ChangeNowComponent> {
  int _currentIndex = 0;
  double _opacity = 1.0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // 타이머는 리스트가 비어 있지 않을 때만 실행

    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _changeName();
    });
  }

  void _changeName() {
    setState(() {
      _opacity = 0.0; // 페이드 아웃
    });

    Future.delayed(Duration(milliseconds: 500), () {
      // 리스트가 비어 있지 않으면 _currentIndex 업데이트
      if (widget.nowList.isNotEmpty) {
        setState(() {
          _currentIndex =
              (_currentIndex + 1) % widget.nowList.length; // 다음 이름으로 변경
          _opacity = 1.0; // 페이드 인
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 리스트가 비어 있으면 기본 컨테이너 반환
    if (widget.nowList.isEmpty) {
      return Container(
        width: CocorySize.width(1920),
        height: CocorySize.height(1080),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(CocorySize.width(65)),
        ),
      );
    } else {
      // 리스트가 비어 있지 않으면 정상적으로 데이터 표시
      return Container(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: CocorySize.width(80),
              vertical: CocorySize.height(90)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedOpacity(
                opacity: _opacity,
                duration: Duration(milliseconds: 500),
                child: Text(
                  '${widget.nowList[_currentIndex].time}',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: CocorySize.width(130),
                      fontWeight: FontWeight.w400),
                ),
              ),
              AnimatedOpacity(
                opacity: _opacity,
                duration: Duration(milliseconds: 500),
                child: Container(
                  width: CocorySize.width(1389.5),
                  child: Text(
                    '${widget.nowList[_currentIndex].name}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: CocorySize.width(180),
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: _opacity,
                duration: Duration(milliseconds: 500),
                child: Container(
                  width: CocorySize.width(805),
                  child: Text(
                    widget.nowList[_currentIndex].count == '1'
                        ? '${widget.nowList[_currentIndex].count} person'
                        : '${widget.nowList[_currentIndex].count} people',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: CocorySize.width(130),
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: _opacity,
                duration: Duration(milliseconds: 500),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '${widget.nowList[_currentIndex].room}',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: CocorySize.width(130),
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
        width: CocorySize.width(1920),
        height: CocorySize.height(1080),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(CocorySize.width(65))),
      );
    }
  }
}
