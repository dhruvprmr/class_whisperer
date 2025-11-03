import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../data/repositories/rtdb_repository.dart';
part 'lecture_event.dart';
part 'lecture_state.dart';

class LectureBloc extends Bloc<LectureEvent, LectureState> {
  final RTDBRepo repo;

  LectureBloc(this.repo) : super(LectureInitial()) {
    on<LectureWatch>(_onLectureWatch);
    on<LectureAsk>(_onLectureAsk);
    on<LectureUpvote>(_onLectureUpvote);
    on<LectureAnswer>(_onLectureAnswer);
  }

  Future<void> _onLectureWatch(LectureWatch e, Emitter<LectureState> emit) async {
    emit(LectureLoading());

    final stream = repo
        .lectureQsRef(e.courseId, e.lectureId)
        .onValue
        .map((ev) {
          final data = ev.snapshot.value as Map<Object?, Object?>?;
          return LectureLoaded(data ?? {});
        })
        .handleError((err) => LectureError(err.toString()));

    await emit.forEach<LectureState>(
      stream,
      onData: (state) => state,
      onError: (_, __) => LectureError(_.toString()),
    );
  }

  Future<void> _onLectureAsk(LectureAsk e, Emitter<LectureState> emit) async {
    try {
      await repo.askLecture(e.courseId, e.lectureId, e.text, e.uid);
    } catch (err) {
      emit(LectureError(err.toString()));
    }
  }

  Future<void> _onLectureUpvote(LectureUpvote e, Emitter<LectureState> emit) async {
    try {
      await repo.upvoteLecture(e.courseId, e.lectureId, e.qid, e.uid);
    } catch (err) {
      emit(LectureError(err.toString()));
    }
  }

  Future<void> _onLectureAnswer(LectureAnswer e, Emitter<LectureState> emit) async {
    try {
      await repo.answerLecture(e.courseId, e.lectureId, e.qid, e.text, e.uid);
    } catch (err) {
      emit(LectureError(err.toString()));
    }
  }
}
