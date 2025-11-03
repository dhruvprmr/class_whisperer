import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool compactCards = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00C68E),
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader('General'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  value: notifications,
                  onChanged: (v) => setState(() => notifications = v),
                  title: const Text('Notifications'),
                  subtitle: const Text('Receive reminders and updates'),
                ),
                const Divider(height: 0),
                SwitchListTile.adaptive(
                  value: compactCards,
                  onChanged: (v) => setState(() => compactCards = v),
                  title: const Text('Compact cards'),
                  subtitle: const Text('Show denser lists on dashboard'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionHeader('Appearance'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.color_lens_outlined, color: Color(0xFF009B8F)),
              title: const Text('Theme'),
              subtitle: const Text('Follows system (light/dark)'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('TODO: hook into app theme provider')),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _sectionHeader('Privacy'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.privacy_tip_outlined, color: Color(0xFF009B8F)),
              title: const Text('Privacy policy'),
              subtitle: const Text('How we store anonymous participation data'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Privacy'),
                    content: const Text(
                      'Class Whisperer stores anonymous display names in the database '
                          'and keeps your Firebase UID for accountability. Only admins can '
                          'see UIDs for flagged content.',
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        letterSpacing: 0.3,
        fontWeight: FontWeight.w700,
        color: Color(0xFF009B8F),
      ),
    ),
  );
}
