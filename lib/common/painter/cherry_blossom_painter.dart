import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CherryBlossomPainter extends CustomPainter {
  final Animation<double> animation;
  final List<CherryBlossom> blossoms;
  final ui.Image? cherryBlossomImage;

  CherryBlossomPainter({
    required this.animation,
    required this.blossoms,
    required this.cherryBlossomImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (cherryBlossomImage == null) return; // 이미지 로드 실패 시 패스

    for (var blossom in blossoms) {
      // Y 좌표 업데이트 (속도 반영)
      blossom.y += blossom.speed;

      // 화면 아래로 벗어나면 위로 다시 배치
      if (blossom.y > size.height) {
        blossom.y = 0;
      }

      // 바람 효과를 주기 위해 X축을 조금씩 이동
      double x =
          (blossom.x * size.width + blossom.wind * blossom.y / size.height) %
              size.width;

      // 벚꽃 이미지 크기 조정 (랜덤 크기 적용)
      final double scale = blossom.size / cherryBlossomImage!.width;
      final Rect srcRect = Rect.fromLTWH(
        0,
        0,
        cherryBlossomImage!.width.toDouble(),
        cherryBlossomImage!.height.toDouble(),
      );

      final Rect dstRect = Rect.fromLTWH(
        x,
        blossom.y,
        cherryBlossomImage!.width * scale,
        cherryBlossomImage!.height * scale,
      );

      // 벚꽃 이미지 그리기
      canvas.drawImageRect(cherryBlossomImage!, srcRect, dstRect, Paint());
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CherryBlossom {
  final double x; // X 위치 (고정)
  double y; // Y 위치 (애니메이션으로 변경)
  final double speed; // 낙하 속도
  final double size; // 크기
  final double wind; // 바람 효과

  CherryBlossom()
      : x = Random().nextDouble(),
        y = Random().nextDouble() * 800,
        speed = Random().nextDouble() * 1.5 + 1,
        size = Random().nextDouble() * 50 + 30,
        // 랜덤 크기 (30~80)
        wind = Random().nextDouble() * 20 - 10;
}

class FallingCherryBlossoms extends StatefulWidget {
  @override
  _FallingCherryBlossomsState createState() => _FallingCherryBlossomsState();
}

class _FallingCherryBlossomsState extends State<FallingCherryBlossoms>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<CherryBlossom> _blossoms;
  ui.Image? _cherryBlossomImage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    )..repeat();

    _blossoms = List.generate(25, (index) => CherryBlossom());

    // 벚꽃 이미지 로드
    _loadCherryBlossomImage();
  }

  Future<void> _loadCherryBlossomImage() async {
    final ByteData data =
        await rootBundle.load('assets/png/cherry_blossom.png');
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    setState(() {
      _cherryBlossomImage = frameInfo.image;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return CustomPaint(
            size: MediaQuery.of(context).size,
            painter: CherryBlossomPainter(
              animation: _animationController,
              blossoms: _blossoms,
              cherryBlossomImage: _cherryBlossomImage,
            ),
          );
        },
      ),
    );
  }
}
