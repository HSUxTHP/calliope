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
    apiKey: 'AIzaSyAhUxlRtqSE8jXHHAWja735-znwvyuKj4I',
    appId: '1:47602731589:web:2cb00f7fbdb034186b712c',
    messagingSenderId: '47602731589',
    projectId: 'calliope-5f6d6',
    authDomain: 'calliope-5f6d6.firebaseapp.com',
    storageBucket: 'calliope-5f6d6.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD7kv2xw8e6rX9g9qKwibLRDorl0cmCrlI',
    appId: '1:47602731589:android:f67d641e6d3a0efa6b712c',
    messagingSenderId: '47602731589',
    projectId: 'calliope-5f6d6',
    storageBucket: 'calliope-5f6d6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCthiFa0GWf460ujxJquY0i5K6wj4C335k',
    appId: '1:47602731589:ios:364bc64afee5c2716b712c',
    messagingSenderId: '47602731589',
    projectId: 'calliope-5f6d6',
    storageBucket: 'calliope-5f6d6.firebasestorage.app',
    iosClientId: '47602731589-3rnjo97ln5h4jha1m35113c5unhrunse.apps.googleusercontent.com',
    iosBundleId: 'com.calliope.calliope',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCthiFa0GWf460ujxJquY0i5K6wj4C335k',
    appId: '1:47602731589:ios:364bc64afee5c2716b712c',
    messagingSenderId: '47602731589',
    projectId: 'calliope-5f6d6',
    storageBucket: 'calliope-5f6d6.firebasestorage.app',
    iosClientId: '47602731589-3rnjo97ln5h4jha1m35113c5unhrunse.apps.googleusercontent.com',
    iosBundleId: 'com.calliope.calliope',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAhUxlRtqSE8jXHHAWja735-znwvyuKj4I',
    appId: '1:47602731589:web:c5e1de1b902dd6a06b712c',
    messagingSenderId: '47602731589',
    projectId: 'calliope-5f6d6',
    authDomain: 'calliope-5f6d6.firebaseapp.com',
    storageBucket: 'calliope-5f6d6.firebasestorage.app',
  );
}
