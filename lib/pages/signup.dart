import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'loading.dart';


class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nicknameController = TextEditingController();

  int? selectedCharacter; // 선택된 캐릭터 ID를 저장하는 변수



  Future<void> _signUp() async {
    final nickname = _nicknameController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final email = _emailController.text.trim();

    //비밀번호 확인 검사
    if (password != confirmPassword) {
      _showErrorDialog("비밀번호 확인이 일치하지 않습니다. 다시 확인해주세요.");
      return;
    }

    // 닉네임 길이 검사
    if (nickname.length > 8) {
      _showErrorDialog("닉네임은 8자리 이하여야 합니다.");
      return;
    }

    // 비밀번호 길이 검사
    if (confirmPassword.length < 8 || confirmPassword.length > 20) {
      _showErrorDialog("비밀번호는 8-20자리여야 합니다.");
      return;
    }

    // 비밀번호 복잡성 검사 (대소문자, 숫자, 기호 포함)
    final hasUpperCase = confirmPassword.contains(RegExp(r'[A-Z]'));
    final hasLowerCase = confirmPassword.contains(RegExp(r'[a-z]'));
    final hasDigits = confirmPassword.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacters = confirmPassword.contains(RegExp(r'[!@#\$&*~]'));

    if (!(hasUpperCase && hasLowerCase && hasDigits && hasSpecialCharacters)) {
      _showErrorDialog("비밀번호에는 대소문자, 숫자, 기호가 포함되어야 합니다.");
      return;
    }

    // 캐릭터 선택 검사
    if (selectedCharacter == null) {
      _showErrorDialog("캐릭터를 선택해주세요.");
      return;
    }

    // 닉네임 중복 체크
    final nicknameExists = await _checkNicknameExists(nickname);
    if (nicknameExists) {
      _showErrorDialog("이미 사용 중인 닉네임입니다. 다른 닉네임을 입력해주세요.");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoadingScreen()), // Navigate to loading screen
    );

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String userId = userCredential.user!.uid;

      await _firestore.collection('users').doc(userId).set({
        'nickname': _nicknameController.text.trim(),
        'email': _emailController.text.trim(),
        'password' : _confirmPasswordController.text.trim(),
        'character': selectedCharacter,
        'level' : 1,
        'level1_true' : 0,
        'level2_true' : 0,
        'level3_true' : 0,
        'createdAt': Timestamp.now(),
      });

      await _createWordsCollection(userId); // 회원가입 후 호출

      Navigator.pushNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'email-already-in-use') {
        _showErrorDialog("이미 존재하는 이메일입니다.");
      } else {
        _showErrorDialog("회원가입 중 오류가 발생했습니다: ${e.message}");
      }
    } catch (e) {
      Navigator.pop(context);
      print("Error during signup: $e");
      _showErrorDialog("회원가입 중 오류가 발생했습니다.");
    }
  }

  Future<bool> _checkNicknameExists(String nickname) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('nickname', isEqualTo: nickname)
        .get();

    return querySnapshot.docs.isNotEmpty; // 닉네임이 존재하면 true 반환
  }


  Future<void> _createWordsCollection(String userId) async {
    final firestore = FirebaseFirestore.instance;

    // Firebase Storage에서 업로드한 파일의 URL을 여기에 추가하세요
    List<String> fileUrls = [
      'https://firebasestorage.googleapis.com/v0/b/runner-fcaf6.firebasestorage.app/o/wordsBook1.csv?alt=media&token=9ac6f619-b97f-4188-bf17-9ae84224ee0a',
      'https://firebasestorage.googleapis.com/v0/b/runner-fcaf6.firebasestorage.app/o/wordsBook2.csv?alt=media&token=c2b3dc43-8d16-48f9-b916-c35ff8d46401',
      'https://firebasestorage.googleapis.com/v0/b/runner-fcaf6.firebasestorage.app/o/wordsBook3.csv?alt=media&token=26aeb4a5-585a-4aaa-b063-5ee71f97e266',
    ];

    for (int i = 0; i < fileUrls.length; i++) {
      final response = await http.get(Uri.parse(fileUrls[i]));

      if (response.statusCode == 200) {
        // 응답 바이트를 UTF-8로 디코딩한 후 CSV로 변환
        String csvData = utf8.decode(response.bodyBytes);
        List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);

        for (int j = 0; j < rows.length && j < 40; j++) {
          var row = rows[j];
          if (row.length < 4) continue; // 데이터가 4열보다 적은 경우 생략

          // 문서 이름을 1부터 40까지 숫자로 설정
          await firestore.collection('users').doc(userId).collection('wordsBook${i + 1}').doc((j + 1).toString()).set({
            'words': row[0],
            'meaning_ko': row[1],
            'example_en': row[2],
            'example_cloze': row[3],
            'example_ko': row[4],
            'words_correct': false,
            'sentence_correct': false,
          });
        }
      } else {
        print('Failed to load CSV file at ${fileUrls[i]}');
      }
    }
  }


// 오류 메시지를 다이얼로그로 표시하는 헬퍼 함수
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("오류"),
        content: Text(
          message,
          style: TextStyle(color: Colors.red), // 텍스트 색상을 빨간색으로 설정
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black, // 텍스트 색상을 빨간색으로 설정
            ),
            child: Text("확인"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // 뒤로 가기
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Color(0xFF66A2FD), // 배경색 설정
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '어너러너',
                style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                '회원가입',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              buildCustomTextField('닉네임', controller: _nicknameController),
              SizedBox(height: 20),
              buildCustomTextField('이메일', controller: _emailController),
              SizedBox(height: 20),
              buildCustomTextField('비밀번호', controller: _passwordController, obscureText: true),
              SizedBox(height: 20),
              buildCustomTextField('비밀번호 확인', controller: _confirmPasswordController, obscureText: true),
              SizedBox(height: 20),
              Text(
                '캐릭터 선택',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.yellow),
              ),
              SizedBox(height: 10),
              buildCharacterSelection(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    side: BorderSide.none,
                  ),
                ),
                child: Text(
                  '회원가입',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget buildCustomTextField(String label, {bool obscureText = false, required TextEditingController controller}) {
    return Row(
      children: [
        Container(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.yellow,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(30.0),
            shadowColor: Colors.black26,
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              obscuringCharacter: '*',
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCharacterSelection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildCharacterOption(1, 'assets/image/learnerBear.png'),
          SizedBox(width: 10),
          buildCharacterOption(2, 'assets/image/learnerBrown.png'),
          SizedBox(width: 10),
          buildCharacterOption(3, 'assets/image/learnerRabbit.png'),
        ],
      ),
    );
  }


  Widget buildCharacterOption(int characterId, String assetPath) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCharacter = characterId;
        });
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                color: selectedCharacter == characterId ? Colors.yellow : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              assetPath,
              width: 80,
              height: 80,
            ),
          ),
          if (selectedCharacter == characterId)
            Icon(
              Icons.check_circle,
              color: Colors.yellow,
              size: 20,
            )
        ],
      ),
    );
  }
}