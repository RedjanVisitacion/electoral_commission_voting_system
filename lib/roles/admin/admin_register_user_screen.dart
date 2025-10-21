import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/services/user_service.dart';
import 'package:flutter_project/widgets/textfield.dart';

class AdminRegisterUserScreen extends StatefulWidget {
  const AdminRegisterUserScreen({super.key});

  @override
  State<AdminRegisterUserScreen> createState() => _AdminRegisterUserScreenState();
}

class _AdminRegisterUserScreenState extends State<AdminRegisterUserScreen> {
  final _name = TextEditingController();
  final _studentId = TextEditingController();
  final _password = TextEditingController();
  String? _department; // IT, BFPT, BTLED, EDUCATION
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _studentId.dispose();
    _password.dispose();
    super.dispose();
  }

  String _idToEmail(String studentId) => "$studentId@ustp.edu.ph";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register User')),
      body: Center(
        child: SizedBox(
          width: 340,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Name', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 6),
              CustomTextField(hint: 'Enter name', label: 'Name', controller: _name),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Student ID', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 6),
              CustomTextField(hint: 'Enter student ID', label: 'Student ID', controller: _studentId),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Department', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _department,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Select department'),
                items: const [
                  DropdownMenuItem(value: 'IT', child: Text('IT')),
                  DropdownMenuItem(value: 'BFPT', child: Text('BFPT')),
                  DropdownMenuItem(value: 'BTLED', child: Text('BTLED')),
                ],
                onChanged: (v) => setState(() => _department = v),
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Password', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 6),
              CustomTextField(hint: 'Enter password', label: 'Password', controller: _password, isPassword: true),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  child: const Text('Create User'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<FirebaseApp> _getSecondaryApp() async {
    try {
      return Firebase.app('adminReg');
    } catch (_) {
      return Firebase.initializeApp(
        name: 'adminReg',
        options: const FirebaseOptions(
          apiKey: "AIzaSyBEm3vkiHXXjfFB3AVA1hUkDNp3brfq7Jg",
          authDomain: "flutter-project-55b51.firebaseapp.com",
          projectId: "flutter-project-55b51",
          storageBucket: "flutter-project-55b51.appspot.com",
          messagingSenderId: "56355879413",
          appId: "1:56355879413:web:ed1567abaaf497c83108bc",
          measurementId: "G-QB4X7JBRD4",
        ),
      );
    }
  }

  Future<void> _register() async {
    final name = _name.text.trim();
    final id = _studentId.text.trim();
    final pass = _password.text.trim();
    if (name.isEmpty || id.isEmpty || pass.length < 6 || _department == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill out name, student ID, department, and 6+ char password')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final secApp = await _getSecondaryApp();
      final secAuth = FirebaseAuth.instanceFor(app: secApp);

      try {
        // Prefer create; if already exists, handle gracefully.
        final cred = await secAuth.createUserWithEmailAndPassword(
          email: _idToEmail(id),
          password: pass,
        );
        final uid = cred.user!.uid;
        try {
          await cred.user!.updateDisplayName(name);
        } catch (_) {}
        await UserService().upsertUser(uid: uid, name: name, studentId: id, departmentId: _department);
        await UserService().setUserRole(uid: uid, role: 'student', departmentId: _department);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User registered')),
        );
        Navigator.pop(context);
        return;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
          // User exists in Auth with an unknown password. Try to find uid via Firestore then update profile/role.
          final uid = await UserService().findUidByStudentId(id);
          if (uid != null) {
            await UserService().upsertUser(uid: uid, name: name, studentId: id, departmentId: _department);
            await UserService().setUserRole(uid: uid, role: 'student', departmentId: _department);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User exists. Profile updated; password unchanged.')),
            );
            Navigator.pop(context);
            return;
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User exists in Auth. Password cannot be changed here. Delete user in Firebase Auth to re-register.')),
            );
            return;
          }
        }
        rethrow;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
