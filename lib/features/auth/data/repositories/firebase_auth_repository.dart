import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/app_user_model.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  @override
  Future<void> signIn({required String email, required String password}) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    // Auth muvaffaqiyatli bo'lsa, profil metadatasi yozilishi yiqilsa ham login to'xtamasin.
    try {
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'lastLoginAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    await credential.user?.updateDisplayName(fullName.trim());
    final userModel = AppUserModel(
      uid: credential.user!.uid,
      email: email.trim(),
      fullName: fullName.trim(),
      phone: phone.trim(),
      createdAt: DateTime.now(),
    );
    // Firestore permission/no-network holatlari ro'yxatdan o'tishni bloklamasin.
    try {
      await _firestore.collection('users').doc(userModel.uid).set(userModel.toMap());
    } catch (_) {}
  }

  @override
  Future<void> sendResetPassword({required String email}) {
    return _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  @override
  Future<AppUser?> currentUserProfile() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    try {
      DocumentSnapshot<Map<String, dynamic>> doc;
      try {
        doc = await _firestore.collection('users').doc(user.uid).get(const GetOptions(source: Source.server));
      } catch (_) {
        doc = await _firestore.collection('users').doc(user.uid).get();
      }
      final data = doc.data();
      if (data != null) {
        final merged = Map<String, dynamic>.from(data);
        final p = merged['photoUrl'] as String?;
        if ((p == null || p.isEmpty) && user.photoURL != null && user.photoURL!.isNotEmpty) {
          merged['photoUrl'] = user.photoURL;
        }
        return AppUserModel.fromMap(merged);
      }
    } catch (_) {}

    // Firestore profili bo'lmasa ham sessiya mavjud bo'lsa app ichiga kirish davom etadi.
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      fullName: (user.displayName ?? '').trim().isEmpty ? 'Mehmon' : user.displayName!,
      phone: user.phoneNumber ?? '',
      createdAt: DateTime.now(),
      photoUrl: user.photoURL,
    );
  }

  @override
  Future<void> updateUserProfile({
    required String fullName,
    required String phone,
    required String email,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'user-not-found', message: 'No signed-in user');
    }
    final docRef = _firestore.collection('users').doc(user.uid);
    final snap = await docRef.get();
    final prev = snap.data();
    final createdAtStr = prev?['createdAt'] as String? ?? DateTime.now().toIso8601String();

    final name = fullName.trim();
    final phoneTrim = phone.trim();
    final emailTrim = email.trim();
    final currentEmail = (user.email ?? '').toLowerCase();

    await user.updateDisplayName(name);

    await docRef.set(
      {
        'uid': user.uid,
        'fullName': name,
        'phone': phoneTrim,
        'createdAt': createdAtStr,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      SetOptions(merge: true),
    );

    final sameEmail = emailTrim.toLowerCase() == currentEmail;
    if (sameEmail) {
      await docRef.set({'email': emailTrim}, SetOptions(merge: true));
    } else {
      await user.verifyBeforeUpdateEmail(emailTrim);
      await docRef.set({'email': emailTrim}, SetOptions(merge: true));
    }
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;
    final email = user?.email;
    if (user == null || email == null || email.isEmpty) {
      throw FirebaseAuthException(code: 'user-not-found', message: 'No email credential');
    }
    final cred = EmailAuthProvider.credential(
      email: email.trim(),
      password: currentPassword.trim(),
    );
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword.trim());
  }

  @override
  Future<String> updateProfilePhotoBytes(List<int> bytes, {String contentType = 'image/jpeg'}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'user-not-found', message: null);
    }
    if (bytes.isEmpty) {
      throw FirebaseAuthException(code: 'invalid-argument', message: null);
    }
    final data = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
    final ref = _storage.ref().child('user_profiles').child(user.uid).child('avatar.jpg');
    try {
      await ref.delete();
    } catch (_) {}
    await ref.putData(data, SettableMetadata(contentType: contentType));
    final url = await ref.getDownloadURL();
    await _firestore.collection('users').doc(user.uid).set(
      {'uid': user.uid, 'photoUrl': url},
      SetOptions(merge: true),
    );
    await user.updatePhotoURL(url);
    return url;
  }

  @override
  Future<String> updateProfilePhotoUrl(String photoUrl) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'user-not-found', message: null);
    }
    final url = photoUrl.trim();
    if (url.isEmpty) {
      throw FirebaseAuthException(code: 'invalid-argument', message: null);
    }
    await _firestore.collection('users').doc(user.uid).set(
      {'uid': user.uid, 'photoUrl': url},
      SetOptions(merge: true),
    );
    await user.updatePhotoURL(url);
    return url;
  }

  @override
  Future<void> clearProfilePhoto() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'user-not-found', message: null);
    }
    try {
      await _storage.ref().child('user_profiles').child(user.uid).child('avatar.jpg').delete();
    } catch (_) {}
    try {
      await _storage.ref().child('user_profiles').child(user.uid).delete();
    } catch (_) {}
    await _firestore.collection('users').doc(user.uid).set(
      {'photoUrl': FieldValue.delete()},
      SetOptions(merge: true),
    );
    await user.updatePhotoURL(null);
  }
}
