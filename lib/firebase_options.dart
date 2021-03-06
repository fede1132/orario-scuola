// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
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
    // ignore: missing_enum_constant_in_switch
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBnbIqjWeUXLwmWFn7ZrBwztsRg9tk_7zA',
    appId: '1:95078018706:web:f74208ffe3b3c491b5404b',
    messagingSenderId: '95078018706',
    projectId: 'orario-scuola-a868a',
    authDomain: 'orario-scuola-a868a.firebaseapp.com',
    storageBucket: 'orario-scuola-a868a.appspot.com',
    measurementId: 'G-60PWR350QV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBAAUBTCaZKfcSQsdruspmfeigBOxLNTZ0',
    appId: '1:95078018706:android:cc9e2fe62e52b06ab5404b',
    messagingSenderId: '95078018706',
    projectId: 'orario-scuola-a868a',
    storageBucket: 'orario-scuola-a868a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAiEdlCxBeBYv_D-pe8dMlc32l4-i3snE0',
    appId: '1:95078018706:ios:6ce0ed93fa9c1925b5404b',
    messagingSenderId: '95078018706',
    projectId: 'orario-scuola-a868a',
    storageBucket: 'orario-scuola-a868a.appspot.com',
    androidClientId: '95078018706-1ijropqqb8kjfkin1vp34blgmdpb3hqh.apps.googleusercontent.com',
    iosClientId: '95078018706-pprqjsghof7pvtbelos49uplmk9sojcl.apps.googleusercontent.com',
    iosBundleId: 'me.fede1132.orarioScuola',
  );
}
