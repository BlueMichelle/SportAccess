import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/models/models.dart';
import 'package:app/screens/qr_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  void _cancelReservation(int indexInGlobal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cancelar Reserva?'),
        content: const Text('Esta acción liberará el horario y no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('NO')),
          TextButton(
            onPressed: () {
              setState(() {
                mockReservations.removeAt(indexInGlobal);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reserva cancelada correctamente')));
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
        backgroundColor: const Color(0xFFF7FAFD),
        appBar: AppBar(
          title: const Text('Mis Reservas', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'PRÓXIMAS'),
              Tab(text: 'ANTERIORES'),
            ],
            indicatorColor: Color(0xFFF05B3A),
            labelColor: Color(0xFFF05B3A),
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: TabBarView(
          children: [
            _buildFilteredList(isUpcoming: true),
            _buildFilteredList(isUpcoming: false),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredList({required bool isUpcoming}) {
    // Necesitamos el índice original para poder borrar de la lista global
    List<Map<String, dynamic>> displayedList = [];
    List<int> originalIndices = [];

    for (int i = 0; i < mockReservations.length; i++) {
      if (mockReservations[i]['isScanned'] == !isUpcoming && mockReservations[i]['email'] == loggedUserEmail) {
        displayedList.add(mockReservations[i]);
        originalIndices.add(i);
      }
    }

    if (displayedList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No hay reservas aquí', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: displayedList.length,
      itemBuilder: (context, index) {
        final res = displayedList[index];
        final globalIndex = originalIndices[index];
        final DateTime date = res['date'] as DateTime;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: isUpcoming ? const Color(0xFFF05B3A).withOpacity(0.1) : Colors.grey.shade100,
              child: Icon(isUpcoming ? Icons.calendar_today : Icons.history, color: isUpcoming ? const Color(0xFFF05B3A) : Colors.grey),
            ),
            title: Text(res['courtName'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${DateFormat('dd/MM/yyyy').format(date)} a las ${res['time']}'),
                Text('${res['total'].toStringAsFixed(2)} €', style: const TextStyle(color: Color(0xFFF05B3A), fontWeight: FontWeight.bold)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isUpcoming)
                  IconButton(
                    icon: const Icon(Icons.qr_code, color: Color(0xFF1B263B)),
                    onPressed: () {
                      final court = mockCourts.firstWhere((c) => c.name == res['courtName'], orElse: () => mockCourts[0]);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => QRScreen(
                        court: court, date: date, time: res['time'], total: res['total'], uuid: res['uuid'],
                      )));
                    },
                  ),
                if (isUpcoming)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _cancelReservation(globalIndex),
                  ),
                if (!isUpcoming) const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
          ),
        );
      },
    );
  }
}
