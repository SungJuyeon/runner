import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'dart:math';

class Quiz extends StatefulWidget {
  const Quiz({Key? key}) : super(key: key);

  @override
  Quizstate createState() => Quizstate();
}

class Quizstate extends State<Quiz> {
  final TextEditingController _controller = TextEditingController();
  int currentQuestion = 0;
  int totalQuestions = 2; //테스트로 2개 ( 20개로 수정 )
  int correctCount = 0;
  List<Question> questions = [];
  bool showResult = false;
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    List<WordList> wordbook = [];

    // Load words from the three CSV files
    for (int level = 1; level <= 3; level++) {
      final String content = await rootBundle.loadString('assets/wordBook/wordsBook$level.csv');
      final rows = const CsvToListConverter().convert(content);

      for (var row in rows) {
        if (row.length >= 5) {
          String wordbookName = row[0].toString();
          String additionalInfo = row[1].toString();
          String sentenceEng = row[2].toString();
          String sentenceBlankEng = row[3].toString();
          String sentenceKor = row[4].toString();
          wordbook.add(WordList(wordbookName, additionalInfo, sentenceEng, sentenceBlankEng, sentenceKor));
        }
      }
    }

    // Shuffle and select 20 random questions
    wordbook.shuffle(Random());
    questions = wordbook.take(totalQuestions).map((word) {
      return Question(
        questionKorean: word.sentenceKor,
        questionEnglish: word.sentenceBlankEng,
        correctAnswer: word.wordbookName,
      );
    }).toList();

    setState(() {});
  }

  void checkAnswer() {
    setState(() {
      isCorrect = _controller.text.trim().toLowerCase() == questions[currentQuestion].correctAnswer.toLowerCase();
      if (isCorrect) correctCount++;
      showResult = true;
    });
  }

  void nextQuestion() {
    setState(() {
      _controller.clear();
      showResult = false;

      // Only increment if there are more questions to display
      if (currentQuestion < totalQuestions - 1) {
        currentQuestion++;
      } else {
        _showScore(); // Call to show the score dialog
      }
    });
  }


  void _showScore() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFDBE4F8),
          title: Center(child: Text('🎉20m 완주🎉', style: TextStyle(fontSize: 24, color: Color(
              0xFF3A88FA)))), // Title centered
          content: Column(
            mainAxisSize: MainAxisSize.min, // Ensure dialog doesn't take full height
            children: [
              Text(
                '이번 러닝 결과: $correctCount m / 20m\n'
                    '누적 러닝 결과: $correctCount m / 40m',
                textAlign: TextAlign.center, // Center the content
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          actions: <Widget>[
            Center( // Center the button
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFF7EB3FF), // Set button background color
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  '홈으로 돌아가기',
                  style: TextStyle(color: Colors.black), // Button text color
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to the previous screen
                },
              ),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Color(0xFF7EB3FF),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 70.0),
        child: Column(
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
                boxShadow: [ // Add shadow here
                  BoxShadow(
                    color: Color.fromARGB(128, 0, 0, 0), // Shadow color
                    blurRadius: 3.0, // Blur radius
                    offset: Offset(0, 4), // Shadow offset
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    questions[currentQuestion].questionKorean,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: questions[currentQuestion].questionEnglish,
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
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                elevation: 4,
              ),
              child: Text('정답 확인',
                  style: TextStyle(fontSize: 20, color: Color(0xFF684A0B)),
              ),
            ),

            // 정답 결과 표시
            if (showResult)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  isCorrect ? '정답입니다!' : '오답입니다. 정답은 "${questions[currentQuestion].correctAnswer}"입니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    color: isCorrect ? Color(0xFFFDDB14) : Color(0xFFFD3027),
                    fontWeight: FontWeight.bold,
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

            // 다음 문제로 이동 버튼
            if (showResult)
              Align(
                alignment: Alignment.centerRight, // Align to the right
                child: ElevatedButton(
                  onPressed: nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFDDB14),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12), // Smaller padding
                    textStyle: TextStyle(fontSize: 17),
                    elevation: 4,
                  ),
                  child: Text('다음 문제',style: TextStyle(
                      fontFamily: 'dohyeon',
                      color: Color(0xFF684A0B), // Text color
                    ),
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
  final String questionKorean;
  final String questionEnglish;
  final String correctAnswer;

  Question({
    required this.questionKorean,
    required this.questionEnglish,
    required this.correctAnswer,
  });
}

class WordList {
  String wordbookName;
  String additionalInfo;
  String sentenceEng;
  String sentenceBlankEng;
  String sentenceKor;

  WordList(this.wordbookName, this.additionalInfo, this.sentenceEng, this.sentenceBlankEng, this.sentenceKor);
}
