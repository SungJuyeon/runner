import 'package:flutter/material.dart';

import 'navigationBar.dart';

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF66A2FD), // 배경색 설정
      bottomNavigationBar: buildBottomNavigationBar(
        context,
        onHomePressed,
        onRankingPressed,
        onProfilePressed,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0), // 좌우 여백
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 세로 가운데 정렬
            crossAxisAlignment: CrossAxisAlignment.center, // 가로 가운데 정렬
            children: [
              Text(
                '어너러너',
                style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                '회원가입',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Image.asset(
                'assets/images/runner_icon.png', // 이미지 경로
                width: 150, // 이미지 너비 설정
                height: 100, // 이미지 높이 설정
              ),
              SizedBox(height: 20),
              // 첫 번째 Row: 닉네임
              buildCustomTextField('닉네임'),
              SizedBox(height: 20),
              // 두 번째 Row: 아이디
              buildCustomTextField('아이디'),
              SizedBox(height: 20),
              // 세 번째 Row: 비밀번호
              buildCustomTextField('비밀번호', obscureText: true),
              SizedBox(height: 20),
              // 네 번째 Row: 비밀번호 확인
              buildCustomTextField('비밀번호 확인', obscureText: true),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // 회원가입 완료 후 로그인 화면으로 돌아가기
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow, // 배경 색
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), // 버튼 둥글게
                    side: BorderSide.none, // 테두리 제거
                  ),
                ),
                child: Text(
                  '회원가입',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 커스텀 텍스트 필드를 빌드하는 함수
  Widget buildCustomTextField(String label, {bool obscureText = false}) {
    return Row(
      children: [
        Container(
          width: 80, // 레이블 크기를 고정
          child: Text(
            label,
            style: TextStyle(
              color: Colors.yellow,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        SizedBox(width: 20), // 레이블과 TextField 사이 간격
        Expanded(
          child: Material(
            elevation: 8, // 그림자 크기
            borderRadius: BorderRadius.circular(30.0),
            shadowColor: Colors.black87, // 그림자 색상
            child: TextField(
              obscureText: obscureText, // 비밀번호 입력 가리기
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white, // 필드 배경 흰색
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16), // 내부 여백 설정
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0), // 둥근 모서리 설정
                  borderSide: BorderSide.none, // 테두리 제거
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
