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
  int totalQuestions = 20; // 20문제 출제하도록 설정
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
    List<Question> falseQuestions = [];
    List<Question> trueQuestions = [];

    final wordsBookCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('wordsBook$level');

    final snapshot = await wordsBookCollection.get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      String exampleCloze = data['example_cloze'] ?? '';
      String correctAnswer = data['words'] ?? '';
      String exampleKo = data['example_ko'] ?? '';
      bool sentenceCorrect = data['sentence_correct'] ?? false;
      String documentId = doc.id;

      if (exampleCloze.isNotEmpty && correctAnswer.isNotEmpty) {
        if (sentenceCorrect) {
          trueQuestions.add(Question(
            questionEnglish: exampleCloze,
            correctAnswer: correctAnswer,
            exampleKo: exampleKo,
            documentId: documentId,
            isFromFalseList: false,
          ));
        } else {
          falseQuestions.add(Question(
            questionEnglish: exampleCloze,
            correctAnswer: correctAnswer,
            exampleKo: exampleKo,
            documentId: documentId,
            isFromFalseList: true,
          ));
        }
      }
    }

    // 우선순위: falseQuestions를 먼저 가져오고, 남는 문제는 trueQuestions에서 채운다.
    int remainingQuestions = totalQuestions - falseQuestions.length;

    // falseQuestions에서 문제 추가
    loadedQuestions.addAll(falseQuestions);

    // 남은 문제를 trueQuestions에서 채우기
    if (remainingQuestions > 0) {
      trueQuestions.shuffle(Random());
      loadedQuestions.addAll(trueQuestions.take(remainingQuestions));
    }

    // 문제 섞기
    loadedQuestions.shuffle(Random());

    // 데이터 부족 시 방어
    if (loadedQuestions.length < totalQuestions) {
      totalQuestions = loadedQuestions.length; // 총 문제 수를 리스트 크기로 조정
    }

    questions = loadedQuestions.take(totalQuestions).toList();
    setState(() {});
  }



  void checkAnswer() async {
    final isAnswerCorrect = _controller.text.trim().toLowerCase() == questions[currentQuestion].correctAnswer.toLowerCase();
    setState(() {
      isCorrect = isAnswerCorrect;
      if (isCorrect) {
        correctCount++;
        showResult = true;
        isCorrectMessageVisible = true;
        tryAgainVisible = false;
      } else {
        showResult = false;
        tryAgainVisible = true;
        _startTryAgainTimer();
      }
    });

    // 정답이 맞았을 경우에만 Firestore 업데이트 수행
    if (isAnswerCorrect) {
      await _updateSentenceCorrect(questions[currentQuestion].documentId);
    }
  }



  //각 레벨에서 맞춘 문제 수가 30 이상일 경우 level up
  Future<void> _updateLevelProgress() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    String currentLevelField = 'level${widget.level}_true';

    final snapshot = await userDoc.get();
    if (!snapshot.exists) return;

    // Firestore에서 현재 맞춘 개수 가져오기
    int currentCount = snapshot[currentLevelField] ?? 0;

    // 다음 레벨 해제 조건 확인
    if (currentCount >= 30 && widget.level < 3) {
      await userDoc.update({
        'level': widget.level + 1, // 다음 레벨로 증가
      });
    }
  }



  Future<void> _updateSentenceCorrect(String documentId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('wordsBook${widget.level}')
        .doc(documentId);

    final docSnapshot = await docRef.get();
    bool sentenceCorrect = docSnapshot['sentence_correct'] ?? false;

    // 이미 sentence_correct가 true인 경우 중복 업데이트 방지
    if (sentenceCorrect) return;

    // 문제 출처가 falseQuestions일 경우에만 업데이트 수행
    if (questions[currentQuestion].isFromFalseList) {
      // sentence_correct를 true로 업데이트
      await docRef.update({'sentence_correct': true});

      // levelX_true 값을 1 증가
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
      String levelTrueField = 'level${widget.level}_true';
      await userDocRef.update({
        levelTrueField: FieldValue.increment(1),
      });
    }
  }



  Future<void> _saveTrueRecord() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // 닉네임 가져오기
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    String nickname = userDoc['nickname'] ?? 'Unknown User';

    // 맞춘 개수와 시간 저장
    final trueRecordCollection = FirebaseFirestore.instance.collection('trueRecord');
    await trueRecordCollection.add({
      'nickname': nickname,
      'count': correctCount, // 맞춘 개수
      'time': Timestamp.now(), // 현재 시간 저장
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
      if (currentQuestion < questions.length - 1) {
        currentQuestion++;
        _controller.clear();
        isCorrect = false;
        showResult = false;
        isCorrectMessageVisible = false;
      } else {
        _showScore();
        _controller.clear();
      }
    });
  }


  void _showScore() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final snapshot = await userDoc.get();
    if (!snapshot.exists) return;

    String currentLevelField = 'level${widget.level}_true';
    int currentLevelTrueCount = snapshot[currentLevelField] ?? 0;

    // 다음 레벨 해제까지 남은 문제 수 계산
    int remainingToNextLevel = max(0, 30 - currentLevelTrueCount);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFDBE4F8),
          title: Center(
            child: Text(
              '🎉문제 풀이 완료🎉',
              style: TextStyle(fontSize: 24, color: Color(0xFF3A88FA)),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '이번 결과: $correctCount / $totalQuestions 맞춤\n',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              if (currentLevelTrueCount >= 30)
                Text(
                  '다음 레벨이 열렸습니다!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.green),
                )
              else
                Text(
                  '다음 레벨 해제까지 $remainingToNextLevel문제 남았습니다!',
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
                onPressed: () async {
                  await _saveTrueRecord(); // 결과 저장 호출
                  await _updateLevelProgress(); // 진행도 업데이트 호출
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  Navigator.of(context).pop(true); // HomePage로 돌아가기
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
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFF7EB3FF),
      body: SingleChildScrollView(
        child: Padding(
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
      ),
    );
  }
}

class Question {
  final String questionEnglish;
  final String correctAnswer;
  final String exampleKo;
  final String documentId;
  final bool isFromFalseList; // 문제 출처 추적(true였을 경우 count 안 되게)

  Question({
    required this.questionEnglish,
    required this.correctAnswer,
    required this.exampleKo,
    required this.documentId,
    required this.isFromFalseList, // 초기화 필수
  });
}
