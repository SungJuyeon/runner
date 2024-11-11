import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 패키지 추가
import 'navigationBar.dart';

class WordView extends StatefulWidget {
  final String title;
  final int level;

  WordView({super.key, required this.title, required this.level});

  @override
  _WordViewState createState() => _WordViewState();
}

class _WordViewState extends State<WordView> {
  List<WordList> wordbook = <WordList>[];

  @override
  void initState() {
    super.initState();
    _loadWordsFromFirestore(); // Firestore에서 단어 로드
  }

  Future<void> _loadWordsFromFirestore() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      print('User ID: $userId'); // 사용자 ID 확인

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId) // 실제 사용자 ID로 변경 필요
          .collection('wordsBook${widget.level}')
          .get();

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          String wordbookName = doc['words'] ?? '';
          String sentenceKor = doc['meaning_ko'] ?? '';
          String exampleEn = doc['example_en'] ?? '';
          String exampleKo = doc['example_ko'] ?? '';
          bool isChecked = doc['words_correct'] ?? false;
          wordbook.add(WordList(wordbookName, sentenceKor, exampleEn, exampleKo, isChecked, doc.id));
          print('Added word: $wordbookName, meaning: $sentenceKor'); // 각 문서 정보 출력
        }
        setState(() {}); // 데이터 추가 후 상태 업데이트
      } else {
        print('No words found for this level');
      }
    } catch (e) {
      print('Error loading words: $e'); // 오류 메시지 출력
    }
  }

  Future<void> _updateWordsCorrectField(String docId, bool newValue) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('wordsBook${widget.level}')
          .doc(docId)
          .update({'words_correct': newValue});
      print('words_correct field updated for docId: $docId');
    } catch (e) {
      print('Error updating words_correct field: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFF66A2FD),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Text(
                'Level ${widget.level}',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      body: Center(child: wordBookView(context)),
      bottomNavigationBar: buildBottomNavigationBar(
        context,
        onHomePressed,
        onRankingPressed,
        onProfilePressed,
      ),
    );
  }

  Widget wordBookView(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: wordbook.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  wordbook[index].wordbookName, // 영어 단어
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  wordbook[index].sentenceKor, // 한글 뜻
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WordListPage(wordList: wordbook[index]),
              ),
            );
          },
          tileColor: wordbook[index].isChecked ? Color(0xFFFBEA7A) : null,
          trailing: Checkbox(
            value: wordbook[index].isChecked,
            activeColor: Color(0xFFF0EC7D),
            onChanged: (bool? value) {
              setState(() {
                wordbook[index].isChecked = value ?? false;
              });
              _updateWordsCorrectField(wordbook[index].docId, value ?? false);
            },
          ),
        );
      },
    );
  }
}

class WordList {
  String wordbookName; // 영어 단어
  String sentenceKor; // 한글 뜻
  String exampleEn; // 영어 문장
  String exampleKo; // 영어 문장 해석
  bool isChecked;
  String docId;

  WordList(this.wordbookName, this.sentenceKor, this.exampleEn, this.exampleKo, this.isChecked, this.docId);
}

class WordListPage extends StatelessWidget {
  final WordList wordList;

  WordListPage({Key? key, required this.wordList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(wordList.wordbookName),
        backgroundColor: Color(0xFF67A4FB),
      ),
      body: Padding(
        padding: EdgeInsets.all(13),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xFF88BDFD),
                ),
                child: Column(
                  children: [
                    Text(
                      wordList.exampleEn, // 영어 문장
                      style: TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                      wordList.exampleKo, // 영어 문장 해석
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
