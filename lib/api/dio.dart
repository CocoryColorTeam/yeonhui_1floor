import 'dart:io';
import 'package:dio/dio.dart';

String getBaseUrl() {
  if (Platform.isAndroid) {
    return 'https://cocory.shop';
  } else if (Platform.isIOS) {
    return 'http://127.0.0.1:8080';
  } else if (Platform.isWindows) {
    return 'https://cocory.shop'; //
  } else {
    return 'https://cocory.shop';
  }
}
final dio = Dio(
  BaseOptions(
    baseUrl: getBaseUrl(), // ✅ 동적으로 환경에 따라 변경
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ),
);

// ✅ 요청 / 응답 / 에러 로그 찍기
void initDio() {
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        print('[DIO REQUEST] ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('[DIO RESPONSE] ${response.statusCode} ${response.data}');
        return handler.next(response);
      },
      onError: (e, handler) {
        print('[DIO ERROR] ${e.message}');
        return handler.next(e);
      },
    ),
  );
}
