import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Kamera / galereya uchun runtime ruxsatlar (Android / iOS).
Future<bool> ensureProfilePhotoPermission(ImageSource source) async {
  if (kIsWeb) return true;

  if (source == ImageSource.camera) {
    final cam = await Permission.camera.request();
    return cam.isGranted;
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    final photos = await Permission.photos.request();
    if (photos.isGranted) return true;
    final storage = await Permission.storage.request();
    return storage.isGranted;
  }

  final photos = await Permission.photos.request();
  return photos.isGranted || photos.isLimited;
}
