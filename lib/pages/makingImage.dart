import 'package:flutter/material.dart';

// 색상 정의
final Color yellowColor = Color(0xFFEEEB96);
final Color blueColor = Color(0xFF66A2FD);

class MakingImage extends StatelessWidget {
  final int rank;
  final String name;
  final String tabName;

  const MakingImage({required this.rank, required this.name, required this.tabName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blueColor, // Set background color to blue
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 사용자 캐릭터 표시 (자신의 캐릭터 위젯으로 교체 가능)
            // 예: Image.asset('assets/images/character.png'),
            Text(
              '현재 $name님의 $tabName 랭킹', // 현재 사용자 랭킹 메시지 표시
              style: TextStyle(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20), // 텍스트와 버튼 사이의 간격
            ElevatedButton(
              onPressed: () {
                // 인스타 공유 로직
              },
              child: Text('인스타에 공유하기'), // 공유 버튼 텍스트
              style: ElevatedButton.styleFrom(
                backgroundColor: yellowColor, // 버튼의 배경색
                foregroundColor: Colors.black87, // 버튼의 텍스트 색
              ),
            ),
          ],
        ),
      ),
    );
  }
}
