import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService auth;

  AuthBloc(this.auth) : super(AuthInitial()) {
    // Watch authentication state changes (for auto-login)
    on<AuthWatchRequested>((event, emit) async {
      await emit.forEach<User?>(
        auth.authStateChanges,
        onData: (u) => u == null ? AuthSignedOut() : AuthSignedIn(u),
      );
    });

    // 🔹 Email sign-in
    on<AuthSignInEmail>((e, emit) async {
      emit(AuthLoading());
      try {
        await auth.signInWithEmail(e.email, e.password);
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          emit(AuthSignedIn(user)); // ✅ critical: UI unlocks now
        } else {
          emit(AuthError("Sign-in failed: no user found."));
        }
      } catch (err) {
        emit(AuthError(err.toString()));
      }
    });

    // 🔹 Email registration
    on<AuthRegisterEmail>((e, emit) async {
      emit(AuthLoading());
      try {
        await auth.registerWithEmail(e.email, e.password);
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // Send verification email right after registration
          await user.sendEmailVerification();
          emit(AuthSignedIn(user));
        } else {
          emit(AuthError("Registration failed: no user created."));
        }
      } catch (err) {
        emit(AuthError(err.toString()));
      }
    });

    // 🔹 Google sign-in
    on<AuthSignInGoogle>((e, emit) async {
      emit(AuthLoading());
      try {
        await auth.signInWithGoogle();
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          emit(AuthSignedIn(user));
        } else {
          emit(AuthError("Google sign-in failed."));
        }
      } catch (err) {
        emit(AuthError(err.toString()));
      }
    });

    // 🔹 Sign-out
    on<AuthSignOut>((e, emit) async {
      await auth.signOut();
      emit(AuthSignedOut());
    });
  }
}
