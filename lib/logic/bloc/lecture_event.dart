part of 'lecture_bloc.dart';
abstract class LectureEvent extends Equatable { @override List<Object?> get props => []; }
class LectureWatch extends LectureEvent { final String courseId; final String lectureId; LectureWatch(this.courseId, this.lectureId); }
class LectureAsk extends LectureEvent { final String courseId; final String lectureId; final String text; final String uid; LectureAsk(this.courseId, this.lectureId, this.text, this.uid); }
class LectureUpvote extends LectureEvent { final String courseId; final String lectureId; final String qid; final String uid; LectureUpvote(this.courseId, this.lectureId, this.qid, this.uid); }
class LectureAnswer extends LectureEvent { final String courseId; final String lectureId; final String qid; final String text; final String uid; LectureAnswer(this.courseId, this.lectureId, this.qid, this.text, this.uid); }
