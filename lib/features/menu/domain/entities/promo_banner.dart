import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../banner_image_parser.dart';

/// Admin `banners` kolleksiyasi — bosh sahifa karuseli.
@immutable
class PromoBanner {
  const PromoBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl = '',
    this.imagePath = '',
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
  final String imagePath;
  final String buttonText;
  final String link;
  final String discount;
  final bool isActive;
  final int order;
  final DateTime? createdAt;

  factory PromoBanner.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final id = (data['id'] as String?)?.trim().isNotEmpty == true
        ? (data['id'] as String).trim()
        : doc.id;
    final image = parseBannerImageFields(data, documentId: id);
    return PromoBanner(
      id: id,
      title: (data['title'] as String?)?.trim() ?? '',
      subtitle: (data['subtitle'] as String?)?.trim() ?? '',
      imagePath: image.storagePath,
      imageUrl: image.networkUrl,
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
        if (imagePath.isNotEmpty) 'imagePath': imagePath,
        if (imageUrl.trim().isNotEmpty) 'imageUrl': imageUrl.trim(),
        'buttonText': buttonText,
        'link': link,
        'isActive': isActive,
        'order': order,
        if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      };

  PromoBanner copyWith({
    String? imageUrl,
    String? imagePath,
  }) =>
      PromoBanner(
        id: id,
        title: title,
        subtitle: subtitle,
        imageUrl: imageUrl ?? this.imageUrl,
        imagePath: imagePath ?? this.imagePath,
        buttonText: buttonText,
        link: link,
        discount: discount,
        isActive: isActive,
        order: order,
        createdAt: createdAt,
      );

  bool get hasImage => imagePath.isNotEmpty || hasNetworkImage;

  bool get hasNetworkImage =>
      imageUrl.trim().startsWith('http://') || imageUrl.trim().startsWith('https://');
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
