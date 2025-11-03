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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white),
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

              // White curved container
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(36)),
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
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      final rawData =
                          (snap.data?.snapshot.value as Map?) ?? {};
                      final data = Map.from(rawData)
                        ..removeWhere((key, value) => value == null);

                      if (data.isEmpty) {
                        return const Center(
                          child: Text(
                            'No questions yet 🤔',
                            style: TextStyle(
                                color: Colors.black54, fontSize: 16),
                          ),
                        );
                      }

                      final items = data.entries.toList()
                        ..sort((a, b) {
                          final t1 =
                          (a.value['createdAt'] ?? 0) as int;
                          final t2 =
                          (b.value['createdAt'] ?? 0) as int;
                          return t2.compareTo(t1);
                        });

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final e = items[index];
                          final q = e.value as Map;
                          final text = q['text'] ?? 'Untitled question';
                          final path = q['path'] ?? '';
                          final courseId = path.contains('/')
                              ? path.split('/').first
                              : path;

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
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor:
                                const Color(0xFF00C68E).withOpacity(0.15),
                                child: const Icon(Icons.help_outline,
                                    color: Color(0xFF009B8F)),
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
                                "Course: $courseId",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: Colors.grey,
                              ),
                              onTap: () {
                                // Optional: Navigate to the original course
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Go to $path (implement navigation)'),
                                  ),
                                );
                              },
                            ),
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
