// Konfigurasi Firebase untuk inisialisasi aplikasi
// File ini akan digunakan untuk setup Firebase di main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyCrt56gm3R5FawDZK22JpKTwi-8cnQcy4c',
      appId: '1:360105845760:android:4d78f040da9b266c1c24e5',
      messagingSenderId: '360105845760',
      projectId: 'miebakso-c781f',
      authDomain: '',
      storageBucket: 'miebakso-c781f.firebasestorage.app',
      measurementId: '',
    );
  }
}
