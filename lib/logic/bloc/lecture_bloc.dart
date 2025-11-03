import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../data/repositories/rtdb_repository.dart';
part 'lecture_event.dart';
part 'lecture_state.dart';

class LectureBloc extends Bloc<LectureEvent, LectureState> {
  final RTDBRepo repo;
  Stream<DatabaseEvent>? _sub;
  LectureBloc(this.repo) : super(LectureInitial()) {
    on<LectureWatch>((e, emit) async {
      emit(LectureLoading());
      _sub?.drain();
      _sub = repo.lectureQsRef(e.courseId, e.lectureId).onValue;
      await emit.forEach<DatabaseEvent>(_sub!, onData: (ev) {
        final data = ev.snapshot.value as Map<Object?, Object?>?;
        return LectureLoaded(data ?? {});
      }, onError: (err, _) => LectureError(err.toString()));
    });
    on<LectureAsk>((e, emit) async { try { await repo.askLecture(e.courseId, e.lectureId, e.text, e.uid); } catch (err) { emit(LectureError(err.toString())); } });
    on<LectureUpvote>((e, emit) async { try { await repo.upvoteLecture(e.courseId, e.lectureId, e.qid, e.uid); } catch (err) { emit(LectureError(err.toString())); } });
    on<LectureAnswer>((e, emit) async { try { await repo.answerLecture(e.courseId, e.lectureId, e.qid, e.text, e.uid); } catch (err) { emit(LectureError(err.toString())); } });
  }
}
