import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Crop qilingan rasm nusxasi — offline ko‘rish uchun (Firebase asosiy manba).
abstract final class ProfilePhotoLocalCache {
  static String _key(String uid) => 'profile_avatar_local_$uid';

  static Future<void> saveBytes(String uid, List<int> bytes) async {
    if (kIsWeb || uid.isEmpty || bytes.isEmpty) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/profile_avatar_$uid.jpg');
      await file.writeAsBytes(bytes, flush: true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key(uid), file.path);
    } catch (_) {}
  }

  static Future<String?> loadFilePath(String uid) async {
    if (kIsWeb || uid.isEmpty) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final path = prefs.getString(_key(uid));
      if (path == null || path.isEmpty) return null;
      if (!File(path).existsSync()) return null;
      return path;
    } catch (_) {
      return null;
    }
  }
}
