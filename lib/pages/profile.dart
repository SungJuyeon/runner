// pages/wordView.dart
import 'package:flutter/material.dart';

import 'navigationBar.dart';

class myPage extends StatefulWidget {
  const myPage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<myPage> {
  bool isPushNotificationEnabled = false; // 푸시 알림 설정 스위치 상태

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('myPage')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  elevation: 10, // 그림자 깊이 설정
                  shadowColor: const Color.fromARGB(128, 0, 0, 0), // 그림자 색상 설정
                  borderRadius: BorderRadius.circular(20), // 버튼 모서리 둥글게 설정
                  color: const Color(0xFF66A2FD), // 버튼 배경색
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF66A2FD), // 버튼의 배경색 설정
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/login'),

                    child: const Text('로그인 / 회원가입하러 가기',
                      style: TextStyle(
                        color: Color(0xFFF0EC7D),
                        fontSize: 20,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 2.0,
                            color: Color.fromARGB(128, 0, 0, 0), // 텍스트 그림자 설정
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(), // <hr> 역할

            // 푸시 알림 설정 스위치
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('푸시 알림 설정',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF66A2FD),
                    )
                ),
                Switch(
                  value: isPushNotificationEnabled,
                  activeColor: Color(0xFF66A2FD), // 스위치 버튼의 활성 상태 색상
                  onChanged: (value) {
                    setState(() {
                      isPushNotificationEnabled = value;

                    });
                  },
                ),
              ],
            ),
            //const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            // 문제 정답 개수
            const Text(
              '달린 기록',
              style: TextStyle(fontSize: 20,
                //color: Color(0xFF66A2FD),
              ),

            ),
            const SizedBox(height: 20),

            // 레벨별 진도율 표시
            _buildLevelProgress('LEVEL 1', 0, 40),
            const SizedBox(height: 30),
            _buildLevelProgress('LEVEL 2', 0, 40),
            const SizedBox(height: 30),
            _buildLevelProgress('LEVEL 3', 0, 40),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        context,
        onHomePressed,
        onRankingPressed,
        onProfilePressed,
      ),
    );
  }

  // 레벨별 진도율 표시 위젯
  Widget _buildLevelProgress(String level, int currentProgress, int maxProgress) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 35), // Adjust padding as needed
      decoration: BoxDecoration(
        color: Color(0xFFFFED90),
        borderRadius: BorderRadius.circular(3),

      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            level,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF634A18),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$currentProgress m / $maxProgress m',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black, // Also set to black for contrast
            ),
          ),
        ],
      ),
    );
  }
}