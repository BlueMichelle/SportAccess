import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  bool _isLoading = false;

  void _intentarLogin() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Por favor, rellena ambos campos.');
      return;
    }

    setState(() {
      _errorMessage = '';
    });

    try {
      // Pedimos a Spring Boot TODOS los usuarios de tu base de datos
      final url = Uri.parse('http://localhost:8080/api/users');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> allUsers = jsonDecode(utf8.decode(response.bodyBytes));

        bool userFound = false;
        bool isAdmin = false;

        // Buscamos si el correo existe y si tiene rol ADMIN
        for (var user in allUsers) {
          if (user['email'] == email) {
            userFound = true;
            final String rolUsuario = user['rol'] ?? 'USER';
            if (rolUsuario.toUpperCase() == 'ADMIN') {
              isAdmin = true;
            }
            break;
          }
        }

        // Si el usuario existe, es ADMIN, y escribe la contraseña maestra "admin"
        if (userFound && isAdmin) {
          if (password == 'admin') {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
              );
            }
          } else {
            if (mounted) {
              setState(() {
                _errorMessage = 'Contraseña incorrecta.';
                _isLoading = false;
              });
            }
          }
        } else {
          if (mounted) {
            setState(() {
              _errorMessage = 'Acceso denegado. Usuario no encontrado o sin permisos.';
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Error del servidor: ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error de conexión. ¿Está Spring Boot encendido?';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 450,
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
                const Center(
                  child: Icon(Icons.sports_score, size: 64, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 16),
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

                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _errorMessage.isNotEmpty ? 40 : 0,
                  child: _errorMessage.isNotEmpty
                      ? Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: GoogleFonts.poppins(
                            color: Colors.redAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
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