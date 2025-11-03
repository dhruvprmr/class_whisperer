import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00C68E),
        title: const Text('Help & Support', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _faqCard(
            'How do I join a course?',
            'Open Courses → tap the + button → scan the QR or enter the course code.',
          ),
          _faqCard(
            'Are questions anonymous?',
            'Yes. Your display name is anonymous in the UI. Your UID is kept privately for abuse handling.',
          ),
          _faqCard(
            'How are sessions different from general?',
            'General is for ongoing Q&A. Lecture sessions are created by instructors and end when the class ends.',
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.email_outlined, color: Color(0xFF009B8F)),
              title: const Text('Contact support'),
              subtitle: const Text('support@classwhisperer.app'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Open your email app to contact support.')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqCard(String q, String a) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(q,
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: Color(0xFF009B8F))),
        const SizedBox(height: 6),
        Text(a),
      ]),
    ),
  );
}
