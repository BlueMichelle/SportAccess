import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'models.dart';

class QRScreen extends StatelessWidget {
  final Court court;
  final DateTime date;
  final String time;
  final double total;

  const QRScreen({
    Key? key,
    required this.court,
    required this.date,
    required this.time,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Simulamos un UUID devuelto por el Backend del Miembro 2
    final String mockUUID = 'reserva-${DateTime.now().millisecondsSinceEpoch}';

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmación')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text('¡Pago completado con éxito!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    Text(court.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('${DateFormat('dd/MM/yyyy').format(date)} a las $time', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 24),
                    QrImageView(
                      data: mockUUID,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                    const SizedBox(height: 16),
                    const Text('Escanea este QR en la pista para acceder', textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text('ID: $mockUUID', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Volver al Inicio'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
