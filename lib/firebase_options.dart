// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for TrackPoint.
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
        return ios;
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

  // Web - still using placeholders (you can update later if needed)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC7aStfX0wnmEaBjRy8CbeSX1vqJ3s61-A',
    appId:
        '1:597725606100:web:placeholder', // replace if you have a real web app
    messagingSenderId: '597725606100',
    projectId: 'trackpoint-app-f55df',
    authDomain: 'trackpoint-app-f55df.firebaseapp.com',
    databaseURL:
        'https://trackpoint-app-f55df-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'trackpoint-app-f55df.firebasestorage.app',
  );

  // Android - taken from your latest google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC7aStfX0wnmEaBjRy8CbeSX1vqJ3s61-A',
    appId: '1:597725606100:android:e2f4bf563e591478ef0b41',
    messagingSenderId: '597725606100',
    projectId: 'trackpoint-app-f55df',
    storageBucket: 'trackpoint-app-f55df.firebasestorage.app',
    databaseURL:
        'https://trackpoint-app-f55df-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  // iOS - kept from your old file (update if you have new iOS values)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAYyRU-8Lt1CPJrLqtkWrFTGwVWH4H6YRk',
    appId: '1:597725606100:ios:21f4af08dc0e2812ef0b41',
    messagingSenderId: '597725606100',
    projectId: 'trackpoint-app-f55df',
    storageBucket: 'trackpoint-app-f55df.firebasestorage.app',
    iosBundleId: 'com.trackpoint.app',
    databaseURL:
        'https://trackpoint-app-f55df-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  // Windows - placeholder
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC7aStfX0wnmEaBjRy8CbeSX1vqJ3s61-A',
    appId: '1:597725606100:web:placeholder',
    messagingSenderId: '597725606100',
    projectId: 'trackpoint-app-f55df',
    databaseURL:
        'https://trackpoint-app-f55df-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'trackpoint-app-f55df.firebasestorage.app',
  );
}
