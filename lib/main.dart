import 'package:flutter/material.dart';
import 'dart:async'; // Timer를 사용하기 위한 import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoadingScreen(),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _isFlipped = false; // 이미지를 반전할지 여부를 저장하는 변수
  late Timer _timer; // 타이머 변수

  @override
  void initState() {
    super.initState();
    // 1초마다 이미지 상태를 반전시키는 타이머 설정
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _isFlipped = !_isFlipped; // 상태 반전
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // 타이머 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/image/loading.png',
              width: screenWidth,
              height: screenHeight,
            ),
          ),
          // Other content here
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '어너러너',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.yellow,
                    fontFamily: 'dohyeon',
                  ),
                ),
                // LearnerBear image flipped horizontally based on _isFlipped
                Transform.scale(
                  scaleX: _isFlipped ? -1 : 1, // 상태에 따라 수평 반전
                  alignment: Alignment.center, // 반전 기준 점
                  child: Image.asset(
                    'assets/image/learnerBear.png',
                    width: 200,
                    height: 300,
                  ),
                ),
                // Other images can be added here
              ],
            ),
          ),
        ],
      ),
    );
  }
}
