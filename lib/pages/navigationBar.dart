// navigationBar.dart
import 'package:flutter/material.dart';

Widget buildBottomNavigationBar(BuildContext context, Function onHomePressed, Function onRankingPressed, Function onProfilePressed) {
  return Stack(
    alignment: Alignment.center,
    clipBehavior: Clip.none,
    children: [
      BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: IconButton(
                    icon: const Icon(Icons.leaderboard),
                    onPressed: () => onRankingPressed(context), // Navigate to Ranking
                  ),
                ),
                const Text('랭킹'),
              ],
            ),
            const SizedBox(width: 48), // 홈 버튼 공간 확보
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () => onProfilePressed(context), // Navigate to Profile
                  ),
                ),
                const Text('마이'),
              ],
            ),
          ],
        ),
      ),
      Positioned(
        bottom: 15, // 홈 버튼 원 위치 조정
        child: InkWell(
          onTap: () => onHomePressed(context), // "홈" 버튼의 onTap 함수 호출
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF66A2FD),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.home,
                  color: Colors.white,
                  size: 40,
                ),
                SizedBox(height: 2), // 간격을 줄이기 위해 적은 높이의 SizedBox 추가
                Text(
                  '홈',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

// Function to navigate to the Ranking page
void onRankingPressed(BuildContext context) {
  Navigator.pushNamed(context, '/ranking');
}

// Function to navigate to the Home page
void onHomePressed(BuildContext context) {
  Navigator.pushNamed(context, '/home');
}

// Function to navigate to the Profile page
void onProfilePressed(BuildContext context) {
  Navigator.pushNamed(context, '/myPage');
}
