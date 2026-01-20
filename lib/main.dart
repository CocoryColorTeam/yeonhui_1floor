import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:cocory_1floor_kiosk/api/dio.dart';
import 'package:cocory_1floor_kiosk/api/event_api.dart';
import 'package:cocory_1floor_kiosk/common/const/size.dart';
import 'package:cocory_1floor_kiosk/component/change_now.dart' as cnow;
import 'package:cocory_1floor_kiosk/component/change_showroom.dart' as showroom;
import 'package:cocory_1floor_kiosk/component/qr_component.dart';
import 'package:cocory_1floor_kiosk/component/showroom_list.dart';
import 'package:cocory_1floor_kiosk/component/video_component.dart';
import 'package:cocory_1floor_kiosk/provider/room_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import 'common/painter/cloud_painter.dart';
import 'component/change_now.dart';
import 'component/change_showroom.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await InternetAddress.lookup('google.com');
    print('[✅ 네트워크 초기화 완료]');
  } catch (e) {
    print('[⚠️ 네트워크 초기화 실패] $e');
  }

  initDio();
  runApp(ProviderScope(
    child: MaterialApp(
        theme: ThemeData(
            fontFamily: GoogleFonts.notoSansKr().fontFamily,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent),
        home: MyApp()),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, devicetype) {
      return Scaffold(
        body: Container(
          width: 100.w,
          height: 100.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: CocorySize.width(1000),
                height: CocorySize.height(500),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(context,
                          MaterialPageRoute(builder: (context) => FirstScreen()), (route) => false);
                    },
                    child: Text(
                      '1층 엘리베이터',
                      style: TextStyle(fontSize: CocorySize.width(100)),
                    )),
              ),
              SizedBox(
                height: 20.h,
              ),
              SizedBox(
                width: CocorySize.width(1000),
                height: CocorySize.height(500),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => SecondScreen()),
                          (route) => false);
                    },
                    child: Text('1층 쇼룸', style: TextStyle(fontSize: CocorySize.width(100)))),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class FirstScreen extends StatefulWidget {
  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> with TickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // 기존에 쓰던 Draggable Sheet 애니메이션 관련
  double _sheetPosition = 0.3;
  late AnimationController _controller;
  late Animation<double> _animation;
  late String today;
  Timer? _timer;
  ValueNotifier<double> sheetPosition = ValueNotifier<double>(0.3);

  // ─────────────────────────────────────────────────────────────────────────
  // ➋ 눈 애니메이션 컨트롤러 (Snow) — 기존 코드 그대로
  late AnimationController _snowController;
  late List<Snowflake> _snowflakes;

  // ─────────────────────────────────────────────────────────────────────────
  // ➌ 구름 애니메이션 컨트롤러 & 상태
  late AnimationController _cloudController;
  late List<Cloud> _clouds;
  // 구름 이미지를 담을 리스트 (cloud_1.png, cloud_2.png)
  List<ui.Image?> _cloudImages = [null, null];

  @override
  void initState() {
    super.initState();

    // (1) DraggableSheet 애니메이션 초기화
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0.3, end: 0.65).animate(_controller)
      ..addListener(() {
        sheetPosition.value = _animation.value;
      });

    // (2) 눈 내리는 애니메이션 초기화 (기존 코드 그대로)
    _snowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _snowflakes = List.generate(100, (index) => Snowflake());

    // (3) 구름 애니메이션 컨트롤러 초기화
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    // 화면 높이를 구해서 구름을 생성 (MediaQuery 불가능할 경우 임시로 window에서 가져옴)
    final screenHeight = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height;
    _clouds = List.generate(10, (_) => Cloud.random(screenHeight, 2));

    // (4) 구름 이미지 로드
    _loadCloudImage(0, 'assets/png/cloud_1.png');
    _loadCloudImage(1, 'assets/png/cloud_2.png');
  }

  /// 구름 이미지를 Asset에서 로드해 [_cloudImages]에 저장
  Future<void> _loadCloudImage(int index, String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    setState(() {
      _cloudImages[index] = frame.image;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _snowController.dispose();
    _cloudController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String todayFormatted = DateFormat('M-d').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/png/kiosk_background_image.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _cloudController,
              builder: (context, child) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: CloudPainter(
                    animation: _cloudController,
                    clouds: _clouds,
                    cloudImages: _cloudImages,
                  ),
                );
              },
            ),
          ),
          Column(
            children: [
              SizedBox(height: CocorySize.height(86)),
              Text(
                '\nWelcome to COCORY',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    letterSpacing: CocorySize.width(15),
                    fontFamily: GoogleFonts.italianno().fontFamily,
                    color: Colors.black,
                    fontSize: CocorySize.width(160)),
              ),
              // 여기 아래에 StreamBuilder로
              // events를 받아오지만 현재 날짜에 해당하는 데이터를 받아와야해
              // 예를들어 5월 5일이면 저기 저장된 값이 5-5 이런식으로 5월 30일이면 5-30 이게 가능할까?
              Expanded(
                child: StreamBuilder(
                  stream: eventStream(), // ✅ Firebase 대신 Dio Stream
                  builder: (context, snapshot) {
                    if (snapshot.hasData && !snapshot.hasError) {
                      // ✅ Firebase에서는 snapshot.data!.snapshot.value 를 썼지만,
                      // 이제는 List<Item> 이 바로 들어옴
                      final List<Item> eventMap = snapshot.data!;
                      eventMap.sort((a, b) => a.time.compareTo(b.time));

                      List<Item> event3 = [];

                      // 현재 시간을 기준으로 필터링
                      var now = DateTime.now();
                      var formatter = DateFormat('H:mm');
                      var nextHalfHour = now.minute < 30
                          ? DateTime(now.year, now.month, now.day, now.hour, 30)
                          : DateTime(now.year, now.month, now.day, now.hour + 1, 0);
                      var delay = nextHalfHour.difference(now);

                      for (var event in eventMap) {
                        DateTime parsedTime = DateFormat('H:mm').parse(event.time, true);
                        DateTime eventTime = DateTime(
                            now.year, now.month, now.day, parsedTime.hour, parsedTime.minute);
                        if (eventTime.isAfter(now.subtract(const Duration(hours: 1))) &&
                            eventTime.isBefore(now.add(const Duration(hours: 1)))) {
                          event3.add(event);
                        }
                      }

                      _timer?.cancel();
                      _timer = Timer(delay, () {
                        event3.clear();
                        for (var event in eventMap) {
                          DateTime parsedTime = DateFormat('H:mm').parse(event.time, true);
                          DateTime eventTime = DateTime(
                              now.year, now.month, now.day, parsedTime.hour, parsedTime.minute);
                          if (eventTime.isAfter(now.subtract(const Duration(hours: 1))) &&
                              eventTime.isBefore(now.add(const Duration(hours: 1)))) {
                            event3.add(event);
                          }
                        }
                        Timer.periodic(const Duration(minutes: 30), (timer) {
                          event3.clear();
                          for (var event in eventMap) {
                            DateTime parsedTime = DateFormat('H:mm').parse(event.time, true);
                            DateTime eventTime = DateTime(
                                now.year, now.month, now.day, parsedTime.hour, parsedTime.minute);
                            if (eventTime.isAfter(now.subtract(const Duration(hours: 1))) &&
                                eventTime.isBefore(now.add(const Duration(hours: 1)))) {
                              event3.add(event);
                            }
                          }
                          setState(() {});
                        });
                        setState(() {});
                      });

                      return Stack(
                        children: [
                          Container(
                            width: 100.w,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(height: CocorySize.height(54)),
                                // 현재 시간 ±1시간 내 이벤트만 표시
                                // ChangeNowComponent(nowList: event3),
                                cnow.ChangeNowComponent(nowList: event3),
                                SizedBox(height: CocorySize.height(90)),
                                VideoComponent(),
                                SizedBox(height: CocorySize.height(104)),
                              ],
                            ),
                          ),
                          Center(
                            child: Container(
                              alignment: Alignment.center,
                              width: CocorySize.width(1920),
                              child: ValueListenableBuilder(
                                valueListenable: sheetPosition,
                                builder: (context, value, child) {
                                  return DraggableScrollableSheet(
                                    initialChildSize: value,
                                    minChildSize: 0.3,
                                    maxChildSize: 0.65,
                                    builder: (BuildContext context,
                                        ScrollController scrollController) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft:
                                            Radius.circular(CocorySize.width(65)),
                                            topRight:
                                            Radius.circular(CocorySize.width(65)),
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 10.0,
                                              spreadRadius: 5.0,
                                              offset: Offset(0.0, -5.0),
                                            ),
                                          ],
                                        ),
                                        child: Container(
                                          width: CocorySize.width(1920),
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.only(
                                              topLeft:
                                              Radius.circular(CocorySize.width(65)),
                                              topRight:
                                              Radius.circular(CocorySize.width(65)),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              GestureDetector(
                                                onHorizontalDragUpdate: (value) {
                                                  if (value.localPosition.dy < 0) {
                                                    _controller.forward();
                                                  } else {
                                                    _controller.reverse();
                                                  }
                                                },
                                                child: Column(
                                                  children: [
                                                    Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.only(
                                                            topLeft: Radius.circular(
                                                                CocorySize.width(65)),
                                                            topRight: Radius.circular(
                                                                CocorySize.width(65)),
                                                          ),
                                                        ),
                                                        height: CocorySize.height(97)),
                                                    Container(
                                                      width: CocorySize.width(766),
                                                      height: CocorySize.height(28),
                                                      decoration: const BoxDecoration(
                                                          color: Color(0xffD9D9D9)),
                                                    ),
                                                    Container(
                                                        color: Colors.white,
                                                        height: CocorySize.height(97)),
                                                  ],
                                                ),
                                              ),
                                              Center(
                                                child: Text(
                                                  'Please check your room number',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: CocorySize.width(90)),
                                                ),
                                              ),
                                              SizedBox(height: CocorySize.height(92)),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: CocorySize.width(120)),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'TIME',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize:
                                                          CocorySize.width(70)),
                                                    ),
                                                    Container(
                                                      width: CocorySize.width(680),
                                                      child: Text(
                                                        'NAME',
                                                        overflow: TextOverflow.ellipsis,
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize:
                                                            CocorySize.width(70),
                                                            fontWeight:
                                                            FontWeight.w700),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: CocorySize.width(150),
                                                      child: const Center(
                                                        child: Text(
                                                          'N',
                                                          style: TextStyle(
                                                            color: Colors.transparent,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: CocorySize.width(511),
                                                      child: Text(
                                                        'ROOM',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize:
                                                            CocorySize.width(70)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: CocorySize.height(30)),
                                              Expanded(
                                                child: ListView.separated(
                                                  separatorBuilder: (context, index) =>
                                                      SizedBox(
                                                          height:
                                                          CocorySize.height(43)),
                                                  scrollDirection: Axis.vertical,
                                                  physics:
                                                  const BouncingScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount: eventMap.length,
                                                  itemBuilder: (context, index) {
                                                    final e = eventMap[index];
                                                    return Padding(
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal:
                                                          CocorySize.width(120)),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            e.time,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                FontWeight.w400,
                                                                fontSize: CocorySize.width(
                                                                    70)),
                                                          ),
                                                          Container(
                                                            width: CocorySize.width(680),
                                                            child: Text(
                                                              e.name,
                                                              overflow:
                                                              TextOverflow.ellipsis,
                                                              textAlign: TextAlign.start,
                                                              style: TextStyle(
                                                                  color: Colors.black,
                                                                  fontSize:
                                                                  CocorySize.width(
                                                                      70),
                                                                  fontWeight:
                                                                  FontWeight.w700),
                                                            ),
                                                          ),
                                                          Container(
                                                            width: CocorySize.width(150),
                                                            child: Center(
                                                              child: Text(
                                                                '${e.count}p',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                    FontWeight.w400,
                                                                    fontSize:
                                                                    CocorySize.width(
                                                                        70)),
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            width: CocorySize.width(511),
                                                            child: Text(
                                                              e.room,
                                                              textAlign:
                                                              TextAlign.start,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                  FontWeight.w400,
                                                                  fontSize:
                                                                  CocorySize.width(
                                                                      70)),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ],
          ),
/*
이거 주석할거야, 나중에 쓸건데 지금은 안씀
          FallingCherryBlossoms(),
*/
        ],
      ),
    );
  }
}

class SnowPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Snowflake> snowflakes;

  SnowPainter({required this.animation, required this.snowflakes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.8);

    for (var snowflake in snowflakes) {
      // Y 좌표 업데이트
      snowflake.y += snowflake.speed;

      // 화면 아래로 벗어나면 위로 재배치
      if (snowflake.y > size.height) {
        snowflake.y = 0;
      }

      // X 좌표는 바람의 영향을 받아 좌우로 약간 흔들림
      double x =
          (snowflake.x * size.width + snowflake.wind * snowflake.y / size.height) % size.width;

      // 눈송이 그리기
      canvas.drawCircle(Offset(x, snowflake.y), snowflake.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Snowflake {
  final double x; // X 위치 (고정)
  double y; // Y 위치 (애니메이션으로 변경)
  final double speed; // 낙하 속도
  final double size; // 눈송이 크기
  final double wind; // 바람의 영향

  Snowflake()
      : x = Random().nextDouble(),
        y = Random().nextDouble() * 800,
        speed = Random().nextDouble() * 2 + 1,
        size = Random().nextDouble() * 3 + 1,
        wind = Random().nextDouble() * 20 - 10;
}

class SecondScreen extends ConsumerStatefulWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends ConsumerState<SecondScreen> {
  late String today;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String todayFormatted = DateFormat('M-d').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SizedBox(height: CocorySize.height(86)),
          Text(
            'Welcome to COCORY',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.white,
              fontSize: CocorySize.width(120),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: eventStream(), // ✅ Dio 기반 Stream 유지
              builder: (context, snapshot) {
                if (snapshot.hasData && !snapshot.hasError) {
                  final List<Item> eventMap = snapshot.data!;
                  eventMap.sort((a, b) => a.time.compareTo(b.time));

                  List<Item> event3 = [];
                  var now = DateTime.now();
                  var formatter = DateFormat('H:mm');
                  var nextHalfHour = now.minute < 30
                      ? DateTime(now.year, now.month, now.day, now.hour, 30)
                      : DateTime(now.year, now.month, now.day, now.hour + 1, 0);
                  var delay = nextHalfHour.difference(now);

                  for (var event in eventMap) {
                    DateTime parsedTime = DateFormat('H:mm').parse(event.time, true);
                    DateTime eventTime = DateTime(
                        now.year, now.month, now.day, parsedTime.hour, parsedTime.minute);
                    if (eventTime.isAfter(now.subtract(const Duration(hours: 1))) &&
                        eventTime.isBefore(now.add(const Duration(hours: 1)))) {
                      event3.add(event);
                    }
                  }

                  _timer?.cancel();
                  _timer = Timer(delay, () {
                    event3.clear();
                    for (var event in eventMap) {
                      DateTime parsedTime = DateFormat('H:mm').parse(event.time, true);
                      DateTime eventTime = DateTime(
                          now.year, now.month, now.day, parsedTime.hour, parsedTime.minute);
                      if (eventTime.isAfter(now.subtract(const Duration(hours: 1))) &&
                          eventTime.isBefore(now.add(const Duration(hours: 1)))) {
                        event3.add(event);
                      }
                    }
                    Timer.periodic(const Duration(minutes: 30), (timer) {
                      event3.clear();
                      for (var event in eventMap) {
                        DateTime parsedTime = DateFormat('H:mm').parse(event.time, true);
                        DateTime eventTime = DateTime(
                            now.year, now.month, now.day, parsedTime.hour, parsedTime.minute);
                        if (eventTime.isAfter(now.subtract(const Duration(hours: 1))) &&
                            eventTime.isBefore(now.add(const Duration(hours: 1)))) {
                          event3.add(event);
                        }
                      }
                      setState(() {});
                    });
                    setState(() {});
                  });

                  return Container(
                    width: 100.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: CocorySize.height(60)),
                        QRComponent(), // ✅ QR 상단 고정
                        SizedBox(height: CocorySize.height(75)),
                        Padding(
                          padding:
                          EdgeInsets.symmetric(horizontal: CocorySize.width(70)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ✅ 왼쪽 (현재 고객 정보)
                              Column(
                                children: [
                                  ChangeShowRoomComponent(nowList: event3),
                                ],
                              ),

                              SizedBox(width: CocorySize.width(77)),

                              // ✅ 오른쪽 (지도 + 리스트)
                              Column(
                                children: [
                                  AnimatedOpacity(
                                    opacity: ref.watch(doubleProvider),
                                    duration: const Duration(milliseconds: 500),
                                    child: ref.watch(roomProvider) != 'null'
                                        ? Container(
                                      width: CocorySize.width(1054),
                                      height:
                                      CocorySize.height(1038.55),
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: Image.asset(
                                              fit: BoxFit.fill,
                                              'assets/png/${ref.read(roomProvider).contains('3rd')
                                                  ? '3rd_floor'
                                                  : ref.read(roomProvider).contains('4th')
                                                  ? '4th_floor'
                                                  : '5th_floor'}.png',
                                            ),
                                          ),
                                          if (ref.read(roomProvider).contains('3rd'))
                                            Positioned(
                                              left: CocorySize.width(800),
                                              top: CocorySize.height(
                                                ref.read(roomProvider).contains('No.1')
                                                    ? 767
                                                    : ref.read(roomProvider).contains('No.2')
                                                    ? 473
                                                    : 187,
                                              ),
                                              child: SizedBox(
                                                width: CocorySize.width(137),
                                                height: CocorySize.height(196),
                                                child: Image.asset('assets/png/marker.png'),
                                              ),
                                            ),
                                          if (ref.read(roomProvider).contains('4th'))
                                            Positioned(
                                              left: CocorySize.width(
                                                ref.read(roomProvider).contains('No.5')
                                                    ? 273
                                                    : ref.read(roomProvider).contains('No.1')
                                                    ? 458
                                                    : 856,
                                              ),
                                              top: CocorySize.height(
                                                ref.read(roomProvider).contains('No.5')
                                                    ? 350
                                                    : ref.read(roomProvider).contains('No.1')
                                                    ? 770
                                                    : ref.read(roomProvider).contains('No.2')
                                                    ? 767
                                                    : ref.read(roomProvider).contains('No.3')
                                                    ? 473
                                                    : 187,
                                              ),
                                              child: SizedBox(
                                                width: CocorySize.width(137),
                                                height: CocorySize.height(196),
                                                child: Image.asset('assets/png/marker.png'),
                                              ),
                                            ),
                                        ],
                                      ),
                                    )
                                        : Container(
                                      width: CocorySize.width(1054),
                                      height: CocorySize.height(1038.55),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                            CocorySize.width(65)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: CocorySize.height(81.45)),
                                  Container(
                                    width: CocorySize.width(1054),
                                    height: CocorySize.height(1213),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          CocorySize.width(65)),
                                    ),
                                    child: ShowRoomListComponent(eventMap: eventMap),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: CocorySize.height(20)),
                      ],
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Item {
  String name;
  String time;
  String room;
  String count;

  Item(this.name, this.time, this.room, this.count);

  Item.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        time = json['time'],
        count = json['count'].toString(),
        room = json['room'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'time': time,
        'count': count.toString(),
        'room': room,
      };
}
