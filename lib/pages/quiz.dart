// pages/quiz.dart
import 'package:flutter/material.dart';

class Quiz extends StatefulWidget {
  const Quiz({Key? key}) : super(key: key);

  @override
  Quizstate createState() => Quizstate();
}

class Quizstate extends State<Quiz> {
  final TextEditingController _controller = TextEditingController();
  int currentQuestion = 1;
  int totalQuestions = 20;
  String questionKorean = '그들은 이제 비교적 안락하게 산다.';
  String questionEnglish = 'They now live in ___ comfort.';
  String correctAnswer = 'relative';
  bool showResult = false;
  bool isCorrect = false;

  void checkAnswer() {
    setState(() {
      isCorrect = _controller.text.trim().toLowerCase() == correctAnswer.toLowerCase();
      showResult = true;
    });
  }

  void nextQuestion() {
    setState(() {
      _controller.clear();
      showResult = false;
      // 임시로 다음 문제 설정
      currentQuestion++;
      questionKorean = '새로운 문제 해석입니다.';
      questionEnglish = 'New question with ___ blank.';
      correctAnswer = 'example'; // 예시 답변
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF7EB3FF),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 상단 진행바
            Row(
              children: [
                Icon(Icons.directions_run, color: Colors.black),
                SizedBox(width: 8),
                Text('$currentQuestion/$totalQuestions', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: LinearProgressIndicator(
                    value: currentQuestion / totalQuestions,
                    backgroundColor: Colors.grey[300],
                    color: Colors.redAccent,
                  ),
                ),
                Icon(Icons.flag, color: Colors.black),
              ],
            ),
            SizedBox(height: 20),

            // 문제 박스
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFFAE67B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    questionKorean,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: questionEnglish.replaceAll('___', ' '),
                          style: TextStyle(fontSize: 24, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // 정답 입력란
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: '정답 입력',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // 정답 확인 버튼
            ElevatedButton(
              onPressed: checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFAE67B),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('정답 확인',
                  style: TextStyle(fontSize: 18,
                    color: Colors.black,
                  )
              ),
            ),

            // 정답 결과 표시
            if (showResult)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  isCorrect ? '정답입니다!' : '오답입니다. 정답은 "$correctAnswer"입니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    color: isCorrect ? Color(0xFFFDDB14) : Color(0xFFFF3C2B),
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 2.0,
                        color: Color.fromARGB(128, 0, 0, 0), // 텍스트 그림자 설정
                      ),
                    ],
                  ),
                ),
              ),

            // 다음 문제로 이동 버튼
            if (showResult)
              ElevatedButton(
                onPressed: nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFAE67B),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('다음 문제',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    )
                ),
              ),
          ],
        ),
      ),
    );
  }
}
