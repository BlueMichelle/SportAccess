import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:app/models/models.dart';

class QRScreen extends StatelessWidget {
  final Court court;
  final DateTime date;
  final String time;
  final double total;
  final String uuid;

  const QRScreen({
    Key? key,
    required this.court,
    required this.date,
    required this.time,
    required this.total,
    required this.uuid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // ✅ Scaffold toma scaffoldBackgroundColor del tema automáticamente
      appBar: AppBar(title: const Text('Confirmación')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text(
                '¡Pago completado con éxito!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  // ✅ Fondo de la tarjeta adaptado al tema (era Colors.white)
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      // ✅ Sombra adaptada al tema
                      color: colorScheme.shadow.withOpacity(0.08),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      court.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // ✅ Color del subtítulo de fecha adaptado al tema (era Colors.grey)
                    Text(
                      '${DateFormat('dd/MM/yyyy').format(date)} a las $time',
                      style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                    ),
                    const SizedBox(height: 24),
                    // ✅ QR con fondo y color de primer plano adaptados al tema
                    QrImageView(
                      data: uuid,
                      version: QrVersions.auto,
                      size: 200.0,
                      backgroundColor: colorScheme.surface,
                      eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: colorScheme.onSurface,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Escanea este QR en la pista para acceder',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // ✅ Color del ID adaptado al tema (era Colors.grey)
                    Text(
                      'ID: $uuid',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Volver al Inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}