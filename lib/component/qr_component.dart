import 'package:flutter/material.dart';

import '../common/const/size.dart';

class QRComponent extends StatefulWidget {
  const QRComponent({Key? key}) : super(key: key);

  @override
  State<QRComponent> createState() => _QRComponentState();
}

class _QRComponentState extends State<QRComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: CocorySize.width(2024.3),
      height: CocorySize.height(897),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(CocorySize.width(70))),
      child: Stack(
        children: [
          Positioned(
              top: CocorySize.height(27),
              left: CocorySize.width(74.65),
              child: Text(
                '사전 설문 Pre-survey',
                style: TextStyle(
                    fontSize: CocorySize.width(55),
                    fontWeight: FontWeight.w700),
              )),
          Positioned(
              top: CocorySize.height(29.44),
              left: CocorySize.width(874.92),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '제출해주신 이메일로 디지털 이미지 카드가 전송됩니다.',
                    style: TextStyle(fontSize: CocorySize.width(35)),
                  ),
                  Text(
                      'A digital image card will be sent to the email you submitted.',
                      style: TextStyle(fontSize: CocorySize.width(35))),
                ],
              )),
          Positioned(
              left: CocorySize.width(69.65),
              top: CocorySize.height(192),
              child: Container(
                  width: CocorySize.width(578),
                  height: CocorySize.height(641),
                  child: Image.asset(
                    'assets/png/kor_qr.png',
                    fit: BoxFit.fill,
                  ))),
          Positioned(
              left: CocorySize.width(725.65),
              top: CocorySize.height(192),
              child: Container(
                  width: CocorySize.width(578),
                  height: CocorySize.height(641),
                  child: Image.asset(
                    'assets/png/eg_qr.png',
                    fit: BoxFit.fill,
                  ))),
          Positioned(
              left: CocorySize.width(1381.65),
              top: CocorySize.height(192),
              child: Container(
                  width: CocorySize.width(578),
                  height: CocorySize.height(641),
                  child: Image.asset(
                    'assets/png/ch_qr.png',
                    fit: BoxFit.fill,
                  ))),
        ],
      ),
    );
  }
}
