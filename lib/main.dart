import 'package:flutter/material.dart';
import 'package:app/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

// NOTIFIER GLOBAL PARA EL MODO OSCURO
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.light);

Future<void> loadThemePreference() async {
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('darkMode') ?? false;
  appThemeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
}

Future<void> saveThemePreference(bool isDark) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('darkMode', isDark);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await loadData();
  await loadThemePreference();
  runApp(const SportAccessApp());
}

class SportAccessApp extends StatelessWidget {
  const SportAccessApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Polirent - SportAccess',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,

          // TEMA CLARO (el que ya tenías)
          theme: ThemeData(
            brightness: Brightness.light,
            cardTheme: const CardThemeData(color: Colors.white),
            primaryColor: const Color(0xFFF05B3A),
            scaffoldBackgroundColor: const Color(0xFFF7FAFD),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFF05B3A),
              brightness: Brightness.light,
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),

          // TEMA OSCURO
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            cardTheme: const CardThemeData(color: Color(0xFF1E2A3A)),
            primaryColor: const Color(0xFFF05B3A),
            scaffoldBackgroundColor: const Color(0xFF0F1923),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFF05B3A),
              brightness: Brightness.dark,
              primary: const Color(0xFFF05B3A),
              secondary: const Color(0xFFF05B3A),
              surface: const Color(0xFF1E2A3A),
            ),
            fontFamily: 'Inter',
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1B263B),
              foregroundColor: Colors.white,
              elevation: 1,
            ),
            drawerTheme: const DrawerThemeData(
              backgroundColor: Color(0xFF1B263B),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF05B3A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF1E2A3A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              labelStyle: const TextStyle(color: Colors.white70),
              hintStyle: const TextStyle(color: Colors.white38),
            ),
          ),

          home: const LoginScreen(),
        );
      },
    );
  }
}