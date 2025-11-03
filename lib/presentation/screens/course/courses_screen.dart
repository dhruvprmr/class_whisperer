import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../data/repositories/rtdb_repository.dart';
import '../../../routes/app_routes.dart';

class CoursesScreen extends StatefulWidget { const CoursesScreen({super.key}); @override State<CoursesScreen> createState() => _CoursesScreenState(); }

class _CoursesScreenState extends State<CoursesScreen> {
  final repo = RTDBRepo();
  final codeCtrl = TextEditingController();
  bool joining = false;

  Future<void> _join(String code) async {
    if (joining || code.isEmpty) return;
    setState(() => joining = true);
    try {
      final courseId = await repo.findCourseIdByCode(code);
      if (courseId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Course not found')));
        return;
      }
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await repo.joinCourse(courseId: courseId, uid: uid, role: 'student');
      if (!mounted) return;
      Navigator.pushNamed(context, AppRoutes.courseHome, arguments: courseId);
    } finally {
      if (mounted) setState(() => joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final db = FirebaseDatabase.instance.ref();
    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      body: StreamBuilder(
        stream: db.child('courseMembers').onValue,
        builder: (context, snapshot) {
          final data = (snapshot.data?.snapshot.value as Map?) ?? {};
          final my = <String>[];
          data.forEach((courseId, members) {
            if ((members as Map).containsKey(uid)) my.add(courseId);
          });
          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              for (final courseId in my)
                FutureBuilder(
                  future: db.child('courses/$courseId').get(),
                  builder: (context, snap) {
                    final title = snap.data?.value != null ? ((snap.data!.value as Map)['title'] ?? courseId) : courseId;
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.school_outlined),
                        title: Text('$title'),
                        subtitle: Text('ID: $courseId'),
                        onTap: () => Navigator.pushNamed(context, AppRoutes.courseHome, arguments: courseId),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          showModalBottomSheet(context: context, builder: (_) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Join by Code'),
                const SizedBox(height: 8),
                TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Enter course code')),
                const SizedBox(height: 8),
                FilledButton(onPressed: () { Navigator.pop(context); _join(codeCtrl.text.trim()); }, child: const Text('Join')),
                const Divider(height: 24),
                const Text('Or Scan QR'),
                const SizedBox(height: 8),
                SizedBox(
                  height: 220,
                  child: MobileScanner(
                    onDetect: (capture) {
                      for (final b in capture.barcodes) {
                        final v = b.rawValue;
                        if (v != null && v.isNotEmpty) {
                          Navigator.pop(context);
                          _join(v);
                          break;
                        }
                      }
                    },
                  ),
                ),
              ]),
            );
          });
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Add Course'),
      ),
    );
  }
}
