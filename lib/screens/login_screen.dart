import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart'; // Importamos el dashboard al que iremos

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _errorMessage = '';

  void _intentarLogin() {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    // 🔒 Nuestro "Candado Sencillo" (Usuario y contraseña fijos de momento)
    if (email == 'admin@admin.com' && password == 'admin') {
      // Si acierta, le abrimos la puerta y reemplazamos la pantalla
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
      );
    } else {
      // Si falla, mostramos un error
      setState(() {
        _errorMessage = 'Correo o contraseña incorrectos';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900], // Fondo oscuro corporativo
      body: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 400, // Ancho fijo para que no ocupe toda la pantalla en PC
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Que la tarjeta ocupe solo lo necesario
              children: [
                const Text(
                  'Acceso Administrador',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: true, // Oculta la contraseña con puntitos
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  onSubmitted: (_) => _intentarLogin(), // Permite darle al Enter para entrar
                ),
                const SizedBox(height: 16),
                // Mensaje de error (solo se muestra si _errorMessage no está vacío)
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, // El botón ocupa todo el ancho de la tarjeta
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[900],
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _intentarLogin,
                    child: const Text('ENTRAR', style: TextStyle(fontSize: 16, letterSpacing: 2)),
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