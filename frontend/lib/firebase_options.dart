import 'dart:developer';
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart';
import 'package:platform/platform.dart' as platform;

class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBTB8nICbJE1s0iVkzA8_D7wQ3Tr7p9NbU',
    appId: '1:952393473776:android:3d779d7615ec47cb162c35',
    messagingSenderId: '952393473776',
    projectId: 'e-learning-app-533f4',
    storageBucket: 'e-learning-app-533f4.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyBi6mTo6RibXltbhLxBbU375GsKY0vhe7s",
      authDomain: "e-learning-app-533f4.firebaseapp.com",
      projectId: "e-learning-app-533f4",
      storageBucket: "e-learning-app-533f4.firebasestorage.app",
      messagingSenderId: "952393473776",
      appId: "1:952393473776:web:2c84b9dcdb533a47162c35",
      measurementId: "G-P1N05YEQ7Z");

  static FirebaseOptions get currentPlatform {
    const localPlatform = platform.LocalPlatform();
    if (kIsWeb) {
      log('Platform detected: Web');
      return web;
    } else if (localPlatform.isAndroid) {
      log('Platform detected: Android');
      return android;
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }
}
