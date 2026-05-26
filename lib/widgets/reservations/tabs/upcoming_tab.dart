import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpcomingTab extends StatelessWidget {
  final List<dynamic> reservations;
  final Function(int) onDelete;

  const UpcomingTab({Key? key, required this.reservations, required this.onDelete}) : super(key: key);

  String _formatDate(String iso) {
    try { return DateFormat('dd/MM/yyyy').format(DateTime.parse(iso)); } catch (e) { return ''; }
  }

  String _extractHour(String iso) {
    try { return iso.split('T')[1].substring(0, 5); } catch (e) { return '--:--'; }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<dynamic>> grupos = {};
    for (var res in reservations) {
      String hInicio = _extractHour(res['fechaInicio']);
      String cliente = res['user'] == null ? (res['nombreInvitado'] ?? 'Invitado') : res['user']['nombre'];
      String pistaId = res['court']['id'].toString();

      String key = '${cliente}_${pistaId}_$hInicio';
      if (!grupos.containsKey(key)) grupos[key] = [];
      grupos[key]!.add(res);
    }

    // Filtramos para dejar solo las series reales (más de 1 reserva)
    grupos.removeWhere((key, lista) => lista.length <= 1);

    if (grupos.isEmpty) return const Center(child: Text('No hay reservas recurrentes programadas.'));

    var keysOrdenadas = grupos.keys.toList();
    keysOrdenadas.sort((a, b) => grupos[a]!.first['fechaInicio'].compareTo(grupos[b]!.first['fechaInicio']));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: keysOrdenadas.length,
      itemBuilder: (context, index) {
        String key = keysOrdenadas[index];
        List<dynamic> grupo = grupos[key]!;

        // Ordenamos las fechas dentro del grupo para que salgan en orden al desplegar
        grupo.sort((a, b) => a['fechaInicio'].compareTo(b['fechaInicio']));

        final res = grupo.first;
        final cliente = res['user'] == null ? '${res['nombreInvitado']} (Invitado)' : res['user']['nombre'];
        final fechaProxima = _formatDate(res['fechaInicio']);
        final hInicio = _extractHour(res['fechaInicio']);
        final hFin = _extractHour(res['fechaFin']);
        int cantidad = grupo.length;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          // ✨ CAMBIAMOS A EXPANSION TILE PARA QUE SEA DESPLEGABLE
          child: ExpansionTile(
            shape: const Border(), // Quita las líneas feas al expandir
            tilePadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.indigo[50], shape: BoxShape.circle),
              child: const Icon(Icons.repeat, color: Colors.indigo),
            ),
            title: Text('${res['court']?['nombre']} - $cliente', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Próxima sesión: $fechaProxima\nHorario fijo: $hInicio - $hFin\nTotal de repeticiones en la serie: $cantidad',
                style: const TextStyle(height: 1.4),
              ),
            ),
            children: [
              const Divider(height: 1),
              const Padding(
                padding: EdgeInsets.only(top: 12.0, bottom: 4.0, left: 32),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Desglose de fechas:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey))
                ),
              ),
              // ✨ LISTA DE DÍAS INDIVIDUALES DENTRO DE LA SERIE
              ...grupo.map((reservaIndividual) {
                final fechaInd = _formatDate(reservaIndividual['fechaInicio']);
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
                  dense: true,
                  title: Text('📅 Sesión del $fechaInd', style: const TextStyle(fontSize: 13)),
                  trailing: IconButton(
                    icon: const Icon(Icons.free_cancellation, color: Colors.orange),
                    tooltip: 'Liberar SOLO este día',
                    onPressed: () => onDelete(reservaIndividual['id']), // Borra solo esta fila en Java
                  ),
                );
              }).toList(),
              // ✨ BOTÓN PARA BORRAR TODA LA SERIE (El que tenías antes)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Cancelar TODA la serie'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red,
                      elevation: 0,
                    ),
                    onPressed: () {
                      for (var r in grupo) {
                        onDelete(r['id']);
                      }
                    },
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}