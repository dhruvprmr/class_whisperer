import 'package:flutter/material.dart';

class AskProfessorScreen extends StatelessWidget {
  const AskProfessorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Ask to Professor')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: ctrl, maxLines: 6, decoration: const InputDecoration(hintText: 'Type your message...', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          FilledButton(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sent (stub)'))); }, child: const Text('Send')),
        ]),
      ),
    );
  }
}
