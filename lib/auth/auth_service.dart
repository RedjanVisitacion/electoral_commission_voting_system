import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  String _idToEmail(String studentId) => "$studentId@ustp.edu.ph";

  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      log("Auth error (signup): ${e.code} ${e.message}");
      final msg = _mapAuthCodeToMessage(e.code, isSignup: true);
      throw Exception(msg);
    } catch (e) {
      log("Something went wrong: $e");
      throw Exception('Unexpected error during signup');
    }
  }

  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      log("Auth error (login): ${e.code} ${e.message}");
      final msg = _mapAuthCodeToMessage(e.code);
      throw Exception(msg);
    } catch (e) {
      log("Something went wrong: $e");
      throw Exception('Unexpected error during login');
    }
  }

  Future<User?> createUserWithStudentId(String studentId, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: _idToEmail(studentId), password: password);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      log("Auth error (signup-id): ${e.code} ${e.message}");
      final msg = _mapAuthCodeToMessage(e.code, isSignup: true);
      throw Exception(msg);
    } catch (e) {
      log("Something went wrong: $e");
      throw Exception('Unexpected error during signup');
    }
  }

  Future<User?> loginUserWithStudentId(String studentId, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: _idToEmail(studentId), password: password);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      log("Auth error (login-id): ${e.code} ${e.message}");
      final msg = _mapAuthCodeToMessage(e.code);
      throw Exception(msg);
    } catch (e) {
      log("Something went wrong: $e");
      throw Exception('Unexpected error during login');
    }
  }

  Future<void> signout() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      log("Auth error (signout): ${e.code} ${e.message}");
      throw Exception(e.message ?? 'Failed to sign out');
    } catch (e) {
      log("Something went wrong: $e");
      throw Exception('Unexpected error during signout');
    }
  }

  String _mapAuthCodeToMessage(String code, {bool isSignup = false}) {
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-not-found':
        return 'No account found for that Student ID.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return isSignup ? 'Account already exists for that Student ID.' : 'Account already exists.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is disabled for this project.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return isSignup ? 'Failed to create account.' : 'Failed to login.';
    }
  }
}
