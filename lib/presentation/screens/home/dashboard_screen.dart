import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final db = FirebaseDatabase.instance.ref();
  String? anonName;
  bool loadingName = true;

  @override
  void initState() {
    super.initState();
    _fetchAnonName();
  }

  Future<void> _fetchAnonName() async {
    try {
      final snap = await db.child('users/$uid/anonName').get();
      setState(() {
        anonName = snap.value?.toString() ?? 'Student';
        loadingName = false;
      });
    } catch (e) {
      setState(() {
        anonName = 'Student';
        loadingName = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00C68E),
        title: const Text(
          'Class Whisperer',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
    );
  }

  // ---------------- Drawer ----------------

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00C68E), Color(0xFF009B8F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: loadingName
                ? const Text("Loading...", style: TextStyle(color: Colors.white70))
                : Text(
              anonName ?? "Student",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            accountEmail: Text(
              FirebaseAuth.instance.currentUser?.email ?? '',
              style: const TextStyle(color: Colors.white70),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFF00C68E), size: 36),
            ),
          ),

          _drawerTile(Icons.class_, 'Courses', AppRoutes.courses),
          _drawerTile(Icons.help_outline, 'Questions', AppRoutes.myQuestions),
          _drawerTile(Icons.mail_outline, 'Ask Professor', AppRoutes.askProfessor),

          const Divider(height: 30),

          _drawerTile(Icons.settings_outlined, 'Settings', AppRoutes.settings),
          _drawerTile(Icons.info_outline, 'About Us', AppRoutes.about),
          _drawerTile(Icons.help_center_outlined, 'Help & Support', AppRoutes.help),

          const Divider(height: 30),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Sign out'),
            onTap: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
                  (_) => false,
            ),
          ),
        ],
      ),
    );
  }

  ListTile _drawerTile(IconData icon, String text, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }

  // ---------------- Body ----------------

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Your Courses"),
          const SizedBox(height: 8),
          Expanded(flex: 1, child: _coursesList()),

          const SizedBox(height: 12),
          const Divider(thickness: 1),
          const SizedBox(height: 12),

          _sectionTitle("Your Recent Questions"),
          const SizedBox(height: 12),
          Expanded(flex: 1, child: _recentQuestionsList()),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Color(0xFF009B8F),
      ),
    );
  }

  // ---------------- COURSES ----------------

  Widget _coursesList() {
    return StreamBuilder(
      stream: db.child('courseMembers').onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00C68E)));
        }

        final data = (snapshot.data?.snapshot.value as Map?) ?? {};
        final myCourses = <String>[];

        data.forEach((courseId, members) {
          if ((members as Map).containsKey(uid)) myCourses.add(courseId);
        });

        if (myCourses.isEmpty) {
          return Center(
            child: Text(
              'You are not enrolled in any course yet.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          );
        }

        return ListView.builder(
          itemCount: myCourses.length,
          itemBuilder: (_, i) {
            final courseId = myCourses[i];

            return FutureBuilder(
              future: db.child('courses/$courseId').get(),
              builder: (context, snap) {
                final title = snap.data?.value != null
                    ? ((snap.data!.value as Map)['title'] ?? courseId)
                    : courseId;

                final code = snap.data?.value != null
                    ? ((snap.data!.value as Map)['code'] ?? courseId)
                    : courseId;

                return _gradientCourseCard(title, code, courseId);
              },
            );
          },
        );
      },
    );
  }

  Widget _gradientCourseCard(String title, String code, String courseId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C68E), Color(0xFF009B8F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF009B8F).withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.courseHome,
          arguments: courseId,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Course Code: $code",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  // ---------------- RECENT QUESTIONS ----------------

  Widget _recentQuestionsList() {
    return StreamBuilder(
      stream: db.child('userQuestions/$uid').onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00C68E)));
        }

        final data = (snapshot.data?.snapshot.value as Map?) ?? {};
        if (data.isEmpty) {
          return Center(
            child: Text('No questions yet.', style: TextStyle(color: Colors.grey.shade600)),
          );
        }

        final items = data.entries.toList();

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) {
            final entry = items[i];
            final path = (entry.value as Map)['path']?.toString() ?? '';
            final parts = path.split('/');

            if (parts.isEmpty) return const SizedBox.shrink();

            late DatabaseReference questionRef;
            String sectionLabel = "";
            String questionId = "";

            // GENERAL
            if (parts[0] == 'courseGeneralQuestions' && parts.length == 3) {
              final courseId = parts[1];
              questionId = parts[2];
              sectionLabel = "General";
              questionRef = db.child("courseGeneralQuestions/$courseId/$questionId/text");
            }

            // LECTURE
            else if (parts[0] == 'lectureQuestions' && parts.length == 4) {
              final courseId = parts[1];
              final lectureId = parts[2];
              questionId = parts[3];
              sectionLabel = "Lecture";
              questionRef = db.child("lectureQuestions/$courseId/$lectureId/$questionId/text");
            }

            else {
              return const SizedBox.shrink();
            }

            return FutureBuilder(
              future: questionRef.get(),
              builder: (context, snap) {
                final text = snap.data?.value?.toString() ?? 'No question text';
                return _gradientQuestionCard(text, sectionLabel, questionId);
              },
            );
          },
        );
      },
    );
  }

  Widget _gradientQuestionCard(String text, String sectionLabel, String questionId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF6FFFB), Color(0xFFEAFDF7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF00C68E),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.question_answer, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      "From $sectionLabel",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "• ID: ${questionId.substring(0, 6)}…",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
