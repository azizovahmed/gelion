import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackEntry {
  const FeedbackEntry({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.message,
    required this.rating,
    required this.createdAt,
    required this.read,
    this.deviceInfo,
  });

  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String message;
  final int rating;
  final DateTime createdAt;
  final bool read;
  final String? deviceInfo;

  factory FeedbackEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? {};
    final ts = m['createdAt'];
    DateTime at = DateTime.now();
    if (ts is Timestamp) at = ts.toDate();
    return FeedbackEntry(
      id: doc.id,
      userId: m['userId'] as String? ?? '',
      fullName: m['fullName'] as String? ?? '',
      email: m['email'] as String? ?? '',
      message: m['message'] as String? ?? '',
      rating: (m['rating'] as num?)?.toInt().clamp(1, 5) ?? 1,
      createdAt: at,
      read: m['read'] as bool? ?? false,
      deviceInfo: m['deviceInfo'] as String?,
    );
  }
}
