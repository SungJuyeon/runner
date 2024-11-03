// pages/wordView.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

import 'navigationBar.dart';
//합쳐져라
class WordView extends StatefulWidget {
  final String title;
  final int level; // 레벨 추가

  WordView({super.key, required this.title, required this.level});

  @override
  _WordViewState createState() => _WordViewState();
}

class _WordViewState extends State<WordView> {
  List<WordList> wordbook = <WordList>[];

  @override
  void initState() {
    super.initState();
    _loadWordsFromCsv();
  }

  Future<void> _loadWordsFromCsv() async {
    wordbook.clear(); // 이전 데이터 제거
    // 레벨에 따라 다른 CSV 파일 로드
    final String content = await rootBundle.loadString('assets/wordBook/wordsBook${widget.level}.csv');
    //print("CSV content: $content"); // 읽은 CSV 내용 출력
    final rows = const CsvToListConverter(eol: '\n').convert(content);
    //print("Number of rows: ${rows.length}");

    for (var row in rows) {
      if (row.length >= 2) {
        String wordbookName = row[0].toString(); // 첫 번째 열
        String additionalInfo = row[1].toString(); // 두 번째 열
        wordbook.add(WordList(wordbookName, additionalInfo)); // 추가 정보와 함께 추가
      }
    }
    print("Loaded words count: ${wordbook.length}");

    setState(() {}); // 상태 업데이트
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
                color: Color(0xFF66A2FD), // 파란색 배경
                borderRadius: BorderRadius.circular(40), // 둥근 모서리
              ),
              child: Text(
                'Level ${widget.level}',
                style: TextStyle(color: Colors.white),
              ),
            ),


          ],
        ),
      ),
      body: wordBookView(context),
      bottomNavigationBar: buildBottomNavigationBar(
        context,
        onHomePressed,
        onRankingPressed,
        onProfilePressed,
      ),
    );
  }

  Widget wordBookView(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: wordbook.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items
                  children: [
                    Container(width: 100, child: Text(wordbook[index].wordbookName)),
                    SizedBox(width: 16), // 체크박스와 텍스트 사이의 간격을 설정
                    Container(
                      width: 100,
                      child: Text(
                        wordbook[index].additionalInfo,
                        textAlign: TextAlign.left,
                        //style: TextStyle(color: Colors.grey[600]), // Optional styling for the meaning
                      ),
                    ),
                    Checkbox(
                      value: wordbook[index].isChecked,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50), // 동그란 모양으로 설정
                      ),
                      activeColor: Color(0xFFffd400),
                      onChanged: (bool? value) {
                        setState(() {
                          wordbook[index].isChecked = value ?? false; // Update the checked state
                        });
                      },
                    ),
                  ],

                ),
                Divider(
                  color: Colors.black, // 구분선 색상
                  thickness: 1, // 구분선 두께
                  height: 1, // 구분선과 항목 사이의 간격 조정
                ),
              ],
            ),
            //trailing:
            //tileColor: wordbook[index].isChecked ? Color(0xFFF0EC7D) : null, // 체크 시 배경색 변경
          );
        },
      ),
    );
  }
}

class WordList {
  String wordbookName;
  String additionalInfo;
  bool isChecked;

  WordList(this.wordbookName, this.additionalInfo, {this.isChecked = false});
}
