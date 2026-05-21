class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.createdAt,
    this.photoUrl,
  });

  final String uid;
  final String email;
  final String fullName;
  final String phone;
  final DateTime createdAt;
  final String? photoUrl;

  AppUser copyWithPhotoUrl(String? photoUrl) => AppUser(
        uid: uid,
        email: email,
        fullName: fullName,
        phone: phone,
        createdAt: createdAt,
        photoUrl: photoUrl,
      );
}
