import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');

  Future<String?> getUserRole(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return doc.data()?['role'] as String?;
  }

  Future<void> setUserRole({required String uid, required String role, String? email, String? name}) async {
    final data = <String, dynamic>{
      'role': role,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _users.doc(uid).set(data, SetOptions(merge: true));
  }

  Future<void> upsertUser({required String uid, String? email, String? name}) async {
    final data = <String, dynamic>{
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _users.doc(uid).set(data, SetOptions(merge: true));
  }
}
