import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
        throw UnsupportedError('Firebase is not configured for this platform.');
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: _required('FIREBASE_WEB_API_KEY'),
    appId: _required('FIREBASE_WEB_APP_ID'),
    messagingSenderId: _required('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _required('FIREBASE_PROJECT_ID'),
    authDomain: _optional('FIREBASE_AUTH_DOMAIN'),
    storageBucket: _optional('FIREBASE_STORAGE_BUCKET'),
  );

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: _required('FIREBASE_ANDROID_API_KEY'),
    appId: _required('FIREBASE_ANDROID_APP_ID'),
    messagingSenderId: _required('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _required('FIREBASE_PROJECT_ID'),
    storageBucket: _optional('FIREBASE_STORAGE_BUCKET'),
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: _required('FIREBASE_IOS_API_KEY'),
    appId: _required('FIREBASE_IOS_APP_ID'),
    messagingSenderId: _required('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _required('FIREBASE_PROJECT_ID'),
    iosBundleId: _optional('FIREBASE_IOS_BUNDLE_ID'),
    storageBucket: _optional('FIREBASE_STORAGE_BUCKET'),
  );

  static FirebaseOptions get macos => ios;

  static FirebaseOptions get windows => FirebaseOptions(
    apiKey: _required('FIREBASE_WINDOWS_API_KEY'),
    appId: _required('FIREBASE_WINDOWS_APP_ID'),
    messagingSenderId: _required('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _required('FIREBASE_PROJECT_ID'),
    authDomain: _optional('FIREBASE_AUTH_DOMAIN'),
    storageBucket: _optional('FIREBASE_STORAGE_BUCKET'),
  );

  static FirebaseOptions get linux => web;

  static String _required(String key) {
    final value = dotenv.env[key];
    if (value == null || value.trim().isEmpty) {
      throw StateError('Missing Firebase config value: $key');
    }
    return value;
  }

  static String? _optional(String key) {
    final value = dotenv.env[key];
    if (value == null || value.trim().isEmpty) return null;
    return value;
  }
}
