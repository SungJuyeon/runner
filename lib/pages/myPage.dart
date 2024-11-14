import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'navigationBar.dart';
import 'notification.dart';

class myPage extends StatefulWidget {
  const myPage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<myPage> {
  bool isPushNotificationEnabled = false; // 푸시 알림 설정 스위치 상태
  String? nickname;
  String? character;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int level1True = 0;
  int level2True = 0;
  int level3True = 0;

  final Map<int, String> characterMap = {
    1: "1",
    2: "2",
    3: "3",
  };


  @override
  void initState() {
    super.initState();
    _fetchNickname();
    _fetchLevelProgress();
  }

  // Firestore에서 닉네임을 가져오는 메서드
  Future<void> _fetchNickname() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      int? level = userDoc['level'];
      setState(() {
        nickname = userDoc['nickname'] ?? "Guest"; // 닉네임이 없으면 기본값 'Guest'로 설정
        character = characterMap[level] ?? "Unknown"; // Log the fetched value here
        print('Fetched character: $character');
      });
    }
  }

  // Firestore에서 각 레벨의 true 개수를 가져오는 메서드
  Future<void> _fetchLevelProgress() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    setState(() {
      level1True = userDoc['level1_true'] ?? 0;
      level2True = userDoc['level2_true'] ?? 0;
      level3True = userDoc['level3_true'] ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (nickname != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '안녕하세요, $nickname 님',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8), // 간격을 조정합니다.
                      if (character != null)
                        Text(
                          '내 레벨: $character', // character값을 보여줌
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000000),
                          ),
                        ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      _auth.signOut().then((_) {
                        setState(() {
                          nickname = null; // 로그아웃 후 닉네임 초기화
                        });
                        Navigator.pushReplacementNamed(context, '/login');
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xFFD3C108),
                    ),
                    child: const Text('로그아웃'),
                  ),
                ],
              ),
            if (nickname == null)
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF66A2FD),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    elevation: 10,
                    shadowColor: const Color.fromARGB(128, 0, 0, 0),
                  ),
                  child: const Text(
                    '로그인 / 회원가입하기',
                    style: TextStyle(
                      color: Color(0xFFF0EC7D),
                      fontSize: 20,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 2.0,
                          color: Color.fromARGB(128, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '푸시 알림 설정',
                  style: TextStyle(fontSize: 20, color: Color(0xFF66A2FD)),
                ),
                Switch(
                  value: isPushNotificationEnabled,
                  activeColor: Color(0xFF66A2FD),
                  onChanged: (value) async {
                    setState(() {
                      isPushNotificationEnabled = value;
                    });
                    if (value) {
                      // Ensure initialization before showing the notification
                      await PushNotificationService.init();
                      await PushNotificationService.showNotification();
                    }
                  },
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              '달린 기록',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            _buildLevelProgress('LEVEL 1', level1True, 40),
            const SizedBox(height: 30),
            _buildLevelProgress('LEVEL 2', level2True, 40),
            const SizedBox(height: 30),
            _buildLevelProgress('LEVEL 3', level3True, 40),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        context,
        onHomePressed,
        onRankingPressed,
        onProfilePressed,
      ),
    );
  }

  Widget _buildLevelProgress(String level, int currentProgress, int maxProgress) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 35),
      decoration: BoxDecoration(
        color: Color(0xFFFFED90),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            level,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF634A18),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$currentProgress m / $maxProgress m',
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
