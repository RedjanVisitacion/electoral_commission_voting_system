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
      throw Exception(e.message ?? 'Failed to create account');
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
      throw Exception(e.message ?? 'Failed to login');
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
      throw Exception(e.message ?? 'Failed to create account');
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
      throw Exception(e.message ?? 'Failed to login');
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
}
