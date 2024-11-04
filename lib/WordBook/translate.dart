import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';

Future<void> main() async {
  // Your Google Cloud Translation API Key
  const apiKey = '';

  final files = ['../DB/wordsBook3.csv'];

  for (var file in files) {
    await translateSentencesInCsv(file, apiKey);
  }
}

Future<void> translateSentencesInCsv(String filePath, String apiKey) async {

  var content = await File(filePath).readAsString(encoding: utf8);

  var rows = const CsvToListConverter().convert(content);

  List<List<dynamic>> updatedRows = [];

  // Translate each row
  for (var row in rows) {
    if (row.length > 1) {
      String sentenceToTranslate = row[2];
      String translatedSentence = await translateToKorean(sentenceToTranslate, apiKey);
      row.add(translatedSentence); // Add the translated sentence to the row
    } else {
      row.add('');
    }
    updatedRows.add(row);
  }

  // Save the updated rows back to the CSV file
  String csv = const ListToCsvConverter().convert(updatedRows);
  await File(filePath).writeAsString(csv, encoding: utf8);
}

Future<String> translateToKorean(String text, String apiKey) async {
  var url = Uri.parse('https://translation.googleapis.com/language/translate/v2?key=$apiKey');
  var response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'q': text,
      'target': 'ko', // Target language (Korean)
      'format': 'text'
    }),
  );

  if (response.statusCode == 200) {
    var responseBody = jsonDecode(response.body);
    return responseBody['data']['translations'][0]['translatedText']; // Get the translated text
  } else {
    print('Error: ${response.statusCode}');
    return 'Translation Error';
  }
}
