import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore `imageBytes` maydoni uchun base64 (mobil/web sinxron).
abstract final class ProductImageCodec {
  /// Kichik preview base64 (katta fayl bazaga yozilmaydi).
  static const int maxFirestoreBase64Length = 68000;

  static String? encodeForFirestore(Uint8List bytes) {
    if (bytes.isEmpty) return null;
    try {
      final encoded = base64Encode(bytes);
      if (encoded.length > maxFirestoreBase64Length) return null;
      return encoded;
    } catch (_) {
      return null;
    }
  }

  static Uint8List? decodeFromFirestore(dynamic raw) {
    if (raw == null) return null;
    if (raw is Uint8List && raw.isNotEmpty) return raw;
    if (raw is Blob && raw.bytes.isNotEmpty) return raw.bytes;
    if (raw is List && raw.isNotEmpty) {
      try {
        return Uint8List.fromList(raw.cast<int>());
      } catch (_) {}
    }
    if (raw is! String) return null;
    final value = raw.trim();
    if (value.isEmpty) return null;
    try {
      final bytes = base64Decode(value.replaceAll(RegExp(r'\s'), ''));
      return bytes.isEmpty ? null : bytes;
    } catch (_) {
      return null;
    }
  }
}
