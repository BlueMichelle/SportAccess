import 'package:flutter/material.dart';
import 'package:app/screens/login_screen.dart';

import 'package:app/models/models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadData();
  runApp(const SportAccessApp());
}

class SportAccessApp extends StatelessWidget {
  const SportAccessApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polirent - SportAccess',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        cardTheme: const CardThemeData(color: Colors.white),
        primaryColor: const Color(0xFFF05B3A),
        scaffoldBackgroundColor: const Color(0xFFF7FAFD),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF05B3A),
          primary: const Color(0xFFF05B3A),
          secondary: const Color(0xFF1B263B),
        ),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1B263B),
          elevation: 1,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF05B3A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const LoginScreen(), // Ahora arrancamos exigiendo inicio de sesión
    );
  }
}
