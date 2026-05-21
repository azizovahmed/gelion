import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Kategoriya — admin panel `categories` kolleksiyasidan real-time.
@immutable
class MenuCategory {
  const MenuCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.iconName,
    required this.order,
    required this.isActive,
    this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String iconName;
  final int order;
  final bool isActive;
  final DateTime? createdAt;

  factory MenuCategory.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return MenuCategory(
      id: (data['id'] as String?)?.trim().isNotEmpty == true
          ? (data['id'] as String).trim()
          : doc.id,
      name: (data['name'] as String?)?.trim() ?? '',
      description: (data['description'] as String?)?.trim() ?? '',
      imageUrl: ((data['image'] ?? data['imageUrl']) as String?)?.trim() ?? '',
      iconName: ((data['icon'] ?? data['iconName']) as String?)?.trim() ??
          'fastfood',
      order: _readInt(data['order']),
      isActive: _readBool(data['isActive'], true),
      createdAt: _readDate(data['createdAt']),
    );
  }
}

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.replaceAll(RegExp(r'[\s,]'), '')) ?? 0;
  return 0;
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
