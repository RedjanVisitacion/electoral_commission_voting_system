import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_project/auth/login_screen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyBEm3vkiHXXjfFB3AVA1hUkDNp3brfq7Jg",
      authDomain: "flutter-project-55b51.firebaseapp.com",
      projectId: "flutter-project-55b51",
      storageBucket: "flutter-project-55b51.appspot.com",
      messagingSenderId: "56355879413",
      appId: "1:56355879413:web:ed1567abaaf497c83108bc",
      measurementId: "G-QB4X7JBRD4",
    ),
  );
  

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
