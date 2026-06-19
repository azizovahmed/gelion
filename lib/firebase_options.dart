import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:

        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError('This platform is not supported.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyDQjmrYr_puH6ck259J-YVr8_nA_u2t1ys",
       authDomain: "gelion-99b07.firebaseapp.com",
   projectId: "gelion-99b07",
   storageBucket: "gelion-99b07.firebasestorage.app",
       messagingSenderId: "385827232786",
       appId: "1:385827232786:web:5159d77404f6848dbccccb",
   measurementId: "G-GEBJLJCRK4"
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCs_a_7Tr_xWlxcm4TPdYtO6p3ur9GlsXY',
    appId: '1:695847730782:android:c743955459a1dfa789becf',
    messagingSenderId: '385827232786',
    projectId: 'gelion-99b07',
    storageBucket: 'gelion-99b07.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDQjmrYr_puH6ck259J-YVr8_nA_u2t1ys',
    appId: String.fromEnvironment('FIREBASE_IOS_APP_ID', defaultValue: '1:385827232786:web:5159d77404f6848dbccccb'),
    messagingSenderId: '385827232786',
    projectId: 'gelion-99b07',
    storageBucket: 'gelion-99b07.firebasestorage.app',
    iosBundleId: 'com.gelion.app',
  );

  static const FirebaseOptions macos = ios;

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDQjmrYr_puH6ck259J-YVr8_nA_u2t1ys',
    appId: '1:385827232786:web:5159d77404f6848dbccccb',
    messagingSenderId: '385827232786',
    projectId: 'gelion-99b07',
    storageBucket: 'gelion-99b07.firebasestorage.app',
  );

  static const FirebaseOptions linux = windows;
}
