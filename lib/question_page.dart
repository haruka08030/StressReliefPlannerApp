import 'package:flutter/material.dart';
import 'result_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuestionPage extends StatefulWidget {
  const QuestionPage({Key? key});

  @override
  QuestionPageState createState() => QuestionPageState();
}

class QuestionPageState extends State<QuestionPage> {
  Future<List<String>> sendAnswersToServer() async {
    final url = Uri.parse('http://127.0.0.1:8000/generate_plan');

    final body = {
      "mood": _answers[0] ?? '',
      "time_available": _answers[1] ?? '',
      "energy_level": _answers[2] ?? '',
      "refresh_preference": _answers[3] ?? '',
      "desired_outcome": _answers[4] ?? '',
      "budget": _answers[5] ?? '',
      "optional_comment": _answers[6] ?? '',
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      final data = json.decode(utf8Body);
      final suggestions = data['suggestions'];

      if (suggestions is String) {
        // モックの場合
        return [suggestions];
      } else if (suggestions is List) {
        return List<String>.from(suggestions);
      } else {
        return ["提案が取得できませんでした。"];
      }
    } else {
      throw Exception('Failed to fetch suggestions');
    }
  }

  int _currentQuestionIndex = 0;
  final Map<int, String> _answers = {};

  final List<Map<String, Object>> _questions = [
    {
      'question': '今の気分を教えてください',
      'options': [
        'イライラしている',
        'だるくてやる気が出ない',
        '落ち込んでいる・不安',
        '元気だけど疲れた',
        '特にない（普通）',
      ],
    },
    {
      'question': '今、自由に使える時間はどれくらいありますか？',
      'options': ['30分以内', '1時間くらい', '2時間くらい', '半日くらい', '丸一日'],
    },
    {
      'question': '今日の体力レベルは？',
      'options': ['かなり疲れている', '少し疲れている', '元気'],
    },
    {
      'question': '好きなリフレッシュ方法は？',
      'options': ['インドア', 'アウトドア', 'どちらでも'],
    },
    {
      'question': '今、求めているものは？',
      'options': [
        'リラックスしたい',
        '気分転換したい',
        '自己肯定感を高めたい',
        'とにかく休みたい',
        '感情をエネルギーに変えたい',
      ],
    },
    {
      'question': '予算はどのくらい？',
      'options': ['無料〜1000円以内', '1000〜5000円くらい', '気にしない'],
    },
    {'question': '気になるテーマがあれば自由に記入（オプション）', 'options': []},
  ];

  String _selectedOption = '';

  void _nextQuestion() {
    if (_selectedOption.isNotEmpty || _currentQuestionIndex == 6) {
      _answers[_currentQuestionIndex] = _selectedOption;
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedOption = '';
        });
      } else {
        sendAnswersToServer()
            .then((suggestions) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultPage(suggestions: suggestions),
                ),
              );
            })
            .catchError((error) {
              print('Error: $error');
              // エラー時は適当にダミーデータで進める
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          ResultPage(suggestions: ['エラーが発生しました。リトライしてください。']),
                ),
              );
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(title: const Text('ストレス診断')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
            ),
            SizedBox(height: 20),
            Text(
              currentQuestion['question'] as String,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            if ((currentQuestion['options'] as List<dynamic>).isNotEmpty)
              ...((currentQuestion['options'] as List<dynamic>)
                  .cast<String>()
                  .map((option) {
                    return RadioListTile(
                      title: Text(option),
                      value: option,
                      groupValue: _selectedOption,
                      onChanged: (value) {
                        setState(() {
                          _selectedOption = value!;
                        });
                      },
                    );
                  })
                  .toList())
            else
              TextField(
                decoration: InputDecoration(hintText: 'ここに自由入力'),
                onChanged: (value) {
                  _selectedOption = value;
                },
              ),
            Spacer(),
            ElevatedButton(onPressed: _nextQuestion, child: const Text('次へ')),
          ],
        ),
      ),
    );
  }
}
