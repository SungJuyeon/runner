import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

// 색상 정의
final Color yellowColor = Color(0xFFEEEB96);
final Color blueColor = Color(0xFF66A2FD);

class MakingImage extends StatelessWidget {
  final int rank;
  final String name;
  final int imgNum;
  final String tabName;

  const MakingImage({required this.rank, required this.name, required this.imgNum, required this.tabName});

  @override
  Widget build(BuildContext context) {
    // 사용자 캐릭터 이미지 경로 설정
    String assetPath;
    if (imgNum == 1) {
      assetPath = 'assets/image/learnerBear.png';
    } else if (imgNum == 2) {
      assetPath = 'assets/image/learnerBrown.png';
    } else {
      assetPath = 'assets/image/learnerRabbit.png';
    }

    return Scaffold(
      backgroundColor: blueColor,
      appBar: AppBar(
        backgroundColor: blueColor, // AppBar 배경색
        elevation: 0, // 그림자 없애기
        automaticallyImplyLeading: false, // 화살표 아이콘 숨기기
        actions: [
          // 닫기 버튼
          Container(
            margin: EdgeInsets.all(0), // 여백 추가
            decoration: BoxDecoration(
              shape: BoxShape.circle, // 원형
              color: Colors.black, // 검은색 배경
            ),
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white), // 엑스 아이콘 흰색
              iconSize: 30, // 아이콘 크기
              onPressed: () {
                Navigator.pop(context); // 랭킹 페이지로 돌아가기
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 현재 사용자 랭킹 메시지 표시
            Text(
              '현재 $name님의 $tabName 랭킹',
              style: TextStyle(color: Colors.black87, fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20), // 텍스트와 버튼 사이의 간격

            // 랭크 표시 노란색 원
            Container(
              width: 60, // 원의 너비
              height: 60, // 원의 높이
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: yellowColor, // 원의 배경색
              ),
              alignment: Alignment.center,
              child: Text(
                '$rank', // 랭크 텍스트
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30, // 폰트 크기 조절
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20), // 원과 버튼 사이의 간격

            // 사용자 별 캐릭터 이미지 표시
            Image.asset(
              assetPath,
              width: 180, // 이미지 너비
              height: 260, // 이미지 높이
              fit: BoxFit.cover, // 이미지 크기 조정 방식
            ),
            SizedBox(height: 20), // 이미지와 버튼 사이의 간격

            // 공유 버튼
            ElevatedButton(
              onPressed: () {
                shareContent();// 인스타 공유 로직
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(250, 60), // 버튼 최소 크기 설정 (너비 200, 높이 50)
                backgroundColor: yellowColor, // 버튼의 배경색
                foregroundColor: Colors.black87, // 버튼의 텍스트 색
              ),
              child: Text(
                '인스타에 공유하기', // 공유 버튼 텍스트
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20, // 폰트 크기 조절
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void shareContent() {
    String message = '현재 $name님의 $tabName 랭킹은 $rank위입니다!';
    Share.share(message);
  }
}