import 'package:flutter/material.dart';
import 'question_page.dart';

void main() {
  runApp(const StressReliefPlannerApp());
}

class StressReliefPlannerApp extends StatelessWidget {
  const StressReliefPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ストレス発散プランナー',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: QuestionPage(),
    );
  }
}
