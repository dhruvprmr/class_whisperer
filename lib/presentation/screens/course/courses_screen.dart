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
      Navigator.pushNamed(context, AppRoutes.courseHome, arguments: courseId);
    } finally {
      if (mounted) setState(() => joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final db = FirebaseDatabase.instance.ref();
    final theme = Theme.of(context);

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
          // Top decorative header curve
          Container(
            width: double.infinity,
            height: 100,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00C68E), Color(0xFF009B8F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(40),
              ),
            ),
          ),

          // Courses section
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
                  final data =
                      (snapshot.data?.snapshot.value as Map?) ?? {};
                  final my = <String>[];
                  data.forEach((courseId, members) {
                    if ((members as Map).containsKey(uid)) my.add(courseId);
                  });

                  if (my.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.library_books_outlined,
                              color: Colors.grey.shade400, size: 90),
                          const SizedBox(height: 16),
                          const Text(
                            "No courses yet",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Join a course using code or QR",
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
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
                          final title = snap.data?.value != null
                              ? ((snap.data!.value as Map)['title'] ??
                              courseId)
                              : courseId;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFE8FDF4),
                                  Color(0xFFD6FFF5),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF00C68E),
                                      Color(0xFF009B8F)
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.school_outlined,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF009B8F),
                                ),
                              ),
                              subtitle: Text(
                                'Course ID: $courseId',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                                color: Color(0xFF00C68E),
                              ),
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.courseHome,
                                arguments: courseId,
                              ),
                            ),
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
        elevation: 6,
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text(
          "Join Course",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        onPressed: () => _showJoinModal(context),
      ),
    );
  }

  void _showJoinModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
              const Text(
                'Join a Course',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF009B8F),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeCtrl,
                decoration: InputDecoration(
                  hintText: 'Enter course code',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  prefixIcon:
                  const Icon(Icons.key_rounded, color: Color(0xFF009B8F)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C68E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _join(codeCtrl.text.trim());
                },
                child: const Text(
                  "Join",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "or Scan QR",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
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
              ),
            ],
          ),
        );
      },
    );
  }
}
