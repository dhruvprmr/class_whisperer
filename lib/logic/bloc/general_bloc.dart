import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../data/repositories/rtdb_repository.dart';

part 'general_event.dart';
part 'general_state.dart';

class GeneralBloc extends Bloc<GeneralEvent, GeneralState> {
  final RTDBRepo repo;
  StreamSubscription<DatabaseEvent>? _subscription;

  GeneralBloc(this.repo) : super(GeneralInitial()) {
    on<GeneralWatch>(_onGeneralWatch);
    on<GeneralAsk>(_onGeneralAsk);
    on<GeneralUpvote>(_onGeneralUpvote);
    on<GeneralAnswer>(_onGeneralAnswer);
  }

  Future<void> _onGeneralWatch(
      GeneralWatch event, Emitter<GeneralState> emit) async {
    emit(GeneralLoading());

    // Cancel any existing subscription
    await _subscription?.cancel();

    // Get RTDB stream
    final stream = repo.generalRef(event.courseId).onValue;

    // Transform the RTDB stream into a state stream
    final stateStream = stream.map<GeneralState>((DatabaseEvent ev) {
      final data = ev.snapshot.value as Map<Object?, Object?>?;
      return GeneralLoaded(data ?? {});
    }).handleError((error) {
      return GeneralError(error.toString());
    });

    // Add the transformed stream safely to the bloc
    await emit.forEach<GeneralState>(
      stateStream,
      onData: (state) => state,
      onError: (_, __) => GeneralError(_.toString()),
    );
  }

  Future<void> _onGeneralAsk(
      GeneralAsk event, Emitter<GeneralState> emit) async {
    try {
      await repo.askGeneral(event.courseId, event.text, event.uid);
    } catch (err) {
      if (!emit.isDone) emit(GeneralError(err.toString()));
    }
  }

  Future<void> _onGeneralUpvote(
      GeneralUpvote event, Emitter<GeneralState> emit) async {
    try {
      await repo.upvoteGeneral(event.courseId, event.qid, event.uid);
    } catch (err) {
      if (!emit.isDone) emit(GeneralError(err.toString()));
    }
  }

  Future<void> _onGeneralAnswer(
      GeneralAnswer event, Emitter<GeneralState> emit) async {
    try {
      await repo.answerGeneral(event.courseId, event.qid, event.text, event.uid);
    } catch (err) {
      if (!emit.isDone) emit(GeneralError(err.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
