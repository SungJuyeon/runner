import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:runner/pages/quiz.dart';
import 'package:runner/pages/wordView.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'navigationBar.dart';

class HomePage  extends StatefulWidget {
  const HomePage ({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  final int totalLevels = 3; //level 수
  late List<bool> isLocked; //level 잠금
  int userLevel = 1; // 기본값 1, 이후 Firestore에서 가져옴

  @override
  void initState() {  //초기 level 상태
    super.initState();
    // 모든 레벨 잠금 상태로 초기화
    isLocked = List.generate(totalLevels, (index) => index > 0);

    _permissionWithNotification();
    _initialization();
    // Firestore에서 사용자 레벨 데이터를 로드
    _loadUserLevelData();
  }

  Future<void> _loadUserLevelData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return;

      // Firestore에서 levelX_true 값을 가져와서 확인
      final level1True = userDoc['level1_true'] ?? 0;
      final level2True = userDoc['level2_true'] ?? 0;

      // 현재 레벨 상태 설정: 각 레벨의 true 개수가 30 이상이면 잠금 해제
      setState(() {
        if (level1True >= 30) {
          isLocked[1] = false; // Level 2 잠금 해제
        }
        if (level2True >= 30) {
          isLocked[2] = false; // Level 3 잠금 해제
        }
      });
    } catch (e) {
      print("Error loading user level data: $e"); // 에러를 로그로 출력
    }
  }

  void _permissionWithNotification() async {
    await [Permission.notification].request();
  }

  void _initialization() async {
    AndroidInitializationSettings android =
    const AndroidInitializationSettings("@mipmap/ic_launcher");
    DarwinInitializationSettings ios = const DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    InitializationSettings settings =
    InitializationSettings(android: android, iOS: ios);
    await _local.initialize(settings);
  }

  void unlockLevel(int level) {  //잠금 해제
    setState(() {   //상태 변경 시 UI 갱신
      if (level - 1 < totalLevels) {  //유효한 level 인지 확인
        isLocked[level - 1] = false;  //해당 level 잠금 해제
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(top: 50.0),
        children: List.generate(totalLevels, (index) {
          final levelNumber = index + 1;
          return Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: buildLevelContainer('level $levelNumber', level: levelNumber, isLocked: isLocked[index]),
              ),
              const SizedBox(height: 20),
            ],
          );
        }),
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        context,
        onHomePressed,
        onRankingPressed,
        onProfilePressed,
      ),
    );
  }


  Widget buildLevelContainer(String levelText, {required int level, bool isLocked = false}) {
    return isLocked
        ? notYetLevel(levelText)
        : Container(
      width: 300,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF66A2FD),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF66A2FD),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            height: 85,
            child: Center(
              child: Text(
                levelText,
                style: const TextStyle(
                  color: Color(0xFFF0EC7D),
                  fontSize: 35,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 5),
                      blurRadius: 4.0,
                      color: Color.fromARGB(128, 0, 0, 0),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 1.5,
            color: Colors.white,
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Quiz(level: level),
                        ),
                      ).then((value) {
                        if (value == true) {
                          _loadUserLevelData(); // 레벨 상태를 갱신
                        }
                      });
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF66A2FD),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '문제\n풀기',
                          style: TextStyle(
                            color: Color(0xFFF0EC7D),
                            fontSize: 22,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 3),
                                blurRadius: 4.0,
                                color: Color.fromARGB(128, 0, 0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 2,
                  color: Colors.white,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WordView(title: '단어장', level: level),
                        ),
                      );
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF66A2FD),
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '단어\n보기',
                          style: TextStyle(
                            color: Color(0xFFF0EC7D),
                            fontSize: 22,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 3),
                                blurRadius: 4.0,
                                color: Color.fromARGB(128, 0, 0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }





  Widget notYetLevel(String levelText) {   // 잠긴 레벨 표시 위젯
    return Stack( // 스택으로 겹쳐서 표시
      children: [
        Container(
          width: 300,
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFF66A2FD),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [  //그림자
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                offset: Offset(0, 4),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF66A2FD),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                height: 85,
                child: Center(
                  child: Text(
                    levelText,
                    style: const TextStyle(
                      color: Color(0xFFF0EC7D),
                      fontSize: 35,
                    ),
                  ),
                ),
              ),
              Container(
                height: 1.5,
                color: Colors.white,
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF66A2FD),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '문제\n풀기',
                            style: TextStyle(
                              color: Color(0xFFF0EC7D),
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 2,
                      color: Colors.white,
                    ),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF66A2FD),
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '단어\n보기',
                            style: TextStyle(
                              color: Color(0xFFF0EC7D),
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 300,
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xBB3C3F43),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Center(
            child: Icon(
              Icons.lock,
              color: Colors.black54,
              size: 40,
            ),
          ),
        ),
      ],
    );
  }

}