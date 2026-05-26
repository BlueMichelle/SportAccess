import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CrudTab extends StatelessWidget {
  final List<dynamic> reservations;
  final Function(int) onDelete;
  final Function(Map<String, dynamic>) onEdit;

  const CrudTab({Key? key, required this.reservations, required this.onDelete, required this.onEdit}) : super(key: key);

  String _formatDate(String iso) {
    try {
      final date = DateTime.parse(iso);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) { return ''; }
  }

  String _extractHour(String iso) {
    try { return iso.split('T')[1].substring(0, 5); } catch (e) { return '--:--'; }
  }

  @override
  Widget build(BuildContext context) {
    // ✨ EL TRUCO VISUAL: Filtramos para ver SOLO desde el pasado hasta dentro de 7 días.
    final hoy = DateTime.now();
    final limiteFuturo = hoy.add(const Duration(days: 7));

    final reservasFiltradas = reservations.where((r) {
      final fecha = DateTime.parse(r['fechaInicio'].toString().split('T')[0]);
      // Mostrar si es antes del límite futuro (oculta el alboroto de meses posteriores)
      return fecha.isBefore(limiteFuturo);
    }).toList();

    if (reservasFiltradas.isEmpty) return const Center(child: Text('No hay reservas recientes ni para esta semana.'));

    // Ordenamos de más reciente a más antigua
    reservasFiltradas.sort((a, b) => b['fechaInicio'].compareTo(a['fechaInicio']));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reservasFiltradas.length,
      itemBuilder: (context, index) {
        final res = reservasFiltradas[index];
        final cliente = res['user'] == null ? '${res['nombreInvitado']} (Invitado)' : res['user']['nombre'];

        final fecha = _formatDate(res['fechaInicio']);
        final hInicio = _extractHour(res['fechaInicio']);
        final hFin = _extractHour(res['fechaFin']);
        final estadoPago = res['estadoPago'] ?? 'PENDIENTE';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blueGrey[50], shape: BoxShape.circle),
                child: const Icon(Icons.sports_tennis, color: Colors.blueGrey),
              ),
              title: Text('${res['court']?['nombre']} - $cliente', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text('$fecha  |  $hInicio - $hFin', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.payment, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text('Método: ${res['metodoPago']}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      ],
                    ),
                  ],
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: estadoPago == 'PAGADO' ? Colors.green[100] : Colors.orange[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(estadoPago, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: estadoPago == 'PAGADO' ? Colors.green[900] : Colors.orange[900])),
                  ),
                  const SizedBox(width: 12),
                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), tooltip: 'Editar esta reserva', onPressed: () => onEdit(res)),
                  IconButton(icon: const Icon(Icons.cancel, color: Colors.red), tooltip: 'Cancelar esta reserva', onPressed: () => onDelete(res['id'])),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}