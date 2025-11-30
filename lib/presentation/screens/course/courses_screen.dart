import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../data/repositories/rtdb_repository.dart';
import '../../../routes/app_routes.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

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
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('❌ Course not found')));
        return;
      }
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await repo.joinCourse(courseId: courseId, uid: uid, role: 'student');
      if (!mounted) return;

      // FIX: fetch course details before navigating
      final snap = await FirebaseDatabase.instance
          .ref()
          .child('courses/$courseId')
          .get();

      final data = (snap.value as Map?) ?? {};
      final title = data['title'] ?? '';
      final codeValue = data['code'] ?? '';

      Navigator.pushNamed(
        context,
        AppRoutes.courseHome,
        arguments: {
          'courseId': courseId,
          'title': title,
          'code': codeValue,
        },
      );
    } finally {
      if (mounted) setState(() => joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final db = FirebaseDatabase.instance.ref();

    return Scaffold(
      backgroundColor: const Color(0xFF009B8F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Courses',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 100,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00C68E), Color(0xFF009B8F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: StreamBuilder(
                stream: db.child('courseMembers').onValue,
                builder: (context, snapshot) {
                  final data = (snapshot.data?.snapshot.value as Map?) ?? {};
                  final my = <String>[];

                  data.forEach((courseId, members) {
                    if ((members as Map).containsKey(uid)) {
                      my.add(courseId);
                    }
                  });

                  if (my.isEmpty) {
                    return const Center(
                      child: Text("No courses yet"),
                    );
                  }

                  return ListView.builder(
                    itemCount: my.length,
                    padding: const EdgeInsets.only(bottom: 80),
                    itemBuilder: (context, index) {
                      final courseId = my[index];

                      return FutureBuilder(
                        future: db.child('courses/$courseId').get(),
                        builder: (context, snap) {
                          final courseData =
                              (snap.data?.value as Map?) ?? {};

                          final title = courseData['title'] ?? courseId;
                          final courseCode = courseData['code'] ?? '';

                          return ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(title),
                            subtitle: Text('Course Code: $courseCode'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.courseHome,
                                arguments: {
                                  'courseId': courseId,
                                  'title': title,
                                  'code': courseCode,
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00C68E),
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text("Join Course"),
        onPressed: () => _showJoinModal(context),
      ),
    );
  }

  void _showJoinModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Join a Course',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: codeCtrl,
                decoration: InputDecoration(
                  hintText: 'Enter course code',
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _join(codeCtrl.text.trim());
                },
                child: const Text("Join"),
              ),
            ],
          ),
        );
      },
    );
  }
}
