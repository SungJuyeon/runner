import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '어너러너',
      theme: ThemeData(
        primarySwatch: Colors.blue,
          fontFamily: 'dohyeon'
      ),
      home: LoginScreen(), // 첫 화면을 LoginScreen으로 설정
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
      },
    );
  }
}
