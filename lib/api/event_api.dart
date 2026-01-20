import 'dart:async';
import 'package:intl/intl.dart';
import 'dio.dart';
import '../main.dart';

Stream<List<Item>> eventStream() async* {
  // 오늘 날짜 포맷 (예: 2025-10-29)
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  const branchName = 'yeonhui';
  while (true) {
    try {
      print('[EVENT STREAM] 요청 날짜: $today');

      final response = await dio.get(
        '/events',
        queryParameters: {
          'date': today,
          'branchName': branchName,
        },
      );

      print('[EVENT STREAM] 응답 코드: ${response.statusCode}');
      print('[EVENT STREAM] 응답 데이터: ${response.data}');

      if (response.statusCode == 200 &&
          (response.data['success'] == true || response.data['status'] == 'success') &&
          response.data['data'] != null) {
        final List<dynamic> list = response.data['data'];
        final events = list.map((e) => Item.fromJson(e)).toList();
        print('[EVENT STREAM] ${events.length}개의 이벤트 수신');
        yield events;
      } else {
        print('[EVENT STREAM] 서버 응답 오류: ${response.data}');
        yield [];
      }

    } catch (e) {
      print('[EVENT STREAM] API 호출 오류: $e');
      yield [];
    }

    // 30분마다 재요청
    await Future.delayed(const Duration(minutes: 30));
  }
}
