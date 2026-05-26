import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  Future<Map<String, dynamic>> fetchDashboardData() async {
    const String baseUrl = 'http://localhost:8080/api';

    try {
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
      List<dynamic> reservationsList = [];

      if (results[0].statusCode == 200) {
        usersCount = (jsonDecode(utf8.decode(results[0].bodyBytes)) as List).length;
      }

      if (results[1].statusCode == 200) {
        List courts = jsonDecode(utf8.decode(results[1].bodyBytes));
        activeCourts = courts.where((c) => c['activa'] == true).length;
      }

      if (results[2].statusCode == 200) {
        reservationsList = jsonDecode(utf8.decode(results[2].bodyBytes)) as List;
        totalReservations = reservationsList.length;
      }

      if (results[3].statusCode == 200) {
        List incidents = jsonDecode(utf8.decode(results[3].bodyBytes));
        openIncidents = incidents.where((i) => i['estado'] == 'ABIERTA').length;
      }

      return {
        'users': usersCount,
        'courts': activeCourts,
        'reservationsCount': totalReservations,
        'incidents': openIncidents,
        'reservationsList': reservationsList,
      };
    } catch (e) {
      throw Exception('Error conectando con el servidor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchDashboardData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar datos reales. ¿Está el backend encendido?', style: GoogleFonts.poppins(color: Colors.red)),
            );
          }

          final data = snapshot.data ?? {'users': 0, 'courts': 0, 'reservationsCount': 0, 'incidents': 0, 'reservationsList': []};
          final resList = data['reservationsList'] as List<dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Resumen General', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                const SizedBox(height: 8),
                Text('Bienvenido de nuevo, aquí tienes un vistazo rápido de hoy.', style: GoogleFonts.poppins(fontSize: 14, color: Colors.blueGrey)),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(child: _buildKpiCard(Icons.people, 'Usuarios Totales', data['users'].toString(), Colors.blue)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildKpiCard(Icons.sports_tennis, 'Pistas Activas', data['courts'].toString(), Colors.green)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildKpiCard(Icons.calendar_month, 'Reservas Totales', data['reservationsCount'].toString(), Colors.orange)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildKpiCard(Icons.report_problem, 'Incidencias Abiertas', data['incidents'].toString(), Colors.red)),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildOcupacionCard(resList)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildEvolucionCard(resList)),
                  ],
                ),
                const SizedBox(height: 24),

                _buildActividadRecienteCard(resList),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKpiCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(value, style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOcupacionCard(List<dynamic> reservas) {
    Map<String, int> conteoPistas = {};
    for (var res in reservas) {
      String pistaNombre = res['court']?['nombre'] ?? 'Desconocida';
      conteoPistas[pistaNombre] = (conteoPistas[pistaNombre] ?? 0) + 1;
    }

    int total = reservas.length;
    List<Color> colores = [Colors.blue[400]!, Colors.green[400]!, Colors.orange[400]!, Colors.red[400]!, Colors.blueGrey[400]!];

    List<PieChartSectionData> secciones = [];
    List<Widget> leyendas = [];
    int idx = 0;

    conteoPistas.forEach((pista, count) {
      Color color = colores[idx % colores.length];
      secciones.add(PieChartSectionData(value: count.toDouble(), color: color, radius: 30, showTitle: false));
      leyendas.add(Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: _buildLegendItem(color, '$pista ($count)'),
      ));
      idx++;
    });

    if (secciones.isEmpty) {
      secciones.add(PieChartSectionData(value: 1, color: Colors.grey[200], radius: 30, showTitle: false));
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ocupación Histórica', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
            const SizedBox(height: 32),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 60, startDegreeOffset: -90, sections: secciones)),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(total.toString(), style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                            Text('Reservas', style: GoogleFonts.poppins(fontSize: 12, color: Colors.blueGrey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: leyendas.isEmpty ? [const Text('Sin datos')] : leyendas,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvolucionCard(List<dynamic> reservas) {
    List<int> reservasPorDia = List.filled(7, 0);

    for (var res in reservas) {
      try {
        DateTime fecha = DateTime.parse(res['fechaInicio'].toString().split('T')[0]);
        int weekday = fecha.weekday;
        reservasPorDia[weekday - 1]++;
      } catch (e) {
        // Ignorar fechas mal formateadas
      }
    }

    double maxReservas = reservasPorDia.reduce((curr, next) => curr > next ? curr : next).toDouble();
    if (maxReservas < 5) maxReservas = 5;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Evolución (Días de la semana)', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
            const SizedBox(height: 32),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxReservas + 1,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500, fontSize: 12);
                          const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
                          if (value >= 0 && value < 7) {
                            return SideTitleWidget(axisSide: meta.axisSide, child: Text(dias[value.toInt()], style: style));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[200], strokeWidth: 1)),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _buildBarGroup(0, reservasPorDia[0].toDouble(), Colors.blue[200]!),
                    _buildBarGroup(1, reservasPorDia[1].toDouble(), Colors.green[300]!),
                    _buildBarGroup(2, reservasPorDia[2].toDouble(), Colors.green[500]!),
                    _buildBarGroup(3, reservasPorDia[3].toDouble(), Colors.orange[300]!),
                    _buildBarGroup(4, reservasPorDia[4].toDouble(), Colors.orange[500]!),
                    _buildBarGroup(5, reservasPorDia[5].toDouble(), Colors.red[400]!),
                    _buildBarGroup(6, reservasPorDia[6].toDouble(), Colors.blueGrey[400]!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
        x: x,
        barRods: [BarChartRodData(toY: y, color: color, width: 20, borderRadius: BorderRadius.circular(4))]
    );
  }

  Widget _buildActividadRecienteCard(List<dynamic> reservas) {
    List<dynamic> recientes = List.from(reservas);
    recientes.sort((a, b) => b['fechaInicio'].compareTo(a['fechaInicio']));
    final topRecientes = recientes.take(4).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Actividad Reciente de Reservas', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: DataTable(
                headingTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
                dataTextStyle: GoogleFonts.poppins(color: Colors.blueGrey[700]),
                horizontalMargin: 0,
                columns: const [
                  DataColumn(label: Text('Fecha y Hora')),
                  DataColumn(label: Text('Pista')),
                  DataColumn(label: Text('Cliente')),
                  DataColumn(label: Text('Estado')),
                ],
                rows: topRecientes.map((res) {
                  String fechaFormateada = '';
                  try {
                    final date = DateTime.parse(res['fechaInicio']);
                    fechaFormateada = DateFormat('yyyy-MM-dd HH:mm').format(date);
                  } catch(e) { fechaFormateada = '--'; }

                  String pista = res['court']?['nombre'] ?? 'Sin pista';
                  String cliente = res['user'] == null ? '${res['nombreInvitado'] ?? ''} (Inv)' : res['user']['nombre'];
                  String estado = res['estadoPago'] ?? 'PENDIENTE';
                  MaterialColor colorEstado = estado == 'PAGADO' ? Colors.green : Colors.orange;

                  return DataRow(
                    cells: [
                      DataCell(Text(fechaFormateada)),
                      DataCell(Text(pista)),
                      DataCell(Text(cliente)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: colorEstado[100], borderRadius: BorderRadius.circular(12)),
                          child: Text(estado, style: TextStyle(color: colorEstado[800], fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✨ AQUÍ ESTÁ LA CORRECCIÓN CLAVE PARA LA LEYENDA DEL GRÁFICO
  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded( // Esto fuerza a que el texto respete los límites de su columna
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.blueGrey[700]),
            maxLines: 1, // Si es muy largo se queda en 1 línea
            overflow: TextOverflow.ellipsis, // Y termina en "..."
          ),
        ),
      ],
    );
  }
}