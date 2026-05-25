import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // ✨ Importamos core de Firebase
import 'firebase_options.dart'; // ✨ Archivo generado por FlutterFire con tus claves
import 'screens/login_screen.dart';

void main() async {
  // ✨ Estas dos líneas son OBLIGATORIAS para que Firebase arranque antes de dibujar la pantalla
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SportAccessWeb());
}

class SportAccessWeb extends StatelessWidget {
  const SportAccessWeb({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin - SportAccess',
      debugShowCheckedModeBanner: false, // Quita la etiqueta roja de "DEBUG"
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      // La puerta de entrada es tu pantalla de Login
      home: const LoginScreen(),
    );
  }
}