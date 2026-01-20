// common/painter/cloud_painter.dart (또는 같은 파일 상단에 붙여넣어도 상관없습니다)

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// 구름 한 개의 상태를 담는 모델
class Cloud {
  // 0.0 ~ 1.0 범위의 비율. 실제 그릴 때 size.width * xRatio 가 X 좌표(px)가 됩니다.
  double xRatio;
  // 화면 위쪽 기준 y(px) 위치 (랜덤으로 화면 높이의 일부 영역에만 배치)
  final double y;
  // px/frame 단위 속도 (양수는 오른쪽, 음수는 왼쪽)
  final double speed;
  // 이미지의 스케일 비율 (원본 이미지 너비 대비)
  final double scale;
  // 사용할 이미지 인덱스 (0 → cloud_1, 1 → cloud_2)
  final int imageIndex;

  Cloud({
    required this.xRatio,
    required this.y,
    required this.speed,
    required this.scale,
    required this.imageIndex,
  });

  /// 화면 높이를 알고 있을 때 랜덤한 구름 하나를 생성하는 팩토리
  factory Cloud.random(double screenHeight, int imageCount) {
    final rnd = Random();
    return Cloud(
      xRatio: rnd.nextDouble(),
      y: rnd.nextDouble() * screenHeight * 0.3, // 화면 높이 상위 30% 영역
      speed: (rnd.nextBool() ? 1 : -1) * (rnd.nextDouble() * 0.5 + 0.2),
      // 속도: ±(0.2 ~ 0.7) px/frame
      scale: rnd.nextDouble() * 0.5 + 0.8, // 스케일: 0.5 ~ 1.0
      imageIndex: rnd.nextInt(imageCount), // 사용할 이미지 인덱스 (0 또는 1)
    );
  }
}
class CloudPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Cloud> clouds;
  final List<ui.Image?> cloudImages;

  CloudPainter({
    required this.animation,
    required this.clouds,
    required this.cloudImages,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 이미지 중 하나라도 null이면 그리지 않음
    if (cloudImages.any((img) => img == null)) return;

    for (var cloud in clouds) {
      // 1) xRatio 업데이트: speed(px/frame)를 화면 너비 비율로 변환
      cloud.xRatio += cloud.speed / size.width;

      final ui.Image img = cloudImages[cloud.imageIndex]!; // non-null
      final double imgWidth = img.width * cloud.scale;

      // 2) 경계 검사 후 “다시 붙여주기” 로직
      if (cloud.speed > 0 && cloud.xRatio * size.width > size.width) {
        // 속도가 양수(오른쪽→왼쪽 아님, 왼쪽→오른쪽) 이고
        // 화면 오른쪽을 벗어나면, 왼쪽 바깥으로 붙이기
        cloud.xRatio = -imgWidth / size.width;
      }
      else if (cloud.speed < 0 && cloud.xRatio * size.width + imgWidth < 0) {
        // 속도가 음수(오른쪽→왼쪽) 이고
        // 화면 왼쪽을 벗어나면, 오른쪽 바깥(정확히 xRatio=1.0)으로 붙이기
        cloud.xRatio = 1.0;
      }

      // 3) 실제 그릴 좌표 계산
      final double dx = cloud.xRatio * size.width;
      final double dy = cloud.y;
      final srcRect = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
      final dstRect = Rect.fromLTWH(dx, dy, imgWidth, img.height * cloud.scale);

      // 4) 캔버스에 그리기
      canvas.drawImageRect(img, srcRect, dstRect, Paint());
    }
  }

  @override
  bool shouldRepaint(covariant CloudPainter oldDelegate) => true;
}
