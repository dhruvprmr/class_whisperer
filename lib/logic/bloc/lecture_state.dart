part of 'lecture_bloc.dart';
abstract class LectureState extends Equatable { @override List<Object?> get props => []; }
class LectureInitial extends LectureState {}
class LectureLoading extends LectureState {}
class LectureLoaded extends LectureState { final Map<Object?, Object?> data; LectureLoaded(this.data); }
class LectureError extends LectureState { final String message; LectureError(this.message); }
