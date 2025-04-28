import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final List<String> suggestions;

  const ResultPage({Key? key, required this.suggestions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('あなたへのリフレッシュ提案')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(Icons.lightbulb),
              title: Text(suggestions[index]),
            );
          },
        ),
      ),
    );
  }
}
