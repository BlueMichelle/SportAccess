import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  // Configuración extraída de tu google-services.json
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCwfVLL5JnMxsH8UPoqNrsIBBd8_R1UU-c', // Sacado de current_key
    appId: '1:850902302916:android:6912565ddfa953f4058991', // Sacado de mobilesdk_app_id
    messagingSenderId: '850902302916', // Sacado de project_number
    projectId: 'sportaccess-76235', // Sacado de project_id
    authDomain: 'sportaccess-76235.firebaseapp.com', // Se genera con el projectId
    storageBucket: 'sportaccess-76235.firebasestorage.app', // Sacado de storage_bucket
  );
}