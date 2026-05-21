import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

class FirebaseBootstrap {
  static Future<void> initialize() async {
    if (Firebase.apps.isNotEmpty) {
      return;
    }
    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      _validateOptions(options);
      await Firebase.initializeApp(options: options).timeout(const Duration(seconds: 12));
    } catch (e) {
      throw Exception('Firebase initialize xatosi: $e');
    }
  }

  static void _validateOptions(FirebaseOptions options) {
    if (options.apiKey.trim().isEmpty || options.appId.trim().isEmpty) {
      throw Exception('Firebase config to‘liq emas (apiKey/appId bo‘sh).');
    }
  }
}
