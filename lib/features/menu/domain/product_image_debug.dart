import 'dart:typed_data';

import 'package:flutter/foundation.dart';

/// Admin / Firestore mahsulot rasmi debug loglari (faqat debug).
void printProductImageDebug(String label, Uint8List? bytes) {
  if (!kDebugMode) return;
  // ignore: avoid_print
  print('[$label] selectedImageBytes / imageBytes: '
      'isNull=${bytes == null} | length=${bytes?.length ?? 0}');
}

void logProductImageDebug(
  String phase, {
  Uint8List? imageBytes,
  String? productId,
  Map<String, dynamic>? payload,
}) {
  if (!kDebugMode) return;
  final len = imageBytes?.length ?? 0;
  // ignore: avoid_print
  print(
    '[$phase] productId=$productId | imageBytes isNull=${imageBytes == null} | length=$len',
  );
  if (payload != null) {
    final hasBytesKey = payload.containsKey('imageBytes');
    final bytesVal = payload['imageBytes'];
    final bytesLen = bytesVal is String ? bytesVal.length : 0;
    // ignore: avoid_print
    print(
      'hasImageBytesKey=$hasBytesKey | imageBytesFieldLen=$bytesLen | '
      'keys=${payload.keys.join(",")}',
    );
  }
}
