import 'package:firebase_auth/firebase_auth.dart';

import '../domain/entities/app_order.dart';

/// Faqat hozirgi login qilgan foydalanuvchi UID.
String? get currentAuthUid => FirebaseAuth.instance.currentUser?.uid;

/// So‘rovlar uchun UID — boshqa account ID qabul qilinmaydi.
String resolveOrdersUserId([String? requested]) {
  final authUid = currentAuthUid?.trim() ?? '';
  if (authUid.isEmpty) return '';
  final req = requested?.trim() ?? '';
  if (req.isNotEmpty && req != authUid) return '';
  return authUid;
}

List<AppOrder> filterOrdersForUser(List<AppOrder> orders, String userId) {
  if (userId.isEmpty) return const [];
  return orders.where((o) {
    final owner = o.userId.trim();
    return owner.isEmpty || owner == userId;
  }).toList();
}
