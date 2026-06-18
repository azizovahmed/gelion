import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

/// Profil uchun rasm faylini tanlash (web: bytes, mobil: path yoki bytes).
Future<({String? path, Uint8List? bytes})?> pickProfileImageFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: false,
    withData: true,
  );
  if (result == null || result.files.isEmpty) return null;

  final file = result.files.first;
  final bytes = file.bytes;
  if (bytes != null && bytes.isNotEmpty) {
    return (path: file.path, bytes: Uint8List.fromList(bytes));
  }

  final path = file.path?.trim();
  if (path != null && path.isNotEmpty) {
    return (path: path, bytes: null);
  }
  return null;
}

/// Cropper uchun vaqtinchalik fayl yo‘li (bytes → temp file).
Future<String?> profileImageTempPathFromBytes(Uint8List bytes) async {
  if (bytes.isEmpty) return null;
  if (kIsWeb) {
    return null;
  }
  try {
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/profile_pick_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  } catch (_) {
    return null;
  }
}
