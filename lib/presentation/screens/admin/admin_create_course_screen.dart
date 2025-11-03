import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../data/repositories/rtdb_repository.dart';

class AdminCreateCourseScreen extends StatefulWidget { const AdminCreateCourseScreen({super.key}); @override State<AdminCreateCourseScreen> createState() => _AdminCreateCourseScreenState(); }
class _AdminCreateCourseScreenState extends State<AdminCreateCourseScreen> {
  final title = TextEditingController();
  final code = TextEditingController();
  String? courseId;

  @override
  Widget build(BuildContext context) {
    final repo = RTDBRepo();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Admin: Create Course')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(controller: title, decoration: const InputDecoration(labelText: 'Course Title')),
          const SizedBox(height: 8),
          TextField(controller: code, decoration: const InputDecoration(labelText: 'Course Code (for QR)')),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () async {
              if (title.text.trim().isEmpty || code.text.trim().isEmpty) return;
              final id = await repo.createCourse(title: title.text.trim(), code: code.text.trim(), adminUid: uid);
              setState(() => courseId = id);
            },
            child: const Text('Create Course'),
          ),
          const SizedBox(height: 16),
          if (courseId != null) ...[
            SelectableText('Course ID: $courseId'),
            const SizedBox(height: 8),
            Center(child: QrImageView(data: code.text.trim(), size: 200)),
            const SizedBox(height: 8),
            const Text('Share this QR or code so students/professors can join.'),
          ],
        ]),
      ),
    );
  }
}
