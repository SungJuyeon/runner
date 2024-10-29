import 'package:flutter/material.dart';
import 'pages/temp_startPage.dart';
import 'pages/ranking_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-Page App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => temp_startPage(),
        '/ranking': (context) => ranking_page(),
      },
    );
  }
}