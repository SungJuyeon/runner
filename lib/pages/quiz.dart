// pages/quiz.dart
import 'package:flutter/material.dart';

class Quiz extends StatelessWidget {
  const Quiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('문제 풀기')),
      body: const Center(child: Text('Quiz Screen Content')),
    );
  }
}
