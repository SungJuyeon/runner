import 'package:flutter/material.dart';
import 'package:runner/pages/login.dart';
import 'package:runner/pages/myPage.dart';
import 'package:runner/pages/notification.dart';
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
  await PushNotificationService.init();
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
        '/ranking': (context) => RankingPage(),
        '/home': (context) => HomePage(),
        '/loading': (context) => ifLoading(),
        '/quiz': (context) => Quiz(),
        '/wordView': (context) => WordView(title: "단어장", level: 1),
        '/myPage': (context) => myPage(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/pushNotifications': (context) => PushNotificationSettings(), // New route
      },
    );
  }
}

class PushNotificationSettings extends StatefulWidget {
  @override
  _PushNotificationSettingsState createState() => _PushNotificationSettingsState();
}

class _PushNotificationSettingsState extends State<PushNotificationSettings> {
  bool isPushNotificationEnabled = false; // 푸시 알림 설정 스위치 상태

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('푸시 알림 설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '푸시 알림 설정',
              style: TextStyle(fontSize: 20, color: Color(0xFF66A2FD)),
            ),
            Switch(
              value: isPushNotificationEnabled,
              activeColor: Color(0xFF66A2FD),
              onChanged: (value) {
                setState(() {
                  isPushNotificationEnabled = value;
                });

                // 푸시 알림이 켜졌을 때 알림을 보냄
                if (value) {
                  PushNotificationService.showNotification();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
