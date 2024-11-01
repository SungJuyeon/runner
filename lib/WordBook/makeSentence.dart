import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';

Future<void> main() async {
  final wordsData = await _readWordsFromCsv('../DB/wordsBook3.csv'); // CSV 파일에서 단어 읽기
  final apiKey = Platform.environment['OPENAI_API_KEY']; // OpenAI API 키를 환경 변수에서 읽기

  if (apiKey == null) {
    print('Error: OpenAI API key is not set. Please set the OPENAI_API_KEY environment variable.');
    return;
  }

  List<List<dynamic>> updatedData = []; // 업데이트된 데이터 저장할 리스트

  // 각 단어에 대해 OpenAI API 호출
  for (var row in wordsData) {
    var word = row[0]?.toString();
    if (word == null || word.isEmpty) {
      print('Warning: Found an empty or null word in the list. Skipping...');
      updatedData.add(row); // 빈 단어는 건너뛰고 기존 행 추가
      continue;
    }

    var sentences = await _getSentenceFromOpenAI(word, apiKey);
    if (sentences != null) {
      // 각 단어에 대해 빈칸 문장과 전체 문장을 추가
      row.add(sentences['blankSentence']);
      row.add(sentences['fullSentence']);
    } else {
      row.add(''); // 에러가 발생할 경우 빈칸으로 추가
      row.add('');
    }
    updatedData.add(row);
  }

  // 업데이트된 데이터를 wordsSelect1.csv 파일에 저장
  _saveSentencesToCsv(updatedData, '../DB/wordsBook3.csv');
}

Future<List<List<dynamic>>> _readWordsFromCsv(String filePath) async {
  var content = await File(filePath).readAsString(encoding: utf8);
  var rows = const CsvToListConverter().convert(content);
  return rows;
}

Future<Map<String, String>?> _getSentenceFromOpenAI(String word, String apiKey) async {
  var url = Uri.parse('https://api.openai.com/v1/chat/completions');
  var headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
  };

  var body = jsonEncode({
    "model": "gpt-3.5-turbo",
    "messages": [
      {
        "role": "user",
        "content": "Create a sentence that includes the word '$word'. Provide the sentence in the following format:Your sentence here. Then provide the version of that sentence with '$word' replaced by '____'. The format should be:Your sentence here."

      }
    ]
  });

  var response = await http.post(url, headers: headers, body: body);

  if (response.statusCode == 200) {
    var responseBody = jsonDecode(response.body);
    var sentences = responseBody['choices'][0]['message']['content'].split('\n');

    if (sentences.length >= 2) {
      return {
        'blankSentence': sentences[0].replaceAll(RegExp(r'\s+'), ' '),
        'fullSentence': sentences[1].replaceAll(RegExp(r'\s+'), ' '),
      };
    }
  } else {
    print('Error: ${response.statusCode}');
    return null;
  }
}

void _saveSentencesToCsv(List<List<dynamic>> sentenceData, String filePath) {
  String csv = const ListToCsvConverter().convert(sentenceData);
  File(filePath).writeAsStringSync(csv, encoding: utf8);
}
