import '../../domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.uid,
    required super.email,
    required super.fullName,
    required super.phone,
    required super.createdAt,
    super.photoUrl,
  });

  static String? profileImageUrlFromMap(Map<String, dynamic> map) {
    for (final key in ['profileImage', 'photoUrl']) {
      final raw = map[key];
      if (raw is String) {
        final t = raw.trim();
        if (t.isNotEmpty) return t;
      } else if (raw != null) {
        final s = raw.toString().trim();
        if (s.isNotEmpty) return s;
      }
    }
    return null;
  }

  factory AppUserModel.fromMap(Map<String, dynamic> map) {
    final photoUrl = profileImageUrlFromMap(map);
    return AppUserModel(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      photoUrl: photoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      if (photoUrl != null && photoUrl!.isNotEmpty) 'photoUrl': photoUrl,
    };
  }
}
