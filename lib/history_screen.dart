import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ejemplo de historial. En el futuro lo sacaremos de /api/reservations/user/{id}
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Reservas')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 2,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.qr_code, color: Color(0xFFF05B3A), size: 40),
              title: const Text('Palacio de Deportes', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('12/11/2026 - 18:00 (2h)'),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
              onTap: () {
                // Aquí podrías re-abrir el QRScreen de esa reserva.
              },
            ),
          );
        },
      ),
    );
  }
}
