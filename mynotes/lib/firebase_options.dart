// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDpuvpfe_rk3BdkIqoQ51E2hB9YtA3sB8o',
    appId: '1:220768399709:web:ffb0e4c092798552b4f8b4',
    messagingSenderId: '220768399709',
    projectId: 'packflix-database-flutte-28adb',
    authDomain: 'packflix-database-flutte-28adb.firebaseapp.com',
    storageBucket: 'packflix-database-flutte-28adb.appspot.com',
    measurementId: 'G-KTM6BS9FVN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB-MF2IELCG1guJqTKN4oSksaiApYsJrPU',
    appId: '1:220768399709:android:6beefaac97f00933b4f8b4',
    messagingSenderId: '220768399709',
    projectId: 'packflix-database-flutte-28adb',
    storageBucket: 'packflix-database-flutte-28adb.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC9aG-LzQ_m4lHXw81cZ0RNPYh_goxbeCM',
    appId: '1:220768399709:ios:06ba51b039c4ba94b4f8b4',
    messagingSenderId: '220768399709',
    projectId: 'packflix-database-flutte-28adb',
    storageBucket: 'packflix-database-flutte-28adb.appspot.com',
    iosClientId: '220768399709-5qmrgafutjvutmiara8ljbmal55q9aas.apps.googleusercontent.com',
    iosBundleId: 'com.example.mynotes',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC9aG-LzQ_m4lHXw81cZ0RNPYh_goxbeCM',
    appId: '1:220768399709:ios:06ba51b039c4ba94b4f8b4',
    messagingSenderId: '220768399709',
    projectId: 'packflix-database-flutte-28adb',
    storageBucket: 'packflix-database-flutte-28adb.appspot.com',
    iosClientId: '220768399709-5qmrgafutjvutmiara8ljbmal55q9aas.apps.googleusercontent.com',
    iosBundleId: 'com.example.mynotes',
  );
}