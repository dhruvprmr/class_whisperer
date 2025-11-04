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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header with anonName
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00C68E), Color(0xFF009B8F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName: loadingName
                  ? const Text(
                "Loading...",
                style: TextStyle(color: Colors.white70),
              )
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

            // --- MENU ITEMS ---
            ListTile(
              leading: const Icon(Icons.class_),
              title: const Text('Courses'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.courses),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Questions'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.myQuestions),
            ),
            ListTile(
              leading: const Icon(Icons.mail_outline),
              title: const Text('Ask Professor'),
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.askProfessor),
            ),
            const Divider(height: 30),

            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.settings);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About Us'),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.about);
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_center_outlined),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.help);
              },
            ),

            const Divider(height: 30),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Sign out'),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.login, (_) => false),
            ),
          ],
        ),
      ),

      // BODY (unchanged, still shows courses & questions)
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Courses',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF009B8F),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 1,
              child: StreamBuilder(
                stream: db.child('courseMembers').onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF00C68E)),
                    );
                  }

                  final data = (snapshot.data?.snapshot.value as Map?) ?? {};
                  final myCourses = <String>[];
                  data.forEach((courseId, members) {
                    if ((members as Map).containsKey(uid)) {
                      myCourses.add(courseId);
                    }
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

                          return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFF00C68E),
                                child:
                                Icon(Icons.school, color: Colors.white),
                              ),
                              title: Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                'Course Code: $code',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: Colors.grey,
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

            const SizedBox(height: 12),
            const Divider(thickness: 1),
            const SizedBox(height: 12),

            const Text(
              'Your Recent Questions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF009B8F),
              ),
            ),
            Expanded(
              flex: 1,
              child: StreamBuilder(
                stream: db.child('userQuestions/$uid').onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF00C68E)),
                    );
                  }

                  final data = (snapshot.data?.snapshot.value as Map?) ?? {};
                  if (data.isEmpty) {
                    return Center(
                      child: Text(
                        'No questions yet.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    );
                  }

                  final items = data.entries.toList();
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final q = items[i];
                      final questionText = (q.value as Map)['question'] ?? 'No question text';
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF009B8F),
                            child: Icon(Icons.question_answer,
                                color: Colors.white),
                          ),
                          title: Text(
                            'Question ${q.key}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            questionText.toString(),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: "Class Whisperer",
      applicationVersion: "1.0.0",
      applicationLegalese: "© 2025 Dhruv Parmar. All rights reserved.",
      children: const [
        Text("A classroom assistant built with Flutter."),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Help & Support"),
        content: const Text(
          "For any technical issues or feedback, please contact:\n\n📧 support@classwhisperer.app",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
