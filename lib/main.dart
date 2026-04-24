import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Importamos tu pantalla de login

void main() {
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