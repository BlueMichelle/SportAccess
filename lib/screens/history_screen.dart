import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models/models.dart';
import 'package:app/screens/qr_screen.dart';
import 'package:app/screens/live_match_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _misReservas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarMisReservas();
  }

  Future<void> _cargarMisReservas() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('http://10.0.2.2:8080/api/reservations');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> todas = jsonDecode(utf8.decode(response.bodyBytes));
        final filtradas = todas.where((r) {
          final userEmail = r['user']['email'] ?? '';
          final estado = r['estado'] ?? '';
          return userEmail == loggedUserEmail && estado != 'CANCELADA';
        }).toList();

        if (mounted) {
          setState(() {
            _misReservas = filtradas;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error al cargar historial: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _cancelReservation(int reservaId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cancelar Reserva?'),
        content: const Text('Esta acción liberará el horario y no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NO'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final url = Uri.parse(
                  'http://10.0.2.2:8080/api/reservations/$reservaId/cancel');
              try {
                final response = await http.put(url);
                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reserva cancelada correctamente')));
                  _cargarMisReservas();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Error al cancelar'),
                      backgroundColor: Colors.red));
                }
              } catch (e) {
                print(e);
              }
            },
            child: const Text('SÍ, CANCELAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Mis Reservas',
              style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            tabs: [Tab(text: 'PRÓXIMAS'), Tab(text: 'ANTERIORES')],
            indicatorColor: Color(0xFFF05B3A),
            labelColor: Color(0xFFF05B3A),
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: _isLoading
            ? const Center(
            child: CircularProgressIndicator(color: Color(0xFFF05B3A)))
            : TabBarView(
          children: [
            _buildFilteredList(isUpcoming: true),
            _buildFilteredList(isUpcoming: false),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredList({required bool isUpcoming}) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    List<dynamic> displayedList = _misReservas.where((res) {
      final fechaFin = DateTime.parse(res['fechaFin']);
      return isUpcoming ? fechaFin.isAfter(now) : fechaFin.isBefore(now);
    }).toList();

    if (displayedList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy,
                size: 64,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No hay reservas aquí',
              style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: displayedList.length,
      itemBuilder: (context, index) {
        final res = displayedList[index];
        final id = res['id'];
        final courtData = res['court'];
        final courtName = courtData['nombre'] ?? 'Pista';
        final DateTime date = DateTime.parse(res['fechaInicio']);
        final horaInicio = DateFormat('HH:mm').format(date);
        final price = (courtData['precioPorHora'] ?? 10.0).toDouble();
        final String? resultado = res['resultadoPartido'];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // FRANJA DEL RESULTADO
              if (resultado != null && resultado.isNotEmpty)
                Container(
                  width: double.infinity,
                  // Color fijo decorativo, queda bien en ambos temas
                  color: const Color(0xFF1B263B),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emoji_events,
                          color: Colors.amber, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'RESULTADO: $resultado',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1),
                      ),
                    ],
                  ),
                ),

              // DATOS DE LA RESERVA
              ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: isUpcoming
                      ? const Color(0xFFF05B3A).withOpacity(0.1)
                      : isDark
                      ? colorScheme.surfaceVariant
                      : Colors.grey.shade100,
                  child: Icon(
                    isUpcoming ? Icons.calendar_today : Icons.history,
                    color: isUpcoming ? const Color(0xFFF05B3A) : Colors.grey,
                  ),
                ),
                title: Text(courtName,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('dd/MM/yyyy').format(date)} a las $horaInicio',
                      style:
                      TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                    ),
                    const Text('Abonado',
                        style: TextStyle(
                            color: Color(0xFFF05B3A),
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isUpcoming)
                      IconButton(
                        icon: Icon(Icons.qr_code,
                            color: colorScheme.onSurface),
                        onPressed: () {
                          final courtObj = Court(
                            id: courtData['id'].toString(),
                            name: courtName,
                            sports: [],
                            imageUrl: courtData['imagen_url'] ?? '',
                            pricePerHour: price,
                            location: courtData['ubicacion'] ?? '',
                          );
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => QRScreen(
                                    court: courtObj,
                                    date: date,
                                    time: horaInicio,
                                    total: price,
                                    uuid: res['qrToken'],
                                  )));
                        },
                      ),
                    if (isUpcoming)
                      IconButton(
                        icon: const Icon(Icons.scoreboard,
                            color: Colors.blueAccent),
                        tooltip: 'Jugar Partido',
                        onPressed: () async {
                          final resultado = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      LiveMatchScreen(reservation: res)));

                          if (resultado != null) {
                            try {
                              final url = Uri.parse(
                                  'http://10.0.2.2:8080/api/reservations/$id/resultado');
                              final response = await http.put(
                                url,
                                headers: {'Content-Type': 'text/plain'},
                                body: resultado,
                              );
                              if (response.statusCode == 200) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('¡Resultado guardado!'),
                                      backgroundColor: Colors.green),
                                );
                                _cargarMisReservas();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Error al guardar el resultado en el servidor'),
                                      backgroundColor: Colors.red),
                                );
                              }
                            } catch (e) {
                              print('Error enviando resultado: $e');
                            }
                          }
                        },
                      ),
                    if (isUpcoming)
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red),
                        onPressed: () => _cancelReservation(id),
                      ),
                    if (!isUpcoming && (resultado == null || resultado.isEmpty))
                      const Icon(Icons.check_circle, color: Colors.green),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}