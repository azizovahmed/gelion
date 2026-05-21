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
    apiKey: 'AIzaSyB1wRGE-zbmoUQjQNfla9XI98hJbc0mYxo',
    appId: '1:695847730782:web:732dc0cf461fda0289becf',
    messagingSenderId: '695847730782',
    projectId: 'gelion-d57cd',
    authDomain: 'gelion-d57cd.firebaseapp.com',
    databaseURL: 'https://gelion-d57cd-default-rtdb.firebaseio.com',
    storageBucket: 'gelion-d57cd.firebasestorage.app',
    measurementId: 'G-RMF7Q9Z3WL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCs_a_7Tr_xWlxcm4TPdYtO6p3ur9GlsXY',
    appId: '1:695847730782:android:c743955459a1dfa789becf',
    messagingSenderId: '695847730782',
    projectId: 'gelion-d57cd',
    storageBucket: 'gelion-d57cd.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_IOS_API_KEY', defaultValue: ''),
    appId: String.fromEnvironment('FIREBASE_IOS_APP_ID', defaultValue: ''),
    messagingSenderId: '695847730782',
    projectId: 'gelion-d57cd',
    storageBucket: 'gelion-d57cd.firebasestorage.app',
    iosBundleId: 'com.gelion.app',
  );

  static const FirebaseOptions macos = ios;

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_WINDOWS_API_KEY', defaultValue: ''),
    appId: String.fromEnvironment('FIREBASE_WINDOWS_APP_ID', defaultValue: ''),
    messagingSenderId: '695847730782',
    projectId: 'gelion-d57cd',
    storageBucket: 'gelion-d57cd.firebasestorage.app',
  );

  static const FirebaseOptions linux = windows;
}
