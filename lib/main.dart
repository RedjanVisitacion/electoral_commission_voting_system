import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_project/auth/login_screen.dart';
import 'package:flutter_project/services/user_service.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  const options = FirebaseOptions(
      apiKey: "AIzaSyBEm3vkiHXXjfFB3AVA1hUkDNp3brfq7Jg",
      authDomain: "flutter-project-55b51.firebaseapp.com",
      projectId: "flutter-project-55b51",
      storageBucket: "flutter-project-55b51.appspot.com",
      messagingSenderId: "56355879413",
      appId: "1:56355879413:web:ed1567abaaf497c83108bc",
      measurementId: "G-QB4X7JBRD4",
  );

  await Firebase.initializeApp(options: options);

  await _ensureDefaultAdmin(options);
  

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: LoginScreen());
  }
}

Future<void> _ensureDefaultAdmin(FirebaseOptions options) async {
  const studentId = '2023304637';
  const name = 'Redjan Phil';
  const password = '12345678';
  final email = '$studentId@ustp.edu.ph';

  FirebaseApp sec;
  try {
    sec = Firebase.app('bootstrap');
  } catch (_) {
    sec = await Firebase.initializeApp(name: 'bootstrap', options: options);
  }
  final secAuth = FirebaseAuth.instanceFor(app: sec);

  String uid;
  try {
    final cred = await secAuth.signInWithEmailAndPassword(email: email, password: password);
    uid = cred.user!.uid;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      final cred = await secAuth.createUserWithEmailAndPassword(email: email, password: password);
      uid = cred.user!.uid;
    } else {
      return; // don't block startup on other errors
    }
  }

  try {
    await UserService().upsertUser(uid: uid, name: name, studentId: studentId);
    await UserService().setUserRole(uid: uid, role: 'admin');
  } catch (_) {}

  try {
    await secAuth.signOut();
  } catch (_) {}
}
