import 'package:flutter/material.dart';

class temp_startPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
              child: Text('홈화면'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text('로그인'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/quiz');
              },
              child: Text('문제풀기'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/ranking');
              },
              child: Text('랭킹'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/loading');
              },
              child: Text('로딩화면'),
            ),
          ],
        ),
      ),
    );
  }
}
