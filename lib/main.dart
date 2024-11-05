import 'package:flutter/material.dart';
import 'package:runner/pages/login.dart';
import 'package:runner/pages/myPage.dart';
import 'package:runner/pages/signup.dart';
import 'pages/quiz.dart';
import 'pages/wordView.dart';
import 'pages/temp_startPage.dart';
import 'pages/ranking_page.dart';
import 'pages/home.dart';
import 'pages/loading.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  //firebase 초기화(로그인, 회원가입 기능)
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-Page App',
      theme: ThemeData(
        fontFamily: 'dohyeon', // 전체 폰트 지정
        primarySwatch: Colors.blue,
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => temp_startPage(),
        '/ranking': (context) => ranking_page(),
        '/home': (context) => HomePage(),
        '/loading': (context) => ifLoading(),
        '/quiz': (context) => Quiz(),            // Add Quiz route
        '/wordView': (context) => WordView(title: "단어장",level: 1),
        '/myPage': (context) => myPage(),
        '/login' : (context) => LoginScreen(),
        '/signup' : (context) => SignUpScreen(),
      },
    );
  }
}

