import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyBAdTSJlduf1UV5MatM9wX5b0VVwNQewco',
    appId: '1:648366842061:web:d18c5d7269c14e18b0c984',
    messagingSenderId: '648366842061',
    projectId: 'pulsenoter',
    authDomain: 'pulsenoter.firebaseapp.com',
    storageBucket: 'pulsenoter.firebasestorage.app',
    measurementId: 'G-HW472R066D',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA9xNEa0QXc2BlC34m5OeKtW-2jb6-Q3zM',
    appId: '1:648366842061:android:a026404babe25621b0c984',
    messagingSenderId: '648366842061',
    projectId: 'pulsenoter',
    storageBucket: 'pulsenoter.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCVBGbPIvIVS2UCYTjYuYr14cYF1Si95S8',
    appId: '1:648366842061:ios:9af7fbfafe151fcab0c984',
    messagingSenderId: '648366842061',
    projectId: 'pulsenoter',
    storageBucket: 'pulsenoter.firebasestorage.app',
    iosBundleId: 'com.example.pulseNote',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCVBGbPIvIVS2UCYTjYuYr14cYF1Si95S8',
    appId: '1:648366842061:ios:9af7fbfafe151fcab0c984',
    messagingSenderId: '648366842061',
    projectId: 'pulsenoter',
    storageBucket: 'pulsenoter.firebasestorage.app',
    iosBundleId: 'com.example.pulseNote',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBAdTSJlduf1UV5MatM9wX5b0VVwNQewco',
    appId: '1:648366842061:web:f7e2b1fd56f4fedfb0c984',
    messagingSenderId: '648366842061',
    projectId: 'pulsenoter',
    authDomain: 'pulsenoter.firebaseapp.com',
    storageBucket: 'pulsenoter.firebasestorage.app',
    measurementId: 'G-SV8NLEWW30',
  );
}
