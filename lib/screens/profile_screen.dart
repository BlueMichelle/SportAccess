import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/models/models.dart';
import 'package:app/main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  int _partidosJugados = 0;
  int _partidosPendientes = 0;
  String _pistaFavorita = "Ninguna";
  double _dineroGastado = 0.0;
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _calcularEstadisticas();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('profileImagePath_$loggedUserEmail');
    if (savedPath != null && File(savedPath).existsSync()) {
      setState(() => _profileImagePath = savedPath);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked =
    await picker.pickImage(source: source, imageQuality: 80, maxWidth: 400);
    if (picked != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImagePath_$loggedUserEmail', picked.path);
      setState(() => _profileImagePath = picked.path);
    }
  }

  void _showImageOptions() {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Foto de perfil',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Color(0xFFF05B3A)),
              title: Text('Tomar foto',
                  style: TextStyle(color: colorScheme.onSurface)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading:
              const Icon(Icons.photo_library, color: Color(0xFFF05B3A)),
              title: Text('Elegir de galería',
                  style: TextStyle(color: colorScheme.onSurface)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_profileImagePath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar foto',
                    style: TextStyle(color: Colors.red)),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('profileImagePath_$loggedUserEmail');
                  setState(() => _profileImagePath = null);
                  if (mounted) Navigator.pop(context);
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showEditProfile() {
    final nameCtrl = TextEditingController(text: loggedUserName);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Editar perfil',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: colorScheme.onSurface),
            ),
            const SizedBox(height: 20),
            Text('Nombre',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: colorScheme.onSurface.withOpacity(0.6))),
            const SizedBox(height: 8),
            TextField(
              controller: nameCtrl,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Tu nombre',
                filled: true,
                fillColor:
                isDark ? colorScheme.surfaceVariant : Colors.grey.shade50,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.person_outline,
                    color: Color(0xFFF05B3A)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Email',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: colorScheme.onSurface.withOpacity(0.6))),
            const SizedBox(height: 8),
            TextField(
              enabled: false,
              controller: TextEditingController(text: loggedUserEmail),
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
              decoration: InputDecoration(
                filled: true,
                fillColor:
                isDark ? colorScheme.surfaceVariant : Colors.grey.shade100,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                prefixIcon:
                const Icon(Icons.email_outlined, color: Colors.grey),
                suffixIcon: const Icon(Icons.lock_outline,
                    color: Colors.grey, size: 18),
              ),
            ),
            const SizedBox(height: 4),
            const Text('El email no se puede modificar',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final newName = nameCtrl.text.trim();
                  if (newName.isEmpty) return;
                  loggedUserName = newName;
                  await saveData();
                  setState(() {});
                  if (mounted) Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('✅ Perfil actualizado'),
                          backgroundColor: Colors.green),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF05B3A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('GUARDAR CAMBIOS',
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _calcularEstadisticas() async {
    try {
      final url = Uri.parse('http://10.0.2.2:8080/api/reservations');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> todas =
        jsonDecode(utf8.decode(response.bodyBytes));
        final misReservas = todas
            .where((r) =>
        r['user']['email'] == loggedUserEmail &&
            r['estado'] != 'CANCELADA')
            .toList();

        final now = DateTime.now();
        int jugados = 0;
        int pendientes = 0;
        double gastoTotal = 0;
        Map<String, int> pistasCount = {};

        for (var res in misReservas) {
          final fechaFin = DateTime.parse(res['fechaFin']);
          final courtData = res['court'];
          final nombrePista = courtData['nombre'] ?? 'Desconocida';
          final precio = (courtData['precioPorHora'] ?? 0).toDouble();

          if (fechaFin.isBefore(now)) {
            jugados++;
          } else {
            pendientes++;
          }
          gastoTotal += precio;
          pistasCount[nombrePista] = (pistasCount[nombrePista] ?? 0) + 1;
        }

        String favorita = "Ninguna";
        int maxCount = 0;
        pistasCount.forEach((key, value) {
          if (value > maxCount) {
            maxCount = value;
            favorita = key;
          }
        });

        if (mounted) {
          setState(() {
            _partidosJugados = jugados;
            _partidosPendientes = pendientes;
            _pistaFavorita = favorita;
            _dineroGastado = gastoTotal;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error al cargar stats: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil y Estadísticas',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFFF05B3A)),
            tooltip: 'Editar perfil',
            onPressed: _showEditProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(color: Color(0xFFF05B3A)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // TARJETA DE USUARIO
            // Fondo fijo decorativo: queda bien en ambos temas
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1B263B),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5))
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _showImageOptions,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          backgroundImage: _profileImagePath != null
                              ? FileImage(File(_profileImagePath!))
                              : null,
                          child: _profileImagePath == null
                              ? Text(
                              loggedUserName.isNotEmpty
                                  ? loggedUserName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                  fontSize: 32,
                                  color: Color(0xFFF05B3A),
                                  fontWeight: FontWeight.bold))
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                                color: Color(0xFFF05B3A),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(loggedUserName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                            ),
                            GestureDetector(
                              onTap: _showEditProfile,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    color:
                                    Colors.white.withOpacity(0.15),
                                    borderRadius:
                                    BorderRadius.circular(8)),
                                child: const Icon(Icons.edit,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(loggedUserEmail,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                              color: const Color(0xFFF05B3A),
                              borderRadius: BorderRadius.circular(20)),
                          child: const Text('Usuario Premium',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // BOTÓN EDITAR PERFIL
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showEditProfile,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Editar datos del perfil',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // SWITCH MODO OSCURO
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: colorScheme.outline.withOpacity(0.3)),
              ),
              child: ValueListenableBuilder<ThemeMode>(
                valueListenable: appThemeMode,
                builder: (context, themeMode, _) {
                  final isDarkMode = themeMode == ThemeMode.dark;
                  return SwitchListTile(
                    title: Text('Modo Oscuro',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface)),
                    subtitle: Text(
                      isDarkMode ? 'Activado' : 'Desactivado',
                      style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withOpacity(0.6)),
                    ),
                    secondary: Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: const Color(0xFFF05B3A),
                    ),
                    activeColor: const Color(0xFFF05B3A),
                    value: isDarkMode,
                    onChanged: (val) async {
                      appThemeMode.value =
                      val ? ThemeMode.dark : ThemeMode.light;
                      await saveThemePreference(val);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 30),

            // TÍTULO ESTADÍSTICAS
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Mis Estadísticas',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                    child: _buildStatCard(Icons.sports_score,
                        'Partidos Jugados', '$_partidosJugados', Colors.blue)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildStatCard(Icons.event_available,
                        'Próximos Partidos', '$_partidosPendientes', Colors.green)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildStatCard(Icons.favorite, 'Pista Favorita',
                        _pistaFavorita, Colors.red,
                        isSmallText: true)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildStatCard(
                        Icons.wallet,
                        'Inversión Deporte',
                        '${_dineroGastado.toStringAsFixed(2)}€',
                        Colors.orange)),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, Color color,
      {bool isSmallText = false}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration:
            BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
                fontSize: isSmallText ? 16 : 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(title,
              style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withOpacity(0.6))),
        ],
      ),
    );
  }
}