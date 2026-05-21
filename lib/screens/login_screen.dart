import 'package:flutter/material.dart';
import 'package:app/screens/home_screen.dart';
import 'package:app/models/models.dart';
import 'package:app/screens/register_screen.dart';
import 'package:app/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _isLoading = false;

  Future<void> _doLogin() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rellena el email y la contraseña')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Buscamos el usuario en el backend
    final userMap = await ApiService().loginUser(email);

    if (userMap != null) {
      // Usuario encontrado en la BD → sesión iniciada
      loggedUserName = userMap['nombre'] ?? 'Usuario';
      loggedUserEmail = userMap['email'] ?? email;
      loggedUserUid = userMap['firebaseUid'] ?? '';
      await saveData();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      // Usuario NO encontrado → no está registrado
      if (mounted) setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Usuario no encontrado. Regístrate primero.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await GoogleSignIn.instance.initialize();
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        await _handleSocialLoginResult(userCredential);
      }
    } catch (e, stacktrace) {
      print('🚨 ERROR GRAVE EN LOGIN: $e');
      print('🚨 STACKTRACE: $stacktrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error interno: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSocialLoginResult(UserCredential userCredential) async {
    final user = userCredential.user;
    if (user != null) {
      final email = user.email ?? '';
      final name = user.displayName ?? 'Usuario';
      final uid = user.uid;

      print('🔍 SOCIAL LOGIN SUCCESS. UID: $uid');
      print('🔍 Buscando usuario en backend...');
      var userMap;
      try {
        userMap = await ApiService().loginUser(email).timeout(const Duration(seconds: 2));
      } catch (e) {
        print('⏳ Timeout al buscar usuario: $e');
        userMap = null;
      }

      if (userMap == null) {
        print('🔍 Usuario no encontrado, procediendo a registrar...');
        try {
          userMap = await ApiService().registerUser(email, name, realUid: uid).timeout(const Duration(seconds: 2));
        } catch (e) {
          print('⏳ Timeout al registrar usuario: $e');
          userMap = {
            'email': email,
            'nombre': name.isEmpty ? 'Usuario' : name,
            'firebaseUid': uid,
            'telefono': '000000000',
            'rol': 'USER',
          };
        }
      }

      print('✅ userMap final: $userMap');

      if (userMap != null) {
        loggedUserName = userMap['nombre'] ?? name;
        loggedUserEmail = userMap['email'] ?? email;
        loggedUserUid = userMap['firebaseUid'] ?? uid;
        print('💾 Guardando datos locales...');
        await saveData();
        print('🚀 Navegando a HomeScreen...');

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          print('❌ ERROR: El widget ya no está montado (mounted = false).');
        }
      } else {
        print('❌ userMap es null, mostrando error.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al registrar usuario en el servidor')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // ✅ El Scaffold ya toma scaffoldBackgroundColor del tema automáticamente
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ Color del título adaptado al tema
                Text(
                  'POLIRENT',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                // ✅ Subtítulo con color del tema
                Text(
                  'SportAccess',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _doLogin,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('ENTRAR'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                  },
                  child: const Text('¿No tienes cuenta? REGÍSTRATE'),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                // ✅ Texto "O iniciar sesión con..." adaptado al tema
                Text(
                  'O iniciar sesión con...',
                  style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.g_mobiledata, size: 32, color: Colors.red),
                    // ✅ Texto del botón Google adaptado al tema (era Colors.black87, fijo)
                    label: Text(
                      'Continuar con Google',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    onPressed: _isLoading ? null : _loginWithGoogle,
                    style: OutlinedButton.styleFrom(
                      // ✅ Borde adaptado al tema
                      side: BorderSide(color: colorScheme.outline),
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
