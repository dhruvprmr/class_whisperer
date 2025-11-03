part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthWatchRequested extends AuthEvent {}
class AuthSignInEmail extends AuthEvent {
  final String email;
  final String password;
  AuthSignInEmail(this.email, this.password);
}
class AuthRegisterEmail extends AuthEvent {
  final String email;
  final String password;
  AuthRegisterEmail(this.email, this.password);
}
class AuthSignInGoogle extends AuthEvent {}
class AuthSignOut extends AuthEvent {}
