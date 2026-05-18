import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false; // Le añadimos un pequeño efecto de carga

  void _intentarLogin() async {
    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    // Simulamos un pequeño tiempo de carga para que se vea más profesional
    await Future.delayed(const Duration(milliseconds: 800));

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (email == 'admin@admin.com' && password == 'admin') {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Credenciales incorrectas. Inténtalo de nuevo.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos un fondo claro y sutil para que la tarjeta destaque
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 450, // Un poco más ancho para respirar mejor
            padding: const EdgeInsets.all(40.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // LOGO / ICONO
                const Center(
                  child: Icon(Icons.sports_score, size: 64, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 16),

                // TÍTULOS
                Text(
                  'PoliRent',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Panel de Administración',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // INPUT EMAIL
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.poppins(),
                  decoration: InputDecoration(
                    hintText: 'Correo electrónico',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF1E293B), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // INPUT PASSWORD
                TextField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  style: GoogleFonts.poppins(),
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF1E293B), width: 1.5),
                    ),
                  ),
                  onSubmitted: (_) => _intentarLogin(),
                ),
                const SizedBox(height: 20),

                // MENSAJE DE ERROR ANIMADO
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _errorMessage.isNotEmpty ? 40 : 0,
                  child: _errorMessage.isNotEmpty
                      ? Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _errorMessage,
                        style: GoogleFonts.poppins(
                          color: Colors.redAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 24),

                // BOTÓN DE LOGIN
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B), // Azul oscuro corporativo
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isLoading ? null : _intentarLogin,
                    child: _isLoading
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                        : Text(
                      'ENTRAR',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}