import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // 로그인 성공 시 홈 화면으로 이동
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = "등록된 아이디가 아닙니다.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "비밀번호가 틀렸습니다.";
      } else {
        errorMessage = "로그인에 실패했습니다.";
      }

      // 오류 메시지를 다이얼로그로 표시
      _showErrorDialog(errorMessage);
    } catch (e) {
      print("Error during login: $e");
      _showErrorDialog("로그인 중 오류가 발생했습니다.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("오류"),
        content: Text(
          message,
          style: TextStyle(color: Colors.red), // 메시지 텍스트 빨간색
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red, // 확인 버튼 텍스트 빨간색
            ),
            child: Text("확인"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF66A2FD), // 배경색 설정
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '어너러너',
              style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.yellow),
            ),
            SizedBox(height: 0),
            Image.asset(
              'assets/image/runner_icon.png',  // 이미지 경로
              width: 230, // 이미지 너비 설정
              height: 180, // 이미지 높이 설정
            ),
            SizedBox(height: 10),
            // 첫 번째 Row: 아이디
            Row(
              children: [
                Container(
                  width: 100, // 레이블 크기 고정
                  child: Text(
                    '아이디',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 20), // 레이블과 TextField 사이 간격
                Expanded(
                  child: TextField(
                    controller: _emailController,
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
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 20), // 레이블과 TextField 사이 간격
                Expanded(
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true, // 비밀번호 입력 가리기
                    obscuringCharacter: '*',
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
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow, // 배경 색
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0), // 버튼 둥글게
                  side: BorderSide.none,  // 테두리 제거
                ),
              ),
              child: Text(
                '로그인',
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // 회원가입 화면으로 이동
                Navigator.pushNamed(context, '/signup');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow, // 배경 색
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0), // 버튼 둥글게
                  side: BorderSide.none, // 테두리 제거
                ),
              ),
              child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}