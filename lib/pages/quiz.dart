import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class Quiz extends StatefulWidget {
  final int level; // 현재 레벨을 받는 변수 추가

  const Quiz({Key? key, required this.level}) : super(key: key);

  @override
  Quizstate createState() => Quizstate();
}

class Quizstate extends State<Quiz> {
  final TextEditingController _controller = TextEditingController();
  int currentQuestion = 0;
  int totalQuestions = 3; // 3문제만 출제하도록 설정
  int correctCount = 0;
  List<Question> questions = [];
  bool showResult = false;
  bool isCorrect = false;
  bool tryAgainVisible = false;
  bool isCorrectMessageVisible = false; // 정답 메시지 표시 여부

  @override
  void initState() {
    super.initState();
    _loadQuestions(widget.level); // 선택한 레벨에 맞는 문제를 로드
  }

  Future<void> _loadQuestions(int level) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    List<Question> loadedQuestions = [];

    // Firestore의 사용자의 하위 컬렉션에 접근하여 선택한 레벨에 맞는 데이터 가져오기
    final wordsBookCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('wordsBook$level');

    final snapshot = await wordsBookCollection.get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      String exampleCloze = data['example_cloze'] ?? '';
      String correctAnswer = data['words'] ?? '';
      String exampleKo = data['example_ko'] ?? ''; // 한국어 예문 불러오기

      // 문제가 비어있지 않으면 리스트에 추가
      if (exampleCloze.isNotEmpty && correctAnswer.isNotEmpty) {
        loadedQuestions.add(
          Question(
            questionEnglish: exampleCloze,
            correctAnswer: correctAnswer,
            exampleKo: exampleKo,
          ),
        );
      }
    }

    // Shuffle and select the first 3 questions
    loadedQuestions.shuffle(Random());
    questions = loadedQuestions.take(totalQuestions).toList();

    setState(() {});
  }

  void checkAnswer() {
    setState(() {
      isCorrect = _controller.text.trim().toLowerCase() == questions[currentQuestion].correctAnswer.toLowerCase();
      if (isCorrect) {
        correctCount++;
        showResult = true;
        isCorrectMessageVisible = true; // 정답 메시지 표시
        tryAgainVisible = false;
      } else {
        showResult = false;
        tryAgainVisible = true;
        _startTryAgainTimer();
      }
    });
  }

  void _startTryAgainTimer() {
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        tryAgainVisible = false; // 3초 후 메시지 숨김
      });
    });
  }

  void nextQuestion() {
    setState(() {
      if (currentQuestion < totalQuestions - 1) {
        currentQuestion++; // 다음 문제로 이동
        _controller.clear(); // TextField 빈칸으로 초기화
        isCorrect = false;
        showResult = false;
        isCorrectMessageVisible = false; // 다음 문제로 넘어가면 정답 메시지 숨김
      } else {
        _showScore();
        _controller.clear();
      }
    });
  }

  void _showScore() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFDBE4F8),
          title: Center(child: Text('🎉문제 풀이 완료🎉', style: TextStyle(fontSize: 24, color: Color(0xFF3A88FA)))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '이번 결과: $correctCount / $totalQuestions 맞춤\n',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              if (correctCount >= 2)
                Text(
                  '다음 레벨이 열렸습니다!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.green),
                ),
              if (correctCount < 2)
                Text(
                  '다음 레벨 잠금 해제에 실패했습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
            ],
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFF7EB3FF),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  '홈으로 돌아가기',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  if (correctCount >= 2) {
                    _unlockNextLevel();
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _unlockNextLevel() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final snapshot = await userDoc.get();

    if (snapshot.exists) {
      int currentLevel = snapshot['level'] ?? 1;
      if (widget.level == currentLevel && currentLevel < 3) {
        await userDoc.update({'level': currentLevel + 1});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF7EB3FF),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 70.0),
        child: questions.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 상단 진행바
            Row(
              children: [
                Icon(Icons.directions_run, color: Colors.black),
                SizedBox(width: 8),
                Text('${currentQuestion + 1}/$totalQuestions', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (currentQuestion + 1) / totalQuestions,
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
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(128, 0, 0, 0),
                    blurRadius: 3.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        questions[currentQuestion].exampleKo,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        questions[currentQuestion].questionEnglish,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (tryAgainVisible)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            tryAgainVisible = false;
                          });
                        },
                        child: Container(
                          color: Color(0xFFFF5E5E),
                          alignment: Alignment.center,
                          child: Text(
                            'Try again',
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),
                        ),
                      ),
                    ),
                  if (isCorrectMessageVisible)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isCorrectMessageVisible = false;
                          });
                        },
                        child: Container(
                          color: Color(0xFF5ECC5E),
                          alignment: Alignment.center,
                          child: Text(
                            '정답입니다!',
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 15),

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

            // 정답 확인 및 힌트 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Color(0xFFDBE4F8),
                          title: Center(child: Text('정답 보기', style: TextStyle(fontSize: 24))),
                          content: Text(
                            '정답은 "${questions[currentQuestion].correctAnswer}"입니다.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          ),
                          actions: <Widget>[
                            Center(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Color(0xFF7EB3FF),
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                ),
                                child: Text(
                                  '확인',
                                  style: TextStyle(color: Colors.black),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  if (currentQuestion >= questions.length - 1) {
                                    _showScore();
                                  } else {
                                    nextQuestion();
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF5E5E),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    textStyle: TextStyle(fontSize: 17),
                  ),
                  child: Text(
                    '정답 보기',
                    style: TextStyle(
                      fontFamily: 'dohyeon',
                      color: Color(0xFF1E1E1B),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: checkAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFAE67B),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    elevation: 4,
                  ),
                  child: Text(
                    '정답 확인',
                    style: TextStyle(fontSize: 17, color: Color(0xFF684A0B)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // 정답일 경우에만 다음 문제 버튼 표시
            if (isCorrect && showResult)
              ElevatedButton(
                onPressed: () {
                  if (currentQuestion < totalQuestions - 1) {
                    nextQuestion();
                  } else {
                    _showScore();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFAE67B),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  textStyle: TextStyle(fontSize: 17),
                ),
                child: Text(
                  '다음 문제',
                  style: TextStyle(
                    fontFamily: 'dohyeon',
                    color: Color(0xFF1E1E1B),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Question {
  final String questionEnglish;
  final String correctAnswer;
  final String exampleKo; // 한국어 예문 추가

  Question({
    required this.questionEnglish,
    required this.correctAnswer,
    required this.exampleKo,
  });
}
