import 'package:flutter/material.dart';
import 'package:runner/pages/profile.dart';
import 'pages/quiz.dart';
import 'pages/wordView.dart';
import 'pages/temp_startPage.dart';
import 'pages/ranking_page.dart';
import 'pages/home.dart';
import 'pages/loading.dart';

void main() {
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
        '/wordView': (context) => WordView(),
        '/profile': (context) => Profile(),
      },
    );
  }
}