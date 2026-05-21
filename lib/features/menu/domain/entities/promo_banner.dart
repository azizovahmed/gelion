import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Admin `banners` kolleksiyasi — bosh sahifa karuseli.
@immutable
class PromoBanner {
  const PromoBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.buttonText,
    required this.link,
    required this.discount,
    required this.isActive,
    this.order = 0,
    this.createdAt,
  });

  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String buttonText;
  final String link;
  final String discount;
  final bool isActive;
  final int order;
  final DateTime? createdAt;

  factory PromoBanner.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return PromoBanner(
      id: (data['id'] as String?)?.trim().isNotEmpty == true
          ? (data['id'] as String).trim()
          : doc.id,
      title: (data['title'] as String?)?.trim() ?? '',
      subtitle: (data['subtitle'] as String?)?.trim() ?? '',
      imageUrl: ((data['image'] ?? data['imageUrl']) as String?)?.trim() ?? '',
      buttonText: ((data['buttonText'] ?? data['actionText']) as String?)
              ?.trim() ??
          '',
      link: ((data['link'] ?? data['targetId'] ?? data['deepLink']) as String?)
              ?.trim() ??
          '',
      discount: (data['discount'] as String?)?.trim() ?? '',
      isActive: _readBool(data['isActive'], true),
      order: _readInt(data['order']),
      createdAt: _readDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'image': imageUrl,
        'buttonText': buttonText,
        'link': link,
        'isActive': isActive,
        'order': order,
        if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      };
}

bool _readBool(dynamic value, bool fallback) {
  if (value is bool) return value;
  if (value is String) {
    final v = value.toLowerCase();
    return v == 'true' || v == '1';
  }
  return fallback;
}

DateTime? _readDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
