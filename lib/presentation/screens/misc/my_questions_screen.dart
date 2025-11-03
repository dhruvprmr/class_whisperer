import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MyQuestionsScreen extends StatelessWidget {
  const MyQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseDatabase.instance.ref().child('userQuestions/$uid');
    return Scaffold(
      appBar: AppBar(title: const Text('My Questions')),
      body: StreamBuilder(
        stream: ref.onValue,
        builder: (context, snap) {
          final data = (snap.data?.snapshot.value as Map?) ?? {};
          if (data.isEmpty) return const Center(child: Text('No questions yet.'));
          final items = data.entries.toList();
          return ListView(
            children: items.map((e) => ListTile(
              leading: const Icon(Icons.question_answer_outlined),
              title: Text('Question ${e.key}'),
              subtitle: Text('${(e.value as Map)['path']}'),
            )).toList(),
          );
        },
      ),
    );
  }
}
