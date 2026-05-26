import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/screens/login_screen.dart';
import 'package:app/models/models.dart';

// ── Paleta oscura global ──────────────────────────────────────────────────────
const kBg        = Color(0xFF0D1117);   // fondo principal
const kCard      = Color(0xFF161B22);   // tarjetas / contenedores
const kSurface   = Color(0xFF21262D);   // superficies elevadas / inputs
const kBorder    = Color(0xFF30363D);   // bordes y divisores
const kPrimary   = Color(0xFFF05B3A);   // naranja acento
const kTextPri   = Color(0xFFE6EDF3);   // texto principal
const kTextSec   = Color(0xFF8B949E);   // texto secundario / hints
const kNavy      = Color(0xFF1B263B);   // azul marino (drawer header, etc.)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
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
      themeMode: ThemeMode.dark,

      // ── Light (fallback) ──────────────────────────────────────────────────
      theme: ThemeData(
        primaryColor: kPrimary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimary,
          primary: kPrimary,
          secondary: kNavy,
        ),
        fontFamily: 'Inter',
      ),

      // ── Dark ─────────────────────────────────────────────────────────────
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBg,
        primaryColor: kPrimary,
        fontFamily: 'Inter',

        colorScheme: const ColorScheme.dark(
          primary:   kPrimary,
          secondary: kNavy,
          surface:   kCard,
          error:     Color(0xFFF85149),
        ),

        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: kCard,
          foregroundColor: kTextPri,
          elevation: 0,
          iconTheme: IconThemeData(color: kTextPri),
          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: kTextPri,
          ),
        ),

        // Cards
        cardTheme: CardThemeData(
          color: kCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: kBorder, width: 0.5),
          ),
        ),

        // Drawer
        drawerTheme: const DrawerThemeData(backgroundColor: kCard),

        // Divider
        dividerColor: kBorder,

        // Input
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kSurface,
          hintStyle: const TextStyle(color: kTextSec),
          labelStyle: const TextStyle(color: kTextSec),
          prefixIconColor: kTextSec,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kPrimary, width: 1.5),
          ),
        ),

        // Elevated Button
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),

        // TextButton
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: kPrimary),
        ),

        // TabBar
        tabBarTheme: const TabBarThemeData(
          labelColor: kPrimary,
          unselectedLabelColor: kTextSec,
          indicatorColor: kPrimary,
        ),

        // Icon
        iconTheme: const IconThemeData(color: kTextSec),

        // Text
        textTheme: const TextTheme(
          bodyLarge:    TextStyle(color: kTextPri),
          bodyMedium:   TextStyle(color: kTextPri),
          bodySmall:    TextStyle(color: kTextSec),
          titleLarge:   TextStyle(color: kTextPri, fontWeight: FontWeight.bold),
          titleMedium:  TextStyle(color: kTextPri, fontWeight: FontWeight.w600),
          labelSmall:   TextStyle(color: kTextSec),
        ),
      ),

      home: const LoginScreen(),
    );
  }
}
