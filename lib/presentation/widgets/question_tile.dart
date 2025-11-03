import 'package:flutter/material.dart';

class QuestionTileRTDB extends StatelessWidget {
  final String id;
  final Map data;
  final VoidCallback onUpvote;
  final VoidCallback onAnswer;

  const QuestionTileRTDB({
    super.key,
    required this.id,
    required this.data,
    required this.onUpvote,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final text = (data['text'] ?? '') as String;
    final upvotes = (data['upvotes'] ?? 0) as int;
    final answers = (data['answers'] ?? {}) as Map;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: ExpansionTile(
        leading: const Icon(Icons.help_outline),
        title: Text(text),
        subtitle: Text('$upvotes upvotes • ${answers.length} answers'),
        children: [
          for (final entry in answers.entries)
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: Text('${(entry.value as Map)['text'] ?? ''}'),
            ),
          ButtonBar(
            children: [
              TextButton.icon(onPressed: onUpvote, icon: const Icon(Icons.thumb_up_alt_outlined), label: const Text('Upvote')),
              TextButton.icon(onPressed: onAnswer, icon: const Icon(Icons.reply_outlined), label: const Text('Answer')),
            ],
          ),
        ],
      ),
    );
  }
}
