part of 'lecture_bloc.dart';

abstract class LectureState extends Equatable {
  const LectureState();

  @override
  List<Object?> get props => [];
}

class LectureInitial extends LectureState {
  const LectureInitial();
}

class LectureLoading extends LectureState {
  const LectureLoading();
}

class LectureLoaded extends LectureState {
  final Map<Object?, Object?> data;
  const LectureLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class LectureError extends LectureState {
  final String message;
  const LectureError(this.message);

  @override
  List<Object?> get props => [message];
}
