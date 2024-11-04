import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'navigationBar.dart';

class myPage extends StatefulWidget {
  const myPage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<myPage> {
  bool isPushNotificationEnabled = false; // 푸시 알림 설정 스위치 상태
  String? nickname; // 닉네임 변수 추가
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchNickname();
  }

  // Firestore에서 닉네임을 가져오는 메서드
  Future<void> _fetchNickname() async {
    final user = _auth.currentUser;
    if (user != null) {
      // 사용자 ID로 Firestore에서 닉네임 가져오기
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        nickname = userDoc['nickname'] ?? "Guest"; // 닉네임이 없으면 기본값 'Guest'로 설정
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  elevation: 10,
                  shadowColor: const Color.fromARGB(128, 0, 0, 0),
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFF66A2FD),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF66A2FD),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      elevation: 0,
                    ),
                    onPressed: () {
                      // 로그인이 안 되어 있으면 로그인 화면으로 이동, 되어 있으면 로그아웃 기능 제공
                      if (_auth.currentUser == null) {
                        Navigator.pushNamed(context, '/login');
                      } else {
                        // 로그아웃 기능 추가
                        _auth.signOut().then((_) {
                          setState(() {
                            nickname = null; // 로그아웃 후 닉네임 초기화
                          });
                        });
                      }
                    },
                    child: Text(
                      nickname != null ? '안녕하세요, $nickname 님' : '로그인 / 회원가입하러 가기',
                      style: const TextStyle(
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
              ],
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
                  onChanged: (value) {
                    setState(() {
                      isPushNotificationEnabled = value;
                    });
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
            _buildLevelProgress('LEVEL 1', 0, 40),
            const SizedBox(height: 30),
            _buildLevelProgress('LEVEL 2', 0, 40),
            const SizedBox(height: 30),
            _buildLevelProgress('LEVEL 3', 0, 40),
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