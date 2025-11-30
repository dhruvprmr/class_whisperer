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
  late String courseTitle;
  late String courseCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    courseId = args['courseId'];
    courseTitle = args['title'];
    courseCode = args['code'];

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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
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
                            "$courseCode • $courseTitle",
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
                            child: const TabBar(
                              dividerColor: Colors.transparent,
                              indicator: BoxDecoration(
                                color: Color(0xFF00C68E),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                              ),
                              indicatorPadding: EdgeInsets.all(2),
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelColor: Colors.white,
                              unselectedLabelColor: Color(0xFF009B8F),
                              tabs: [
                                Tab(
                                  icon: Icon(Icons.chat_bubble_outline,
                                      size: 20),
                                  text: 'General',
                                ),
                                Tab(
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
                              _GeneralQnATab(
                                  courseId: courseId, uid: uid),
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
                final map = state.data.map(
                        (key, value) => MapEntry(key as String, value as Map));

                if (map.isEmpty) {
                  return const Center(
                    child: Text(
                      "No general questions yet",
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
                    return bu.compareTo(au);
                  });

                return ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: entries.length,
                  itemBuilder: (_, index) {
                    final e = entries[index];
                    final data = e.value;

                    final question = data['text'] ?? "Untitled Question";
                    final upvotes = data['upvotes'] ?? 0;
                    final answers = (data['answers'] as Map?) ?? {};

                    final expanded = expandedId == e.key;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            expandedId = expanded ? null : e.key;
                          });
                        },
                        title: Text(question,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text("$upvotes upvotes"),
                            if (expanded) ...[
                              const Divider(),
                              if (answers.isEmpty)
                                const Text("No answers yet")
                              else
                                ...answers.entries.map((a) => Padding(
                                  padding:
                                  const EdgeInsets.only(bottom: 6.0),
                                  child: Text("- ${a.value['text']}"),
                                )),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  child: const Text("Add Answer"),
                                  onPressed: () async {
                                    final ctrl = TextEditingController();
                                    final ans = await showDialog<String>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text("Your Answer"),
                                        content: TextField(
                                            controller: ctrl,
                                            decoration:
                                            const InputDecoration(
                                                hintText:
                                                "Type answer")),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text("Cancel")),
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context,
                                                      ctrl.text.trim()),
                                              child: const Text("Submit"))
                                        ],
                                      ),
                                    );

                                    if (ans != null && ans.isNotEmpty) {
                                      context.read<GeneralBloc>().add(
                                          GeneralAnswer(widget.courseId,
                                              e.key, ans, widget.uid));
                                    }
                                  },
                                ),
                              )
                            ],
                          ],
                        ),
                        trailing: TextButton(
                          child: Text("$upvotes"),
                          onPressed: () {
                            context.read<GeneralBloc>().add(GeneralUpvote(
                                widget.courseId, e.key, widget.uid));
                          },
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
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: askCtrl,
                    decoration: const InputDecoration(
                      hintText: "Ask a question...",
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon:
                  const Icon(Icons.send, color: Color(0xFF009B8F)),
                  onPressed: () {
                    final text = askCtrl.text.trim();
                    if (text.isEmpty) return;
                    context.read<GeneralBloc>().add(GeneralAsk(
                        widget.courseId, text, widget.uid));
                    askCtrl.clear();
                  },
                )
              ],
            ),
          ),
        )
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
            child: Text("No lectures yet"),
          );
        }

        final entries = data.entries
            .map((e) => MapEntry(e.key, e.value as Map))
            .toList()
          ..sort((a, b) =>
              (b.value['createdAt'] ?? 0).compareTo(a.value['createdAt'] ?? 0));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (_, index) {
            final e = entries[index];
            final active = e.value['active'] == true;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor:
                active ? Colors.green : Colors.grey.shade300,
                child: Icon(
                  active ? Icons.wifi : Icons.play_circle_outline,
                  color: Colors.white,
                ),
              ),
              title: Text(e.value['title'] ?? "Lecture"),
              subtitle: Text(active ? "Live now" : "Ended"),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.lectureQnA,
                  arguments: {
                    'courseId': courseId,
                    'lectureId': e.key,
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
