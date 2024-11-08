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
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = "등록된 이메일이 아닙니다.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "비밀번호가 틀렸습니다.";
      } else {
        errorMessage = "로그인에 실패했습니다. 이메일이나 비밀번호를 확인해주세요.";
      }
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
        title: Text("오류",
          style: TextStyle(
            color: Colors.red,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
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
      backgroundColor: Color(0xFF66A2FD),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '어너러너',
              style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                color: Colors.yellow,
                shadows: [
                  Shadow(
                    offset: Offset(0, 4),
                    blurRadius: 4.0,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Image.asset(
              'assets/image/runner_icon.png',
              width: 280,
              height: 230,
            ),
            SizedBox(height: 20),
            buildRowWithLabel('이메일', _emailController, obscureText: false),
            SizedBox(height: 20),
            buildRowWithLabel('비밀번호', _passwordController, obscureText: true),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  side: BorderSide.none,
                ),
              ),
              child: Text(
                '로그인',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  side: BorderSide.none,
                ),
              ),
              child: Text(
                '회원가입',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRowWithLabel(String label, TextEditingController controller, {required bool obscureText}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2, // 텍스트의 가로 비율
          child: Align(
            alignment: Alignment.center, // 텍스트를 가운데 정렬
            child: Text(
              label,
              style: TextStyle(
                color: Colors.yellow,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(0, 4),
                    blurRadius: 4.0,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          flex: 5, // 텍스트 필드의 가로 비율
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(30.0),
            shadowColor: Colors.black.withOpacity(0.5),
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              obscuringCharacter: '*',
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
