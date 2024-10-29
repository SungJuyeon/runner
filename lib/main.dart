import 'package:flutter/material.dart';
import 'pages/temp_startPage.dart';
import 'pages/ranking_page.dart';
import 'pages/home.dart';

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
      },
    );
  }
}