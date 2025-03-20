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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDhVs74eeuecE3YZmawfsy_LKlXaAj-Naw',
    appId: '1:464064167681:web:300178a8c0ec1b765aa500',
    messagingSenderId: '464064167681',
    projectId: 'gestor-tratamientos-medi-2d9b6',
    authDomain: 'gestor-tratamientos-medi-2d9b6.firebaseapp.com',
    storageBucket: 'gestor-tratamientos-medi-2d9b6.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBZlzKHGpfhghUt_lCMG7EIaUPl0OdIXXM',
    appId: '1:464064167681:android:1f5b9ae6607f6b675aa500',
    messagingSenderId: '464064167681',
    projectId: 'gestor-tratamientos-medi-2d9b6',
    storageBucket: 'gestor-tratamientos-medi-2d9b6.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAFBmvBLmXfBYWxGV6gbS7UT9X4xqNW0Lw',
    appId: '1:464064167681:ios:1caa77879d14e7f85aa500',
    messagingSenderId: '464064167681',
    projectId: 'gestor-tratamientos-medi-2d9b6',
    storageBucket: 'gestor-tratamientos-medi-2d9b6.appspot.com',
    iosBundleId: 'com.example.gestorFlutterEstetico',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAFBmvBLmXfBYWxGV6gbS7UT9X4xqNW0Lw',
    appId: '1:464064167681:ios:1caa77879d14e7f85aa500',
    messagingSenderId: '464064167681',
    projectId: 'gestor-tratamientos-medi-2d9b6',
    storageBucket: 'gestor-tratamientos-medi-2d9b6.appspot.com',
    iosBundleId: 'com.example.gestorFlutterEstetico',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDhVs74eeuecE3YZmawfsy_LKlXaAj-Naw',
    appId: '1:464064167681:web:300178a8c0ec1b765aa500',
    messagingSenderId: '464064167681',
    projectId: 'gestor-tratamientos-medi-2d9b6',
    authDomain: 'gestor-tratamientos-medi-2d9b6.firebaseapp.com',
    storageBucket: 'gestor-tratamientos-medi-2d9b6.firebasestorage.app',
  );
}
