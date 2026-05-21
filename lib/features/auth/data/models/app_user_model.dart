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

  factory AppUserModel.fromMap(Map<String, dynamic> map) {
    final raw = map['photoUrl'];
    String? photoUrl;
    if (raw is String) {
      photoUrl = raw.trim().isEmpty ? null : raw.trim();
    } else if (raw != null) {
      final s = raw.toString().trim();
      photoUrl = s.isEmpty ? null : s;
    }
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
