import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserAnswerScreen extends StatelessWidget {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController numController = TextEditingController();
  final TextEditingController wordCorrectController = TextEditingController();
  final TextEditingController sentenceCorrectController = TextEditingController();

  // Firestore에 사용자 답안 데이터 저장
  Future<void> saveUserAnswer() async {
    String userId = userIdController.text;
    int num = int.parse(numController.text);
    bool wordCorrect = wordCorrectController.text.toLowerCase() == 'true';
    bool sentenceCorrect = sentenceCorrectController.text.toLowerCase() == 'true';

    try {
      // Firestore에 'answer'라는 컬렉션을 생성하고, 데이터를 추가
      CollectionReference userAnswers = FirebaseFirestore.instance.collection('answer');
      await userAnswers.add({
        'user_id': userId,
        'num': num,
        'wordCorrect': wordCorrect,
        'sentenceCorrect': sentenceCorrect,
      });
      print('답안 데이터 저장 성공!');
    } catch (e) {
      print('답안 데이터 저장 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Answer 저장하기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: userIdController,
              decoration: InputDecoration(labelText: 'User ID'),
            ),
            TextField(
              controller: numController,
              decoration: InputDecoration(labelText: '문제 번호'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: wordCorrectController,
              decoration: InputDecoration(labelText: '단어 정답 여부 (true/false)'),
            ),
            TextField(
              controller: sentenceCorrectController,
              decoration: InputDecoration(labelText: '문장 정답 여부 (true/false)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveUserAnswer,
              child: Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
