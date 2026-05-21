import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;

import '../domain/entities/feedback_entry.dart';
import '../domain/repositories/feedback_repository.dart';

/// Firestore `feedbacks` — har bir hujjat: `userId`, `fullName`, `email`, `message`, `rating`, `createdAt`, `read`, `deviceInfo`.
/// Admin: `users/{uid}` hujjatida `isAdmin: true` yoki `role: "admin"`.
/// [Firestore security rules] da yozish/o‘qish/o‘chirish huquqlarini sozlang.
class FirebaseFeedbackRepository implements FeedbackRepository {
  FirebaseFeedbackRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const _collection = 'feedbacks';

  String _deviceSummary() {
    if (kIsWeb) return 'Web';
    return defaultTargetPlatform.name;
  }

  @override
  Future<bool> isCurrentUserAdmin() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final d = doc.data();
      if (d == null) return false;
      if (d['isAdmin'] == true) return true;
      final role = d['role'];
      if (role is String && role.toLowerCase() == 'admin') return true;
    } catch (_) {}
    return false;
  }

  @override
  Future<void> submitFeedback({
    required String message,
    required int rating,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'user-not-found', message: null);
    }
    final trimmed = message.trim();
    if (trimmed.length < 10) {
      throw FirebaseAuthException(code: 'invalid-argument', message: null);
    }
    final r = rating.clamp(1, 5);
    Map<String, dynamic>? userRow;
    try {
      userRow = (await _firestore.collection('users').doc(user.uid).get()).data();
    } catch (_) {}
    final fullName = (userRow?['fullName'] as String?)?.trim().isNotEmpty == true
        ? userRow!['fullName'] as String
        : (user.displayName ?? '').trim();
    final email = (user.email ?? userRow?['email'] as String? ?? '').trim();

    await _firestore.collection(_collection).add({
      'userId': user.uid,
      'fullName': fullName.isEmpty ? 'User' : fullName,
      'email': email.isEmpty ? '—' : email,
      'message': trimmed,
      'rating': r,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
      'deviceInfo': _deviceSummary(),
    });
  }

  @override
  Stream<List<FeedbackEntry>> watchFeedbacks() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(FeedbackEntry.fromDoc).toList());
  }

  @override
  Future<void> deleteFeedback(String id) {
    return _firestore.collection(_collection).doc(id).delete();
  }

  @override
  Future<void> setFeedbackRead(String id, {required bool read}) {
    return _firestore.collection(_collection).doc(id).update({'read': read});
  }
}
