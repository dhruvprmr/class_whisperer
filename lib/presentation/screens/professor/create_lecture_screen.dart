import 'package:flutter/material.dart';
import '../../../data/repositories/rtdb_repository.dart';

class CreateLectureScreen extends StatefulWidget { const CreateLectureScreen({super.key}); @override State<CreateLectureScreen> createState() => _CreateLectureScreenState(); }
class _CreateLectureScreenState extends State<CreateLectureScreen> {
  final title = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final courseId = ModalRoute.of(context)!.settings.arguments as String;
    final repo = RTDBRepo();
    return Scaffold(
      appBar: AppBar(title: const Text('Create Lecture Session')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: title, decoration: const InputDecoration(labelText: 'Lecture Title')),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              await repo.createLecture(courseId, title.text.trim().isEmpty ? 'Lecture' : title.text.trim());
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ]),
      ),
    );
  }
}
