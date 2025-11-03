part of 'general_bloc.dart';
abstract class GeneralEvent extends Equatable { @override List<Object?> get props => []; }
class GeneralWatch extends GeneralEvent { final String courseId; GeneralWatch(this.courseId); }
class GeneralAsk extends GeneralEvent { final String courseId; final String text; final String uid; GeneralAsk(this.courseId, this.text, this.uid); }
class GeneralUpvote extends GeneralEvent { final String courseId; final String qid; final String uid; GeneralUpvote(this.courseId, this.qid, this.uid); }
class GeneralAnswer extends GeneralEvent { final String courseId; final String qid; final String text; final String uid; GeneralAnswer(this.courseId, this.qid, this.text, this.uid); }
