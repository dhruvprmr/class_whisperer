part of 'general_bloc.dart';
abstract class GeneralState extends Equatable { @override List<Object?> get props => []; }
class GeneralInitial extends GeneralState {}
class GeneralLoading extends GeneralState {}
class GeneralLoaded extends GeneralState { final Map<Object?, Object?> data; GeneralLoaded(this.data); }
class GeneralError extends GeneralState { final String message; GeneralError(this.message); }
