// pages/wordView.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

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
    _loadWordsFromCsv();
  }

  Future<void> _loadWordsFromCsv() async {
    final String content = await rootBundle.loadString('../assets/wordBook/wordsBook${widget.level}.csv');
    final rows = const CsvToListConverter().convert(content);

    for (var row in rows) {
      if (row.length >= 4) { // Ensure row has enough columns
        String wordbookName = row[0].toString();
        String additionalInfo = row[1].toString();
        String sentenceEng = row[2].toString();
        String sentenceKor = row[4].toString();
        wordbook.add(WordList(wordbookName, additionalInfo, sentenceEng, sentenceKor));
      }
    }
    setState(() {});
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
          leading: Checkbox(
            value: wordbook[index].isChecked,
            activeColor: Color(0xFFF0EC7D),
            onChanged: (bool? value) {
              setState(() {
                wordbook[index].isChecked = value ?? false;
              });
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(wordbook[index].wordbookName),
              Text(wordbook[index].additionalInfo),
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
          tileColor: wordbook[index].isChecked ? Color(0xFFF0EC7D) : null,
        );
      },
    );
  }
}

class WordList {
  String wordbookName;
  String additionalInfo;
  String sentenceEng;
  String sentenceKor;
  bool isChecked;

  WordList(this.wordbookName, this.additionalInfo, this.sentenceEng, this.sentenceKor, {this.isChecked = false});
}

class WordListPage extends StatelessWidget {
  final WordList wordList;

  WordListPage({Key? key, required this.wordList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(wordList.wordbookName),
      ),
      body: Padding(
        padding: EdgeInsets.all(13),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                wordList.sentenceEng, // English sentence
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(height: 100),
              Text(
                wordList.sentenceKor, // Korean translation
                style: TextStyle(fontSize: 20, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
