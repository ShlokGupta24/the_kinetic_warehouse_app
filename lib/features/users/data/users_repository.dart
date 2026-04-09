import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository(FirebaseFirestore.instance);
});

final allUsersStreamProvider = StreamProvider.autoDispose<QuerySnapshot<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(usersRepositoryProvider);
  return repo.getUsersStream();
});

class UsersRepository {
  final FirebaseFirestore _firestore;

  UsersRepository(this._firestore);

  Stream<QuerySnapshot<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('users').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addUser(Map<String, dynamic> userData) async {
    userData['createdAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('users').add(userData);
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    await _firestore.collection('users').doc(userId).update({
      'role': newRole,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }
}
