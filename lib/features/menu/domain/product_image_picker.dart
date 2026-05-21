import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

/// Admin panel: web + mobil uchun rasm bytes (`withData: true`, `Image.file` yo‘q).
Future<Uint8List?> pickProductImageBytes() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    withData: true,
    allowMultiple: false,
  );

  if (result == null || result.files.isEmpty) return null;

  final bytes = result.files.first.bytes;
  if (bytes != null && bytes.isNotEmpty) {
    return bytes;
  }

  return null;
}
