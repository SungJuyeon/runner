// pages/wordView.dart
import 'package:flutter/material.dart';

class WordView extends StatelessWidget {
  const WordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('단어 보기')),
      body: const Center(child: Text('Word View Screen Content')),
    );
  }
}
