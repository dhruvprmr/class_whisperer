import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/bloc/auth_bloc.dart';
import '../../../data/repositories/rtdb_repository.dart';
import '../../../routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final realName = TextEditingController();
  final anonName = TextEditingController();
  final bannerId = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school_rounded, size: 90, color: Colors.white),
                  const SizedBox(height: 10),
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // White container
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    constraints: const BoxConstraints(maxWidth: 480),
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
                            "hello!",
                            style: TextStyle(
                              fontSize: 30,
                              color: Color(0xFF009B8F),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildTextField(realName, Icons.person_outline, "Real Name"),
                        const SizedBox(height: 16),
                        _buildTextField(anonName, Icons.visibility_off_outlined, "Anonymous Display Name"),
                        const SizedBox(height: 16),
                        _buildTextField(bannerId, Icons.badge_outlined, "Banner ID"),
                        const SizedBox(height: 16),
                        _buildTextField(email, Icons.email_outlined, "Email", type: TextInputType.emailAddress),
                        const SizedBox(height: 16),

                        TextField(
                          controller: password,
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
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C68E),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onPressed: loading ? null : _registerAndVerifyEmail,
                            child: loading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              "Create Account",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Already have an account? Sign In",
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon, String hint,
      {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _registerAndVerifyEmail() async {
    setState(() => loading = true);
    try {
      // Create Firebase user
      await context.read<AuthBloc>().auth.registerWithEmail(
        email.text.trim(),
        password.text,
      );

      await Future.delayed(const Duration(seconds: 1));
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) throw Exception("Registration failed. Try again.");

      // Send verification email
      if (!user.emailVerified) {
        await user.sendEmailVerification();
        print("📧 Verification email sent to ${user.email}");
      }

      // Save user info to RTDB
      final repo = RTDBRepo();
      await repo.saveUser(user.uid, {
        'realName': realName.text.trim(),
        'anonName': anonName.text.trim(),
        'bannerId': bannerId.text.trim(),
        'email': email.text.trim(),
        'verified': false,
        'role': 'student',
      });

      // Show dialog
      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Verify Your Email"),
            content: Text(
              "A verification link has been sent to ${user.email}. "
                  "Please verify your email before logging in.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // go back to login
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ $e")),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
}
