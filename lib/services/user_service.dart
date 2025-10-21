import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');

  Future<String?> getUserRole(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return doc.data()?['role'] as String?;
  }

  Future<void> setUserRole({required String uid, required String role, String? email, String? name, String? studentId, String? departmentId}) async {
    final data = <String, dynamic>{
      'role': role,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (studentId != null) 'studentId': studentId,
      if (departmentId != null) 'departmentId': departmentId,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _users.doc(uid).set(data, SetOptions(merge: true));
  }

  Future<void> upsertUser({required String uid, String? email, String? name, String? studentId, String? departmentId}) async {
    final data = <String, dynamic>{
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (studentId != null) 'studentId': studentId,
      if (departmentId != null) 'departmentId': departmentId,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _users.doc(uid).set(data, SetOptions(merge: true));
  }

  Future<String?> findUidByStudentId(String studentId) async {
    final q = await _users.where('studentId', isEqualTo: studentId).limit(1).get();
    if (q.docs.isEmpty) return null;
    return q.docs.first.id;
  }

  Future<void> setPresentCode({required String uid, required String code}) async {
    await _users.doc(uid).set({
      'presentCode': code,
      'presentCodeCreatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setPresentCodeForStudentId({required String studentId, required String code}) async {
    await _db.collection('present_codes').doc(studentId).set({
      'studentId': studentId,
      'presentCode': code,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
