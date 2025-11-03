import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/rtdb_repository.dart';
import '../../../logic/bloc/general_bloc.dart';
import '../../../logic/bloc/lecture_bloc.dart';
import '../../widgets/question_tile.dart';
import '../../../routes/app_routes.dart';

class CourseHomeScreen extends StatefulWidget { const CourseHomeScreen({super.key}); @override State<CourseHomeScreen> createState() => _CourseHomeScreenState(); }

class _CourseHomeScreenState extends State<CourseHomeScreen> {
  late String courseId;
  final askGeneralCtrl = TextEditingController();
  final answerCtrl = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    courseId = ModalRoute.of(context)!.settings.arguments as String;
    context.read<GeneralBloc>().add(GeneralWatch(courseId));
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Course: $courseId'),
          bottom: const TabBar(tabs: [Tab(text: 'General'), Tab(text: 'Lectures')]),
        ),
        body: TabBarView(children: [
          // ---------- General ----------
          Column(children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(children: [
                Expanded(child: TextField(controller: askGeneralCtrl, decoration: const InputDecoration(hintText: 'Ask general question...', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    final text = askGeneralCtrl.text.trim();
                    if (text.isEmpty) return;
                    context.read<GeneralBloc>().add(GeneralAsk(courseId, text, uid));
                    askGeneralCtrl.clear();
                  },
                  child: const Text('Send'),
                ),
              ]),
            ),
            Expanded(
              child: BlocBuilder<GeneralBloc, GeneralState>(
                builder: (context, state) {
                  if (state is GeneralLoading) return const Center(child: CircularProgressIndicator());
                  if (state is GeneralLoaded) {
                    final map = state.data.map((k,v)=>MapEntry(k as String, v));
                    if (map.isEmpty) return const Center(child: Text('No general questions yet.'));
                    final entries = map.entries.toList();
                    entries.sort((a,b) {
                      final au = (a.value as Map)['upvotes'] ?? 0;
                      final bu = (b.value as Map)['upvotes'] ?? 0;
                      return (bu as int).compareTo(au as int);
                    });
                    return ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (_, i) {
                        final e = entries[i];
                        return QuestionTileRTDB(
                          id: e.key,
                          data: e.value as Map,
                          onUpvote: () => context.read<GeneralBloc>().add(GeneralUpvote(courseId, e.key, uid)),
                          onAnswer: () async {
                            final text = await _askAnswer(context);
                            if (text != null && text.trim().isNotEmpty) {
                              context.read<GeneralBloc>().add(GeneralAnswer(courseId, e.key, text.trim(), uid));
                            }
                          },
                        );
                      },
                    );
                  }
                  if (state is GeneralError) return Center(child: Text('Error: ${state.message}'));
                  return const SizedBox.shrink();
                },
              ),
            ),
          ]),

          // ---------- Lectures ----------
          _LecturesTab(courseId: courseId),
        ]),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.createLecture, arguments: courseId),
          icon: const Icon(Icons.play_circle_outline),
          label: const Text('New Lecture (Instructor)'),
        ),
      ),
    );
  }

  Future<String?> _askAnswer(BuildContext context) async {
    final ctrl = TextEditingController();
    return showDialog<String>(context: context, builder: (ctx) {
      return AlertDialog(
        title: const Text('Your Answer'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Type your answer')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('Submit')),
        ],
      );
    });
  }
}

class _LecturesTab extends StatelessWidget {
  final String courseId;
  const _LecturesTab({required this.courseId});

  @override
  Widget build(BuildContext context) {
    final repo = RTDBRepo();
    return StreamBuilder(
      stream: repo.lecturesRef(courseId).onValue,
      builder: (context, snap) {
        final data = (snap.data?.snapshot.value as Map?) ?? {};
        if (data.isEmpty) return const Center(child: Text('No lectures yet.'));
        final entries = data.entries.toList().map((e)=>MapEntry(e.key as String, e.value as Map)).toList();
        entries.sort((a,b)=>((b.value['createdAt'] ?? 0) as int).compareTo((a.value['createdAt'] ?? 0) as int));
        return ListView.builder(
          itemCount: entries.length,
          itemBuilder: (_, i) {
            final e = entries[i];
            final active = e.value['active'] == true;
            return ListTile(
              leading: Icon(active ? Icons.wifi_tethering : Icons.stop_circle_outlined),
              title: Text('${e.value['title'] ?? 'Lecture'}'),
              subtitle: Text(active ? 'Active' : 'Ended'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.lectureQnA, arguments: {'courseId': courseId, 'lectureId': e.key}),
            );
          },
        );
      },
    );
  }
}
