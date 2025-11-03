import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/bloc/auth_bloc.dart';
import '../../../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthSignedIn) {
            final user = FirebaseAuth.instance.currentUser;

            if (user != null && !user.emailVerified) {
              await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Verify Your Email"),
                  content: Text(
                    "Your email (${user.email}) is not verified yet.\n\n"
                        "Please check your inbox for a verification link.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        await user.sendEmailVerification();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "📧 Verification email sent again to ${user.email}"),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text("Resend Email"),
                    ),
                    TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pop(context);
                      },
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
              return;
            }

            // ✅ Verified → go to dashboard
            Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
          }

          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00C68E), Color(0xFF009B8F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.school_rounded,
                          color: Colors.white, size: 90),
                      const SizedBox(height: 10),
                      const Text(
                        "Class Whisperer",
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Card
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        constraints: const BoxConstraints(maxWidth: 420),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                "Welcome back!",
                                style: TextStyle(
                                  fontSize: 30,
                                  color: Color(0xFF009B8F),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            TextField(
                              controller: _email,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.email_outlined),
                                hintText: "Email",
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            TextField(
                              controller: _password,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outline),
                                hintText: "Password",
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Sign In Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00C68E),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: state is AuthLoading
                                    ? null
                                    : () async {
                                  context.read<AuthBloc>().add(
                                    AuthSignInEmail(
                                      _email.text.trim(),
                                      _password.text.trim(),
                                    ),
                                  );

                                  // 🛡️ Safety fallback if Bloc doesn't emit
                                  await Future.delayed(
                                      const Duration(seconds: 2));
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user != null &&
                                      user.emailVerified &&
                                      mounted) {
                                    Navigator.pushReplacementNamed(
                                        context, AppRoutes.dashboard);
                                  }
                                },
                                child: state is AuthLoading
                                    ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                    : const Text(
                                  "Sign In",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Forgot Password
                            Center(
                              child: TextButton(
                                onPressed: () async {
                                  if (_email.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Enter your email to reset password."),
                                      ),
                                    );
                                    return;
                                  }
                                  try {
                                    await FirebaseAuth.instance
                                        .sendPasswordResetEmail(
                                        email: _email.text.trim());
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Password reset link sent to ${_email.text.trim()}"),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Error sending reset email: $e")),
                                    );
                                  }
                                },
                                child: const Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: Color(0xFF009B8F),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),
                            Center(
                              child: TextButton(
                                onPressed: () => Navigator.pushNamed(
                                    context, AppRoutes.register),
                                child: const Text(
                                  "Don't have an account? Sign Up",
                                  style: TextStyle(
                                    color: Color(0xFF009B8F),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
