import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../common/const/size.dart';
import '../main.dart'; // ✅ Item 클래스 임포트 (Item 정의 위치에 맞게 변경)

class ShowRoomListComponent extends StatefulWidget {
  final List<Item> eventMap; // ✅ 타입 명확히 지정

  const ShowRoomListComponent({Key? key, required this.eventMap}) : super(key: key);

  @override
  State<ShowRoomListComponent> createState() => _ShowRoomListComponentState();
}

class _ShowRoomListComponentState extends State<ShowRoomListComponent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: CocorySize.height(62)),
        Text(
          '''please check
your room number''',
          textAlign: TextAlign.center,
          style: TextStyle(
            height: 0.75,
            fontSize: CocorySize.width(80),
            fontStyle: FontStyle.italic,
            fontFamily: GoogleFonts.inter().fontFamily,
          ),
        ),
        SizedBox(height: CocorySize.height(58)),

        // ✅ 이벤트 리스트
        Expanded(
          child: ListView.separated(
            separatorBuilder: (context, index) => SizedBox(height: CocorySize.height(40)),
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.eventMap.length,
            itemBuilder: (context, index) {
              final item = widget.eventMap[index]; // ✅ 바로 Item 객체로 접근
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: CocorySize.width(39)),

                  // 🕒 시간
                  Text(
                    item.time,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: CocorySize.width(50),
                    ),
                  ),

                  SizedBox(width: CocorySize.width(60)),

                  // 👤 이름 / 인원 / 방번호
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이름
                      Text(
                        item.name,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: CocorySize.width(50),
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      // 인원 & 방번호
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            int.tryParse(item.count) == 1
                                ? '${item.count} person'
                                : '${item.count} people',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: CocorySize.width(50),
                            ),
                          ),
                          SizedBox(width: CocorySize.width(50)),
                          Text(
                            item.room,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: CocorySize.width(50),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: CocorySize.height(58)),
      ],
    );
  }
}
