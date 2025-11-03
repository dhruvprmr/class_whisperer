import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/bloc/lecture_bloc.dart';
import '../../widgets/question_tile.dart';

class LectureQnAScreen extends StatefulWidget { const LectureQnAScreen({super.key}); @override State<LectureQnAScreen> createState() => _LectureQnAScreenState(); }
class _LectureQnAScreenState extends State<LectureQnAScreen> {
  late String courseId;
  late String lectureId;
  final askCtrl = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    courseId = args['courseId'];
    lectureId = args['lectureId'];
    context.read<LectureBloc>().add(LectureWatch(courseId, lectureId));
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
    return Scaffold(
      appBar: AppBar(title: Text('Lecture: $lectureId')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            Expanded(child: TextField(controller: askCtrl, decoration: const InputDecoration(hintText: 'Ask lecture question...', border: OutlineInputBorder()))),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () {
                final text = askCtrl.text.trim();
                if (text.isEmpty) return;
                context.read<LectureBloc>().add(LectureAsk(courseId, lectureId, text, uid));
                askCtrl.clear();
              },
              child: const Text('Send'),
            ),
          ]),
        ),
        Expanded(
          child: BlocBuilder<LectureBloc, LectureState>(
            builder: (context, state) {
              if (state is LectureLoading) return const Center(child: CircularProgressIndicator());
              if (state is LectureLoaded) {
                final map = state.data.map((k,v)=>MapEntry(k as String, v));
                if (map.isEmpty) return const Center(child: Text('No lecture questions yet.'));
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
                      onUpvote: () => context.read<LectureBloc>().add(LectureUpvote(courseId, lectureId, e.key, uid)),
                      onAnswer: () async {
                        final text = await _askAnswer(context);
                        if (text != null && text.trim().isNotEmpty) {
                          context.read<LectureBloc>().add(LectureAnswer(courseId, lectureId, e.key, text.trim(), uid));
                        }
                      },
                    );
                  },
                );
              }
              if (state is LectureError) return Center(child: Text('Error: ${state.message}'));
              return const SizedBox.shrink();
            },
          ),
        ),
      ]),
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
