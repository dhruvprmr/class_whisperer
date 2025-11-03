import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class RTDBRepo {
  final db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: "https://class-whisperer-default-rtdb.firebaseio.com/",
  ).ref();

  // Users
  Future<void> saveUser(String uid, Map<String, dynamic> data) async {
    print("📤 Attempting to save user: $uid");
    try {
      await db.child('users/$uid').set(data);
      print("✅ User saved successfully!");
    } catch (e) {
      print("❌ Failed to save user: $e");
    }
  }

  Future<Map?> getUser(String uid) async {
    final snap = await db.child('users/$uid').get();
    return snap.value as Map?;
  }

  // Courses
  Future<String> createCourse({required String title, required String code, required String adminUid}) async {
    final newRef = db.child('courses').push();
    await newRef.set({
      'title': title,
      'code': code,
      'createdBy': adminUid,
      'createdAt': ServerValue.timestamp,
    });
    await db.child('courseMembers/${newRef.key}/$adminUid').set({
      'role': 'admin',
      'joinedAt': ServerValue.timestamp,
    });
    return newRef.key!;
  }

  Future<String?> findCourseIdByCode(String code) async {
    final snap = await db.child('courses').get();
    if (!snap.exists) return null;
    for (final c in snap.children) {
      if ((c.child('code').value ?? '') == code) return c.key;
    }
    return null;
  }

  Future<void> joinCourse({required String courseId, required String uid, required String role}) async {
    await db.child('courseMembers/$courseId/$uid').set({
      'role': role,
      'joinedAt': ServerValue.timestamp,
    });
  }

  // General questions
  DatabaseReference generalRef(String courseId) => db.child('courseGeneralQuestions/$courseId');

  Future<void> askGeneral(String courseId, String text, String uid) async {
    final q = generalRef(courseId).push();
    await q.set({'text': text, 'authorUid': uid, 'upvotes': 0, 'timestamp': ServerValue.timestamp});
    await db.child('userQuestions/$uid/${q.key}').set({
      'courseId': courseId,
      'path': 'courseGeneralQuestions/$courseId/${q.key}',
      'timestamp': ServerValue.timestamp,
    });
  }

  Future<void> upvoteGeneral(String courseId, String qid, String uid) async {
    final votePath = 'courseGeneralQuestions/$courseId/$qid/votes/$uid';
    final upvotesPath = 'courseGeneralQuestions/$courseId/$qid/upvotes';
    final voteSnap = await db.child(votePath).get();
    if (voteSnap.exists) return;
    await db.update({ votePath: true });
    final curSnap = await db.child(upvotesPath).get();
    final cur = (curSnap.value ?? 0) as int;
    await db.child(upvotesPath).set(cur + 1);
  }

  Future<void> answerGeneral(String courseId, String qid, String text, String uid) async {
    await db.child('courseGeneralQuestions/$courseId/$qid/answers').push().set({
      'text': text, 'authorUid': uid, 'upvotes': 0, 'timestamp': ServerValue.timestamp,
    });
  }

  // Lectures
  DatabaseReference lecturesRef(String courseId) => db.child('lectures/$courseId');

  Future<String> createLecture(String courseId, String title) async {
    final l = lecturesRef(courseId).push();
    await l.set({'title': title, 'active': true, 'createdAt': ServerValue.timestamp});
    return l.key!;
  }

  Future<void> endLecture(String courseId, String lectureId) async {
    await db.child('lectures/$courseId/$lectureId/active').set(false);
  }

  DatabaseReference lectureQsRef(String courseId, String lectureId) =>
      db.child('lectureQuestions/$courseId/$lectureId');

  Future<void> askLecture(String courseId, String lectureId, String text, String uid) async {
    final q = lectureQsRef(courseId, lectureId).push();
    await q.set({'text': text, 'authorUid': uid, 'upvotes': 0, 'timestamp': ServerValue.timestamp});
    await db.child('userQuestions/$uid/${q.key}').set({
      'courseId': courseId,
      'lectureId': lectureId,
      'path': 'lectureQuestions/$courseId/$lectureId/${q.key}',
      'timestamp': ServerValue.timestamp,
    });
  }

  Future<void> upvoteLecture(String c, String l, String q, String uid) async {
    final votePath = 'lectureQuestions/$c/$l/$q/votes/$uid';
    final upvotesRef = db.child('lectureQuestions/$c/$l/$q/upvotes');

    // Prevent double voting
    final voteSnap = await db.child(votePath).get();
    if (voteSnap.exists) return;

    // Record user's vote
    await db.child(votePath).set(true);

    // Atomically increment upvotes and trigger real-time update
    await upvotesRef.runTransaction((currentData) {
      final cur = (currentData as int?) ?? 0;
      return Transaction.success(cur + 1);
    });
  }

  Future<void> answerLecture(String c, String l, String q, String text, String uid) async {
    await db.child('lectureQuestions/$c/$l/$q/answers').push().set({
      'text': text, 'authorUid': uid, 'upvotes': 0, 'timestamp': ServerValue.timestamp,
    });
  }
}
