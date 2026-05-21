import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<void> signIn({required String email, required String password});
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  });
  Future<void> sendResetPassword({required String email});
  Future<void> signOut();
  Future<AppUser?> currentUserProfile();

  /// Firestore `users/{uid}` + [User.updateDisplayName]. Email o‘zgarganda [User.verifyBeforeUpdateEmail].
  Future<void> updateUserProfile({
    required String fullName,
    required String phone,
    required String email,
  });

  /// [User.reauthenticateWithCredential] so‘ng [User.updatePassword].
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Profil rasmini Storage ga yuklaydi, `users/{uid}.photoUrl` va Auth [User.photoURL]. Qaytaradi: download URL.
  Future<String> updateProfilePhotoBytes(List<int> bytes, {String contentType = 'image/jpeg'});

  /// Tayyor rasm URL ni profilga yozadi (qayta yuklamasdan).
  Future<String> updateProfilePhotoUrl(String photoUrl);

  /// `photoUrl` ni olib tashlaydi, Storage dagi faylni o‘chirishga harakat qiladi.
  Future<void> clearProfilePhoto();
}
