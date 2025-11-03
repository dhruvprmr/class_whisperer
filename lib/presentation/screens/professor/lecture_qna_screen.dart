import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/bloc/lecture_bloc.dart';

class LectureQnAScreen extends StatefulWidget {
  const LectureQnAScreen({super.key});

  @override
  State<LectureQnAScreen> createState() => _LectureQnAScreenState();
}

class _LectureQnAScreenState extends State<LectureQnAScreen> {
  late String courseId;
  late String lectureId;
  final askCtrl = TextEditingController();
  String? expandedId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    courseId = args['courseId'];
    lectureId = args['lectureId'];
    context.read<LectureBloc>().add(LectureWatch(courseId, lectureId));
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F7),
      body: Stack(
        children: [
          // Gradient Header
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
              // Top AppBar Style
              SafeArea(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Lecture: $lectureId",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Body content container
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
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Expanded(
                        child: BlocBuilder<LectureBloc, LectureState>(
                          builder: (context, state) {
                            if (state is LectureLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (state is LectureLoaded) {
                              final map = state.data
                                  .map((k, v) => MapEntry(k as String, v));
                              if (map.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No questions yet 🤔',
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 16),
                                  ),
                                );
                              }

                              final entries = map.entries.toList()
                                ..sort((a, b) {
                                  final au = (a.value as Map)['upvotes'] ?? 0;
                                  final bu = (b.value as Map)['upvotes'] ?? 0;
                                  return (bu as int).compareTo(au as int);
                                });

                              return ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: entries.length,
                                itemBuilder: (_, i) {
                                  final e = entries[i];
                                  final data = e.value as Map;
                                  final question = data['text'] ?? 'Question';
                                  final upvotes = data['upvotes'] ?? 0;
                                  final answers =
                                      (data['answers'] as Map?) ?? {};
                                  final isExpanded = expandedId == e.key;

                                  return AnimatedContainer(
                                    duration:
                                    const Duration(milliseconds: 250),
                                    margin:
                                    const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                      border: Border.all(
                                          color: const Color(0xFFE0F4EF)),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(18),
                                      onTap: () {
                                        setState(() {
                                          expandedId =
                                          isExpanded ? null : e.key;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color:
                                                    const Color(0xFF00C68E)
                                                        .withOpacity(0.1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  padding:
                                                  const EdgeInsets.all(10),
                                                  child: const Icon(
                                                      Icons.help_outline,
                                                      color: Color(0xFF009B8F),
                                                      size: 22),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    question,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                      FontWeight.w600,
                                                      fontSize: 16,
                                                      color: Color(0xFF002B27),
                                                    ),
                                                  ),
                                                ),

                                                // Upvote Button 💚
                                                GestureDetector(
                                                  onTap: () {
                                                    context
                                                        .read<LectureBloc>()
                                                        .add(LectureUpvote(
                                                        courseId,
                                                        lectureId,
                                                        e.key,
                                                        uid));
                                                  },
                                                  child: AnimatedContainer(
                                                    duration: const Duration(
                                                        milliseconds: 250),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFF00C68E)
                                                          .withOpacity(0.08),
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          20),
                                                      border: Border.all(
                                                          color: const Color(
                                                              0xFF00C68E)
                                                              .withOpacity(
                                                              0.3)),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.thumb_up_alt_rounded,
                                                          size: 18,
                                                          color:
                                                          Color(0xFF009B8F),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '$upvotes',
                                                          style: const TextStyle(
                                                              color: Color(
                                                                  0xFF009B8F),
                                                              fontWeight:
                                                              FontWeight
                                                                  .w500),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(width: 6),
                                                Icon(
                                                  isExpanded
                                                      ? Icons
                                                      .expand_less_rounded
                                                      : Icons
                                                      .expand_more_rounded,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 6),
                                            Text(
                                              "${answers.length} answers",
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 13,
                                              ),
                                            ),

                                            if (isExpanded) ...[
                                              const SizedBox(height: 10),
                                              const Divider(thickness: 0.8),
                                              if (answers.isEmpty)
                                                const Padding(
                                                  padding: EdgeInsets.all(8),
                                                  child: Text(
                                                    'No answers yet.',
                                                    style: TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 14),
                                                  ),
                                                )
                                              else
                                                ...answers.entries.map((a) {
                                                  final val = a.value as Map;
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 6,
                                                        horizontal: 4),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        const Icon(
                                                            Icons
                                                                .subdirectory_arrow_right,
                                                            color: Color(
                                                                0xFF009B8F),
                                                            size: 18),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            val['text'] ?? '',
                                                            style:
                                                            const TextStyle(
                                                                color: Colors
                                                                    .black87,
                                                                fontSize:
                                                                15),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                              const SizedBox(height: 8),
                                              Align(
                                                alignment:
                                                Alignment.centerRight,
                                                child: TextButton.icon(
                                                  onPressed: () async {
                                                    final ctrl =
                                                    TextEditingController();
                                                    final ans =
                                                    await showDialog<String>(
                                                      context: context,
                                                      builder: (ctx) =>
                                                          AlertDialog(
                                                            title: const Text(
                                                                'Your Answer'),
                                                            content: TextField(
                                                              controller: ctrl,
                                                              decoration:
                                                              const InputDecoration(
                                                                hintText:
                                                                'Type your answer...',
                                                                border:
                                                                OutlineInputBorder(),
                                                              ),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          ctx),
                                                                  child: const Text(
                                                                      'Cancel')),
                                                              ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                  const Color(
                                                                      0xFF00C68E),
                                                                ),
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        ctx,
                                                                        ctrl.text
                                                                            .trim()),
                                                                child: const Text(
                                                                    'Submit',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white)),
                                                              ),
                                                            ],
                                                          ),
                                                    );
                                                    if (ans != null &&
                                                        ans.isNotEmpty) {
                                                      context
                                                          .read<LectureBloc>()
                                                          .add(LectureAnswer(
                                                          courseId,
                                                          lectureId,
                                                          e.key,
                                                          ans,
                                                          uid));
                                                    }
                                                  },
                                                  icon: const Icon(
                                                      Icons.add_comment_rounded),
                                                  label:
                                                  const Text("Add Answer"),
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                    const Color(0xFF009B8F),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }

                            if (state is LectureError) {
                              return Center(
                                  child: Text('Error: ${state.message}',
                                      style:
                                      const TextStyle(color: Colors.red)));
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      _buildInputBar(context, uid),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, String uid) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: askCtrl,
                decoration: InputDecoration(
                  hintText: "Ask a question...",
                  prefixIcon: const Icon(Icons.question_answer_outlined,
                      color: Color(0xFF009B8F)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C68E),
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
              ),
              onPressed: () {
                final text = askCtrl.text.trim();
                if (text.isEmpty) return;
                context
                    .read<LectureBloc>()
                    .add(LectureAsk(courseId, lectureId, text, uid));
                askCtrl.clear();
              },
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
