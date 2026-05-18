import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Esta función pide los 4 datos al servidor simultáneamente
  Future<Map<String, int>> fetchDashboardData() async {
    const String baseUrl = 'http://localhost:8080/api';

    try {
      // Usamos Future.wait para lanzar las 4 peticiones a la vez (muy profesional)
      final results = await Future.wait([
        http.get(Uri.parse('$baseUrl/users')),
        http.get(Uri.parse('$baseUrl/courts')),
        http.get(Uri.parse('$baseUrl/reservations')),
        http.get(Uri.parse('$baseUrl/incidents')),
      ]);

      int usersCount = 0;
      int activeCourts = 0;
      int totalReservations = 0;
      int openIncidents = 0;

      // 1. Procesamos Usuarios
      if (results[0].statusCode == 200) {
        usersCount = (jsonDecode(utf8.decode(results[0].bodyBytes)) as List).length;
      }

      // 2. Procesamos Pistas (contamos solo las activas)
      if (results[1].statusCode == 200) {
        List courts = jsonDecode(utf8.decode(results[1].bodyBytes));
        activeCourts = courts.where((c) => c['activa'] == true).length;
      }

      // 3. Procesamos Reservas
      if (results[2].statusCode == 200) {
        totalReservations = (jsonDecode(utf8.decode(results[2].bodyBytes)) as List).length;
      }

      // 4. Procesamos Incidencias (contamos solo las abiertas)
      if (results[3].statusCode == 200) {
        List incidents = jsonDecode(utf8.decode(results[3].bodyBytes));
        openIncidents = incidents.where((i) => i['estado'] == 'ABIERTA').length;
      }

      return {
        'users': usersCount,
        'courts': activeCourts,
        'reservations': totalReservations,
        'incidents': openIncidents,
      };
    } catch (e) {
      throw Exception('Error conectando con el servidor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: fetchDashboardData(),
      builder: (context, snapshot) {
        // Mientras carga, mostramos el circulito de progreso
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Si hay error, avisamos al administrador
        if (snapshot.hasError) {
          return Center(
            child: Text('Error al cargar datos reales. ¿Está el backend encendido?',
                style: GoogleFonts.poppins(color: Colors.red)),
          );
        }

        final data = snapshot.data ?? {'users': 0, 'courts': 0, 'reservations': 0, 'incidents': 0};

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido de nuevo, aquí tienes un vistazo rápido de hoy.',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildKpiCard(Icons.people, 'Usuarios Totales', data['users'].toString(), Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildKpiCard(Icons.sports_tennis, 'Pistas Activas', data['courts'].toString(), Colors.green)),
                const SizedBox(width: 16),
                Expanded(child: _buildKpiCard(Icons.calendar_month, 'Reservas Totales', data['reservations'].toString(), Colors.orange)),
                const SizedBox(width: 16),
                Expanded(child: _buildKpiCard(Icons.report_problem, 'Incidencias Abiertas', data['incidents'].toString(), Colors.red)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w500)),
              Text(value, style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}