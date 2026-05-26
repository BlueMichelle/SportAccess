import 'package:flutter/material.dart';
import 'package:app/screens/home_screen.dart';
import 'package:app/models/models.dart';
import 'package:app/screens/register_screen.dart';
import 'package:app/services/api_service.dart';
import 'package:app/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _isLoading  = false;
  bool _obscure    = true;

  Future<void> _doLogin() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rellena el email y la contraseña')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final userMap = await ApiService().loginUser(email);

    if (userMap != null) {
      loggedUserName  = userMap['nombre'] ?? 'Usuario';
      loggedUserEmail = userMap['email']  ?? email;
      loggedUserUid   = userMap['firebaseUid'] ?? '';
      await saveData();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Usuario no encontrado. Regístrate primero.'),
            backgroundColor: Color(0xFFF85149),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo / Brand
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPrimary, Color(0xFFFF8C42)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: kPrimary.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: const Icon(Icons.sports_tennis, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 24),
                const Text('POLIRENT', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: kTextPri, letterSpacing: 2)),
                const Text('SportAccess', style: TextStyle(fontSize: 15, color: kTextSec, letterSpacing: 1)),
                const SizedBox(height: 48),

                // Email
                TextField(
                  controller: _emailCtrl,
                  style: const TextStyle(color: kTextPri),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: kSurface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorder)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimary, width: 1.5)),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  style: const TextStyle(color: kTextPri),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: kTextSec),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    filled: true,
                    fillColor: kSurface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorder)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimary, width: 1.5)),
                  ),
                ),
                const SizedBox(height: 28),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _doLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                      shadowColor: kPrimary.withOpacity(0.5),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text('ENTRAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
                  ),
                ),
                const SizedBox(height: 20),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿No tienes cuenta?', style: TextStyle(color: kTextSec)),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: const Text('REGÍSTRATE', style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
