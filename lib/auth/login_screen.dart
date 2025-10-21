import 'dart:developer';

import 'package:flutter_project/auth/auth_service.dart';
import 'package:flutter_project/auth/signup_screen.dart';
import 'package:flutter_project/home_screen.dart';
import 'package:flutter_project/roles/student/student_landing.dart';
import 'package:flutter_project/services/user_service.dart';
import 'package:flutter_project/roles/select_role_screen.dart';
// import 'package:flutter_project/roles/student/student_home.dart';
import 'package:flutter_project/roles/admin/admin_home.dart';
import 'package:flutter_project/widgets/button.dart';
import 'package:flutter_project/widgets/textfield.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _studentId = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    super.dispose();
    _studentId.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 260,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0E7A5F), Color(0xFF095C46)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/images/Icon-CRCL.png', height: 48),
                          const SizedBox(width: 12),
                          Text(
                            'Welcome',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Login to your account',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -40),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 18, offset: Offset(0, 8)),
                      ],
                    ),
                    
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 30),
                        CustomTextField(
                          hint: "Enter Student ID",
                          label: "Student ID",
                          controller: _studentId,
                        ),

                        SizedBox(height: 20),
                        const SizedBox(height: 16),
                        CustomTextField(
                          hint: "Enter Password",
                          label: "Password",
                          isPassword: true,
                          controller: _password,
                        ),
                        
                        SizedBox(height: 30),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0E7A5F),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                            ),
                            
                            child: const Text('Sign in'),
                          ),
                        ),
                        const SizedBox(height: 14),
                        
                        
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 0),
            ],
          ),
        ),
      ),
    );
  }

  goToSignup(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignupScreen()),
      );

  goToHome(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );

  _login() async {
    final id = _studentId.text.trim();
    final pass = _password.text.trim();

    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student ID is required')),
      );
      return;
    }
    if (pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final user = await _auth.loginUserWithStudentId(id, pass);
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed')),
        );
        return;
      }

      log("User Logged In");
      // Do not block navigation on Firestore; upsert in background
      // and try to get role with a short timeout
      UserService()
          .upsertUser(uid: user.uid, studentId: id)
          .catchError((_) {});
      var role = await UserService()
          .getUserRole(user.uid)
          .timeout(const Duration(seconds: 1), onTimeout: () => null);

      // Auto-assign role if missing: default admin vs students
      const adminId = '2023304637';
      if (role == null) {
        role = (id == adminId) ? 'admin' : 'student';
        // Set role in background; don't block navigation
        UserService().setUserRole(uid: user.uid, role: role!).catchError((_) {});
      }

      if (!mounted) return;
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminHome()),
        );
      } else if (role == 'student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentLanding()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SelectRoleScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e is Exception ? e.toString() : 'Login error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg.replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
