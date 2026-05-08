import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models/models.dart';

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

  @override
  void initState() {
    super.initState();
    _calcularEstadisticas();
  }

  Future<void> _calcularEstadisticas() async {
    try {
      final url = Uri.parse('http://10.0.2.2:8080/api/reservations');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> todas = jsonDecode(utf8.decode(response.bodyBytes));

        // Filtramos solo las de este usuario
        final misReservas = todas.where((r) => r['user']['email'] == loggedUserEmail && r['estado'] != 'CANCELADA').toList();

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

          // Contar partidos
          if (fechaFin.isBefore(now)) {
            jugados++;
          } else {
            pendientes++;
          }

          // Sumar gasto (simulamos 1 hora por defecto si no tenemos duracion exacta aquí)
          gastoTotal += precio;

          // Contar pista favorita
          pistasCount[nombrePista] = (pistasCount[nombrePista] ?? 0) + 1;
        }

        // Determinar pista favorita
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
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFD),
      appBar: AppBar(
        title: const Text('Mi Perfil y Estadísticas', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B263B))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1B263B)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF05B3A)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // TARJETA DE USUARIO
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: const Color(0xFF1B263B),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Text(loggedUserName.isNotEmpty ? loggedUserName[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 32, color: Color(0xFFF05B3A), fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loggedUserName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(loggedUserEmail, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFF05B3A), borderRadius: BorderRadius.circular(20)),
                          child: const Text('Usuario Premium', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),

            // CUADRÍCULA DE ESTADÍSTICAS
            const Align(
                alignment: Alignment.centerLeft,
                child: Text('Mis Estadísticas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B263B)))
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildStatCard(Icons.sports_score, 'Partidos Jugados', '$_partidosJugados', Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard(Icons.event_available, 'Próximos Partidos', '$_partidosPendientes', Colors.green)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard(Icons.favorite, 'Pista Favorita', _pistaFavorita, Colors.red, isSmallText: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard(Icons.wallet, 'Inversión Deporte', '${_dineroGastado.toStringAsFixed(2)}€', Colors.orange)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, Color color, {bool isSmallText = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(value, style: TextStyle(fontSize: isSmallText ? 16 : 28, fontWeight: FontWeight.bold, color: const Color(0xFF1B263B)), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}