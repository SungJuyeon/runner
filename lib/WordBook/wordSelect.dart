import 'dart:math';
import 'dart:io';
import 'package:csv/csv.dart';


Future<void> main() async {
  await selectWords();
}

Future<void> selectWords() async {
  var file = './DB/word.csv';
  var content = await File(file).readAsString(); // CSV 파일 읽기
  var rows = const CsvToListConverter().convert(content); // CSV를 리스트로 변환


  // 단어와 뜻 저장을 위한 리스트
  List<Map<String, String>> elementaryWords = []; //초등
  List<Map<String, String>> middleWords = [];   //중고
  List<Map<String, String>> advancedWords = [];   //전문

  //csv 에서 " 1,a,하나의,초등 " 으로 한 행에 저장되어 있음. 여기서 맨 마지막 value가 "초등" 이면 1, "중고"이면 2, "전문"이면 3 으로 level 저장
  //각 level 별로 40개의 행을 뽑아 단어와 뜻을 저장해. level 별로 (단어, 뜻)을 ./DB/wordsSelect1.csv , wordsSelect2.csv, wordsSelect3.csv에 저장

  for(var row in rows) {
    if(row.length >= 4) {
      var word = row[1]?.toString() ?? '';
      var meaning = row[2]?.toString() ?? '';
      var level = row[3]?.toString() ?? '';

      if(level == "초등") {
        elementaryWords.add({'word': word, 'meaning': meaning});
      } else if (level == "중고") {
        middleWords.add({'word': word, 'meaning': meaning});
      } else if (level == "전문") {
        advancedWords.add({'word': word, 'meaning': meaning});
      }
      //print(word + "  " + level);
    }
  }

  var selectedElementary = _selectRandomWords(elementaryWords, 40);
  var selectedMiddle = _selectRandomWords(middleWords, 40);
  var selectedAdvanced = _selectRandomWords(advancedWords, 40);

  _saveWordsToCsv(selectedElementary, './DB/wordsSelect1.csv');
  _saveWordsToCsv(selectedMiddle, './DB/wordsSelect2.csv');
  _saveWordsToCsv(selectedAdvanced, './DB/wordsSelect3.csv');

}

List<Map<String, String>> _selectRandomWords(List<Map<String, String>> words, int count) {
  final random = Random();
  words.shuffle(random);
  return words.take(count).toList();
}

void _saveWordsToCsv(List<Map<String, String>> words, String fileName) {
  List<List<dynamic>> csvData = [];

  // 선택한 단어와 뜻을 리스트에 추가
  for (var word in words) {
    csvData.add([word['word'], word['meaning']]); // 단어, 뜻, 레벨을 추가
  }

  // CSV 파일로 저장
  String csv = const ListToCsvConverter().convert(csvData);
  File(fileName).writeAsStringSync(csv);
}