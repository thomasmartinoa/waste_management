// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyABF5PZD5TA0iB4bZCUpHMIueiDgJksGQQ',
    appId: '1:1025490843942:web:af7e3a845df97b07cbe9e7',
    messagingSenderId: '1025490843942',
    projectId: 'wastemanagement-07',
    authDomain: 'wastemanagement-07.firebaseapp.com',
    storageBucket: 'wastemanagement-07.firebasestorage.app',
    measurementId: 'G-CQYQ2P4H35',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAJsR94gtQZ3lDHRhamxvHS4Yxsl3TKsYk',
    appId: '1:1025490843942:android:9d47c9bfabc29702cbe9e7',
    messagingSenderId: '1025490843942',
    projectId: 'wastemanagement-07',
    storageBucket: 'wastemanagement-07.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAAf-toUwWBY0RSOAleDfo14QGmop_1qxU',
    appId: '1:1025490843942:ios:1c4f34698a970951cbe9e7',
    messagingSenderId: '1025490843942',
    projectId: 'wastemanagement-07',
    storageBucket: 'wastemanagement-07.firebasestorage.app',
    iosBundleId: 'com.example.milanTestPoli',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAAf-toUwWBY0RSOAleDfo14QGmop_1qxU',
    appId: '1:1025490843942:ios:1c4f34698a970951cbe9e7',
    messagingSenderId: '1025490843942',
    projectId: 'wastemanagement-07',
    storageBucket: 'wastemanagement-07.firebasestorage.app',
    iosBundleId: 'com.example.milanTestPoli',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyABF5PZD5TA0iB4bZCUpHMIueiDgJksGQQ',
    appId: '1:1025490843942:web:efd97a525797479bcbe9e7',
    messagingSenderId: '1025490843942',
    projectId: 'wastemanagement-07',
    authDomain: 'wastemanagement-07.firebaseapp.com',
    storageBucket: 'wastemanagement-07.firebasestorage.app',
    measurementId: 'G-LHLF4FGYVC',
  );
}
