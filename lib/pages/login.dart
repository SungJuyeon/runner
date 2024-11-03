import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF67A4FB), // 배경색 설정
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // '홈' 탭 선택
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: '랭킹',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '마이',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '어너러너',
              style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.yellow),
            ),
            SizedBox(height: 20),
            Image.asset(
              'assets/images/runner_icon.png',  // 이미지 경로
              width: 150, // 이미지 너비 설정
              height: 100, // 이미지 높이 설정
            ),
            SizedBox(height: 20),
            // 첫 번째 Row: 아이디
            Row(
              children: [
                Container(
                  width: 100, // 레이블 크기 고정
                  child: Text(
                    ' 아이디',
                    style: TextStyle(
                      color: Color(0xFFF0EC7D),
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ),
                SizedBox(width: 20), // 레이블과 TextField 사이 간격
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white, // 필드 배경 흰색
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none, // 테두리 제거
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            // 두 번째 Row: 비밀번호
            Row(
              children: [
                Container(
                  width: 100, // 레이블 크기 고정
                  child: Text(
                    '비밀번호',
                    style: TextStyle(
                      color: Color(0xFFF0EC7D),
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ),
                SizedBox(width: 20), // 레이블과 TextField 사이 간격
                Expanded(
                  child: TextField(
                    obscureText: true, // 비밀번호 입력 가리기
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white, // 필드 배경 흰색
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none, // 테두리 제거
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 로그인 로직 처리
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF0EC7D), // 배경 색
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0), // 버튼 둥글게
                  side: BorderSide.none,  // 테두리 제거
                ),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: Text(
                '    로그인    ',
                style: TextStyle(color: Color(0xFF306DFB), fontSize: 22),
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // 회원가입 화면으로 이동
                Navigator.pushNamed(context, '/signup');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF0EC7D), // 배경 색
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0), // 버튼 둥글게
                  side: BorderSide.none, // 테두리 제거
                ),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: Text('   회원가입   ',
                style: TextStyle(color: Colors.black, fontSize: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
