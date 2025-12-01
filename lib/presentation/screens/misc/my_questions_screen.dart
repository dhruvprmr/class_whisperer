import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MyQuestionsScreen extends StatefulWidget {
  const MyQuestionsScreen({super.key});
  @override
  State<MyQuestionsScreen> createState() => _MyQuestionsScreenState();
}

class _MyQuestionsScreenState extends State<MyQuestionsScreen> {
  String filter = "all";

  Widget _buildFilterButton(String label, String value) {
    final bool active = filter == value;
    return GestureDetector(
      onTap: () => setState(() => filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(30),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFF009B8F) : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFilterButton("All", "all"),
                    _buildFilterButton("General", "general"),
                    _buildFilterButton("Lecture", "lecture"),
                    _buildFilterButton("By Course", "course"),
                  ],
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

                      final filtered = <MapEntry>[];

                      for (var e in items) {
                        final q = e.value as Map;
                        final path = q['path'] ?? '';
                        final segments = path.split('/');
                        final type = segments.isNotEmpty ? segments[0] : 'unknown';

                        if (filter == "general" && type != "courseGeneralQuestions") continue;
                        if (filter == "lecture" && type != "lectureQuestions") continue;

                        filtered.add(e);
                      }

                      final listToShow = (filter == "course") ? items : filtered;

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: listToShow.length,
                        itemBuilder: (context, index) {
                          final e = listToShow[index];
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
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.06),
                                              blurRadius: 12,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          leading: Container(
                                            width: 46,
                                            height: 46,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF00C68E).withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            child: const Icon(Icons.help_outline, color: Color(0xFF009B8F), size: 26),
                                          ),
                                          title: Text(
                                            text,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 17,
                                              color: Color(0xFF00332F),
                                              height: 1.3,
                                            ),
                                          ),
                                          subtitle: Text(
                                            subtitle,
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 14,
                                              height: 1.3,
                                            ),
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
