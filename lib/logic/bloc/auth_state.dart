part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSignedIn extends AuthState {
  final User user;
  AuthSignedIn(this.user);
}
class AuthSignedOut extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
