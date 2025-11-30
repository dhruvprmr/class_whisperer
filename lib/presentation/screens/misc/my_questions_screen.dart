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
      backgroundColor: const Color(0xFFF5F8F7),
      body: Stack(
        children: [
          // Gradient header
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00C68E), Color(0xFF009B8F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "My Questions",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: StreamBuilder(
                    stream: ref.onValue,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final raw = snap.data?.snapshot.value as Map?;
                      if (raw == null || raw.isEmpty) {
                        return const Center(
                          child: Text(
                            'No questions yet 🤔',
                            style: TextStyle(color: Colors.black54, fontSize: 16),
                          ),
                        );
                      }

                      final items = raw.entries.toList()
                        ..sort((a, b) {
                          final t1 = (a.value['timestamp'] ?? 0) as int;
                          final t2 = (b.value['timestamp'] ?? 0) as int;
                          return t2.compareTo(t1);
                        });

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final e = items[index];
                          final q = e.value as Map;

                          final path = q['path'] ?? '';

                          return FutureBuilder(
                            future: FirebaseDatabase.instance.ref().child(path).child('text').get(),
                            builder: (context, textSnap) {
                              final text = textSnap.data?.value?.toString() ?? 'Loading...';
                              // existing parsing
                              final segments = path.split('/');
                              final type = segments.isNotEmpty ? segments[0] : 'unknown';
                              final courseId = segments.length > 1 ? segments[1] : 'unknown';
                              final lectureId = (type == 'lectureQuestions' && segments.length > 2) ? segments[2] : null;

                              return FutureBuilder(
                                future: FirebaseDatabase.instance.ref().child('courses/$courseId').get(),
                                builder: (context, courseSnap) {
                                  final courseData = courseSnap.data?.value as Map?;
                                  final courseTitle = courseData?['title'] ?? courseId;
                                  final courseCode = courseData?['code'] ?? '';

                                  return FutureBuilder(
                                    future: type == 'lectureQuestions'
                                        ? FirebaseDatabase.instance.ref().child('lectures/$courseId/$lectureId').get()
                                        : Future.value(null),
                                    builder: (context, lectureSnap) {
                                      final lectureData = lectureSnap.data?.value as Map?;
                                      final lectureTitle = lectureData?['title'] ?? lectureId;

                                      final subtitle = type == 'courseGeneralQuestions'
                                          ? "General – $courseTitle ($courseCode)"
                                          : "Lecture: $lectureTitle – $courseTitle ($courseCode)";

                                      return Container(
                                        margin: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFFF6FFFB), Color(0xFFEAFDF7)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          leading: CircleAvatar(
                                            radius: 24,
                                            backgroundColor: const Color(0xFF00C68E).withOpacity(0.15),
                                            child: const Icon(Icons.help_outline, color: Color(0xFF009B8F)),
                                          ),
                                          title: Text(
                                            text,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: Color(0xFF002B27),
                                            ),
                                          ),
                                          subtitle: Text(
                                            subtitle,
                                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                          ),
                                          trailing: const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          onTap: () {},
                                        ),
                                      );
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
        ],
      ),
    );
  }
}
