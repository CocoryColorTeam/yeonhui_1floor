import 'dart:async';

import 'package:cocory_1floor_kiosk/provider/room_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/const/size.dart';

class ChangeShowRoomComponent extends ConsumerStatefulWidget {
  ChangeShowRoomComponent({Key? key, required this.nowList}) : super(key: key);
  List nowList;

  @override
  ConsumerState<ChangeShowRoomComponent> createState() =>
      _ChangeShowRoomComponentState();
}

class _ChangeShowRoomComponentState
    extends ConsumerState<ChangeShowRoomComponent> {
  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _changeName();
    });
  }

  void _changeName() {

    ref.read(doubleProvider.notifier).update((state) => 0.0);


    Future.delayed(Duration(milliseconds: 500), () {
      if (widget.nowList.isNotEmpty) {
        setState(() {
          _currentIndex =
              (_currentIndex + 1) % widget.nowList.length; // 다음 이름으로 변경

        });
        ref.read(doubleProvider.notifier).update((state) => 1.0);
        ref
            .read(roomProvider.notifier)
            .update((state) => widget.nowList[_currentIndex].room);
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
    if (widget.nowList.isEmpty)
      return Container(
        width: CocorySize.width(871),
        height: CocorySize.height(2332),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(CocorySize.width(65))),
      );
    else
      return Container(
        width: CocorySize.width(871),
        height: CocorySize.height(2332),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: CocorySize.width(71),
              vertical: CocorySize.height(55)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedOpacity(
                opacity: ref.watch(doubleProvider),
                duration: Duration(milliseconds: 500),
                child: Text(
                  '${widget.nowList[_currentIndex].time}',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: CocorySize.width(130),
                      fontWeight: FontWeight.w400),
                ),
              ),
              SizedBox(height: CocorySize.height(55)),
              AnimatedOpacity(
                opacity: ref.watch(doubleProvider),
                duration: Duration(milliseconds: 500),
                child: Container(
                  width: CocorySize.width(705),
                  height: CocorySize.height(520),
                  child: Text(
                    '${widget.nowList[_currentIndex].name}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: CocorySize.width(130),
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              SizedBox(height: CocorySize.height(28)),
              AnimatedOpacity(
                opacity: ref.watch(doubleProvider),
                duration: Duration(milliseconds: 500),
                child: Container(
                  width: CocorySize.width(726),
                  height: CocorySize.height(207),
                  child: Text(
                    widget.nowList[_currentIndex].count == '1'
                        ? '${widget.nowList[_currentIndex].count} person'
                        : '${widget.nowList[_currentIndex].count} people',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: CocorySize.width(100),
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
              SizedBox(height: CocorySize.height(29)),
              AnimatedOpacity(
                opacity: ref.watch(doubleProvider),
                duration: Duration(milliseconds: 500),
                child: Row(
                  children: [
                    SizedBox(width: CocorySize.width(130),),
                    Container(
                      width: CocorySize.width(532),
                      height: CocorySize.height(659),
                      child: Image.asset('assets/png/arrow.png',fit: BoxFit.fill,),
                    ),
                  ],
                ),
              ),
              SizedBox(height: CocorySize.height(127)),
              AnimatedOpacity(
                opacity: ref.watch(doubleProvider),
                duration: Duration(milliseconds: 500),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '${_formatRoomString(widget.nowList[_currentIndex].room)}',
                    textAlign: TextAlign.end, // 오른쪽 정렬
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
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(CocorySize.width(65))),
      );
  }

  String _formatRoomString(String room) {
    // "-" 문자를 제거
    room = room.replaceAll(' -', '');

    // "No"를 기준으로 문자열을 분리
    int noIndex = room.indexOf(' No');
    if (noIndex != -1) {
      // "No"가 있는 경우 줄 바꿈을 포함한 문자열 반환
      return room.substring(0, noIndex) + '\n' + room.substring(noIndex + 1);
    }
    // "No"가 없는 경우 원래 문자열 반환
    return room;
  }
}
