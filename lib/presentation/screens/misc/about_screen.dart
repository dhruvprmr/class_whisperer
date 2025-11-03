import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00C68E),
        title: const Text('About Us', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: const [
              CircleAvatar(
                radius: 26,
                backgroundColor: Color(0xFF00C68E),
                child: Icon(Icons.school, color: Colors.white, size: 28),
              ),
              SizedBox(width: 12),
              Text('Class Whisperer',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 12),
            Text(
              'An equitable classroom engagement tool that lets students ask anonymous questions, '
                  'upvote others, and share feedback in real time. Built with Flutter + Firebase.',
              style: TextStyle(color: Colors.grey.shade800, height: 1.35),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.info_outline, color: Color(0xFF009B8F)),
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.policy_outlined, color: Color(0xFF009B8F)),
                title: const Text('License & Credits'),
                subtitle: const Text('© 2025 Class Whisperer. All rights reserved.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
