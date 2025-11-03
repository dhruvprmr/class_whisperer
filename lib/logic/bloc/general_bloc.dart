import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../data/repositories/rtdb_repository.dart';
part 'general_event.dart';
part 'general_state.dart';

class GeneralBloc extends Bloc<GeneralEvent, GeneralState> {
  final RTDBRepo repo;
  Stream<DatabaseEvent>? _sub;
  GeneralBloc(this.repo) : super(GeneralInitial()) {
    on<GeneralWatch>((e, emit) async {
      emit(GeneralLoading());
      _sub?.drain();
      _sub = repo.generalRef(e.courseId).onValue;
      await emit.forEach<DatabaseEvent>(_sub!, onData: (ev) {
        final data = ev.snapshot.value as Map<Object?, Object?>?;
        return GeneralLoaded(data ?? {});
      }, onError: (err, _) => GeneralError(err.toString()));
    });
    on<GeneralAsk>((e, emit) async { try { await repo.askGeneral(e.courseId, e.text, e.uid); } catch (err) { emit(GeneralError(err.toString())); } });
    on<GeneralUpvote>((e, emit) async { try { await repo.upvoteGeneral(e.courseId, e.qid, e.uid); } catch (err) { emit(GeneralError(err.toString())); } });
    on<GeneralAnswer>((e, emit) async { try { await repo.answerGeneral(e.courseId, e.qid, e.text, e.uid); } catch (err) { emit(GeneralError(err.toString())); } });
  }
}
