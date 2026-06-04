import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web not supported');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCJ2UhB3F7pW2aevfhNHE2leohQksRUCjs',
    appId: '1:949583340805:android:2317af65b83cfbd7eec36c',
    messagingSenderId: '949583340805',
    projectId: 'me-c-69d57',
    storageBucket: 'me-c-69d57.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCJ2UhB3F7pW2aevfhNHE2leohQksRUCjs',
    appId: '1:949583340805:ios:0000000000000000eec36c',
    messagingSenderId: '949583340805',
    projectId: 'me-c-69d57',
    storageBucket: 'me-c-69d57.firebasestorage.app',
    iosBundleId: 'com.taya.slc',
  );
}
