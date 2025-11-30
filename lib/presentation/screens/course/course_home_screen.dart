import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/rtdb_repository.dart';
import '../../../logic/bloc/general_bloc.dart';
import '../../../routes/app_routes.dart';

class CourseHomeScreen extends StatefulWidget {
  const CourseHomeScreen({super.key});

  @override
  State<CourseHomeScreen> createState() => _CourseHomeScreenState();
}

class _CourseHomeScreenState extends State<CourseHomeScreen> {
  late String courseId;
  final askGeneralCtrl = TextEditingController();

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
        backgroundColor: const Color(0xFFF5F8F7),
        body: Stack(
          children: [
            Container(
              height: 220,
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
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Course: $courseId',
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
                        const SizedBox(height: 16),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAFDF7),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: TabBar(
                              dividerColor: Colors.transparent,
                              indicator: BoxDecoration(
                                color: const Color(0xFF00C68E),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              indicatorPadding: const EdgeInsets.all(2),
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelColor: Colors.white,
                              unselectedLabelColor: const Color(0xFF009B8F),
                              tabs: const [
                                Tab(
                                  iconMargin: EdgeInsets.only(bottom: 4),
                                  icon: Icon(Icons.chat_bubble_outline, size: 20),
                                  text: 'General',
                                ),
                                Tab(
                                  iconMargin: EdgeInsets.only(bottom: 4),
                                  icon: Icon(Icons.video_library_outlined,
                                      size: 20),
                                  text: 'Lectures',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _GeneralQnATab(courseId: courseId, uid: uid),
                              _LecturesTab(courseId: courseId),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GeneralQnATab extends StatefulWidget {
  final String courseId;
  final String uid;
  const _GeneralQnATab({required this.courseId, required this.uid});

  @override
  State<_GeneralQnATab> createState() => _GeneralQnATabState();
}

class _GeneralQnATabState extends State<_GeneralQnATab> {
  final askCtrl = TextEditingController();
  String? expandedId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocBuilder<GeneralBloc, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is GeneralLoaded) {
                final map =
                state.data.map((k, v) => MapEntry(k as String, v as Map));
                if (map.isEmpty) {
                  return const Center(
                    child: Text(
                      'No general questions yet 🤔',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                final entries = map.entries.toList()
                  ..sort((a, b) {
                    final au = a.value['upvotes'] ?? 0;
                    final bu = b.value['upvotes'] ?? 0;
                    return (bu as int).compareTo(au as int);
                  });

                return ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: entries.length,
                  itemBuilder: (_, i) {
                    final e = entries[i];
                    final data = e.value;
                    final question = data['text'] ?? 'Untitled Question';
                    final upvotes = data['upvotes'] ?? 0;
                    final answers = (data['answers'] as Map?) ?? {};

                    final isExpanded = expandedId == e.key;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(vertical: 8),
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
                        border:
                        Border.all(color: const Color(0xFFE0F4EF), width: 1),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          setState(() {
                            expandedId = isExpanded ? null : e.key;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00C68E).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    child: const Icon(Icons.help_outline,
                                        color: Color(0xFF009B8F), size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      question,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Color(0xFF002B27),
                                      ),
                                    ),
                                  ),

                                  // --- 💚 Upvote button ---
                                  GestureDetector(
                                    onTap: () {
                                      context
                                          .read<GeneralBloc>()
                                          .add(GeneralUpvote(widget.courseId, e.key, widget.uid));
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00C68E).withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: const Color(0xFF00C68E).withOpacity(0.3)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.thumb_up_alt_rounded,
                                              size: 18, color: Color(0xFF009B8F)),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${data['upvotes'] ?? 0}',
                                            style: const TextStyle(
                                              color: Color(0xFF009B8F),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 6),
                                  Icon(
                                    isExpanded
                                        ? Icons.expand_less_rounded
                                        : Icons.expand_more_rounded,
                                    color: Colors.grey.shade600,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.thumb_up_alt_outlined,
                                      size: 16, color: Colors.teal.shade700),
                                  const SizedBox(width: 4),
                                  Text('$upvotes upvotes',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.teal.shade700)),
                                  const SizedBox(width: 14),
                                  Icon(Icons.comment_outlined,
                                      size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text('${answers.length} answers',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600)),
                                ],
                              ),
                              if (isExpanded) ...[
                                const SizedBox(height: 12),
                                const Divider(thickness: 0.8),
                                if (answers.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      'No answers yet.',
                                      style: TextStyle(
                                          color: Colors.black54, fontSize: 14),
                                    ),
                                  )
                                else
                                  ...answers.entries.map((a) {
                                    final val = a.value as Map;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6, horizontal: 4),
                                      child: Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.subdirectory_arrow_right,
                                              color: Color(0xFF009B8F), size: 18),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              val['text'] ?? '',
                                              style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 15),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () async {
                                      final ctrl = TextEditingController();
                                      final ans = await showDialog<String>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Your Answer'),
                                          content: TextField(
                                            controller: ctrl,
                                            decoration: const InputDecoration(
                                                hintText: 'Type your answer'),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                const Color(0xFF00C68E),
                                              ),
                                              onPressed: () => Navigator.pop(
                                                  ctx, ctrl.text.trim()),
                                              child: const Text('Submit',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (ans != null && ans.isNotEmpty) {
                                        context.read<GeneralBloc>().add(
                                            GeneralAnswer(widget.courseId,
                                                e.key, ans, widget.uid));
                                      }
                                    },
                                    icon: const Icon(Icons.add_comment_rounded),
                                    label: const Text("Add Answer"),
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF009B8F),
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
              return const SizedBox.shrink();
            },
          ),
        ),
        SafeArea(
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
                        .read<GeneralBloc>()
                        .add(GeneralAsk(widget.courseId, text, widget.uid));
                    askCtrl.clear();
                  },
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
        if (data.isEmpty) {
          return const Center(
            child: Text('No lectures yet 🎥',
                style: TextStyle(color: Colors.black54, fontSize: 16)),
          );
        }

        final entries = data.entries
            .map((e) => MapEntry(e.key as String, e.value as Map))
            .toList()
          ..sort((a, b) =>
              ((b.value['createdAt'] ?? 0) as int)
                  .compareTo((a.value['createdAt'] ?? 0) as int));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (_, i) {
            final e = entries[i];
            final active = e.value['active'] == true;
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEAFDF7), Color(0xFFF6FFFB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                leading: CircleAvatar(
                  backgroundColor:
                  active ? const Color(0xFF00C68E) : Colors.grey.shade300,
                  child: Icon(
                    active
                        ? Icons.wifi_tethering
                        : Icons.play_circle_outline,
                    color: active ? Colors.white : Colors.grey.shade600,
                  ),
                ),
                title: Text(
                  '${e.value['title'] ?? 'Lecture'}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: active
                        ? const Color(0xFF009B8F)
                        : Colors.grey.shade700,
                  ),
                ),
                subtitle: Text(
                  active ? 'Live now' : 'Ended',
                  style: TextStyle(
                    color:
                    active ? Colors.green.shade700 : Colors.grey.shade500,
                  ),
                ),
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.lectureQnA,
                  arguments: {
                    'courseId': courseId,
                    'lectureId': e.key,
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
