import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app/models/models.dart';
import 'package:app/services/api_service.dart';

// Coordenadas reales de cada instalación deportiva
const Map<String, List<double>> _courtCoords = {
  'Príncipe de Asturias': [37.9922, -1.1307],
  'San Javier':           [37.8063, -0.8374],
  'Palacio de Deportes':  [37.6051, -0.9862],
  'José Barnés':          [37.9850, -1.1400],
  'Inacua':               [37.9815, -1.1283],
  'Alcantarilla':         [37.9706, -1.2132],
  'Fausto Vicent':        [37.9680, -1.2140],
  'Universidad':          [37.9977, -1.1315],
  'JC1':                  [37.9815, -1.1283],
  'Cabezo':               [38.0194, -1.0977],
  'Premium':              [37.9875, -1.1290],
};

List<double> _getCoordsByName(String courtName) {
  for (final entry in _courtCoords.entries) {
    if (courtName.contains(entry.key)) return entry.value;
  }
  return [37.9922, -1.1307];
}

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isValidating = false;
  String _statusMsg = 'Enfoca el código QR de tu reserva';

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (capture.barcodes.isEmpty || _isValidating) return;
    setState(() { _isValidating = true; _statusMsg = 'Verificando QR...'; });

    final String code = capture.barcodes.first.rawValue ?? '';

    setState(() => _statusMsg = '🔍 Consultando reserva en el servidor...');
    final reservation = await ApiService().getReservationByQrToken(code);

    if (reservation == null) {
      _deny('QR INVÁLIDO: Este código no corresponde a ninguna reserva registrada.');
      return;
    }

    final String? fechaStr = reservation['fechaInicio'];
    if (fechaStr == null) {
      _deny('ERROR: La reserva no tiene fecha registrada.');
      return;
    }
    final DateTime fechaReserva = DateTime.parse(fechaStr);
    final DateTime ahora = DateTime.now();
    final bool esHoy = fechaReserva.year == ahora.year &&
        fechaReserva.month == ahora.month &&
        fechaReserva.day == ahora.day;
    if (!esHoy) {
      final formatted = '${fechaReserva.day}/${fechaReserva.month}/${fechaReserva.year}';
      _deny('ACCESO DENEGADO: Esta reserva es para el $formatted, no para hoy.');
      return;
    }

    if (ahora.isBefore(fechaReserva) || ahora.isAfter(DateTime.parse(reservation['fechaFin'] ?? fechaStr))) {
      final hora = '${fechaReserva.hour.toString().padLeft(2, '0')}:${fechaReserva.minute.toString().padLeft(2, '0')}';
      _deny('ACCESO DENEGADO: Tu reserva es a las $hora. Espera a la hora indicada.');
      return;
    }

    setState(() => _statusMsg = '📍 Verificando tu ubicación GPS...');

    final courtName = reservation['court']?['nombre'] ?? reservation['courtName'] ?? '';
    final coords = _getCoordsByName(courtName);
    final double courtLat = coords[0];
    final double courtLng = coords[1];

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _deny('El GPS del móvil está desactivado.\nActívalo para poder validar tu entrada.');
        return;
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        _deny('Permiso de ubicación bloqueado permanentemente.\nActívalo en los Ajustes del móvil.');
        return;
      }
      if (perm == LocationPermission.denied) {
        _deny('Necesitas conceder permiso de ubicación para validar el acceso.');
        return;
      }

      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).timeout(const Duration(seconds: 5));
      } catch (e) {
        if (e.toString().contains('TimeoutException') || e.toString().contains('TIMEOUT')) {
          pos = await Geolocator.getLastKnownPosition();
        } else {
          rethrow;
        }
      }

      if (pos == null) {
        _deny('GPS sin señal.\n\nEl móvil no tiene registrada ninguna ubicación.');
        return;
      }

      final double distancia = Geolocator.distanceBetween(pos.latitude, pos.longitude, courtLat, courtLng);

      if (distancia > 500) {
        final metros = distancia.toStringAsFixed(0);
        final km = (distancia / 1000).toStringAsFixed(2);
        _deny('No estás en la instalación.\n\nDistancia actual: ${distancia > 1000 ? "$km km" : "$metros metros"}\nAcércate a la instalación para validar el acceso.');
        return;
      }

    } catch (e) {
      _deny('Error al obtener la ubicación GPS.\n\nDetalle: $e');
      return;
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ValidationSuccessScreen(
          qrCode: code, courtName: courtName, reservationDate: fechaReserva,
        )),
      );
    }
  }

  void _deny(String message) {
    if (!mounted) return;
    setState(() { _statusMsg = 'Acceso Denegado'; });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Row(children: [Icon(Icons.block, color: Colors.red), SizedBox(width: 8), Text('Acceso Denegado', style: TextStyle(color: Colors.red, fontSize: 16))]),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (mounted) {
                setState(() { _isValidating = false; _statusMsg = 'Enfoca el código QR de tu reserva'; });
              }
            },
            child: const Text('ENTENDIDO'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validar Acceso QR'), backgroundColor: const Color(0xFF1B263B), foregroundColor: Colors.white),
      body: Stack(
        children: [
          MobileScanner(onDetect: _handleBarcode),
          Center(child: Container(width: 240, height: 240, decoration: BoxDecoration(border: Border.all(color: const Color(0xFFF05B3A), width: 3), borderRadius: BorderRadius.circular(16)))),
          if (_isValidating)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFFF05B3A)),
                    const SizedBox(height: 20),
                    Text(_statusMsg, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 40, left: 24, right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_scanner, color: Color(0xFFF05B3A), size: 20),
                  const SizedBox(width: 8),
                  Flexible(child: Text(_statusMsg, style: const TextStyle(color: Colors.white, fontSize: 13), textAlign: TextAlign.center)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ValidationSuccessScreen extends StatelessWidget {
  final String qrCode;
  final String courtName;
  final DateTime reservationDate;

  const ValidationSuccessScreen({Key? key, required this.qrCode, required this.courtName, required this.reservationDate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hora = '${reservationDate.hour.toString().padLeft(2, '0')}:${reservationDate.minute.toString().padLeft(2, '0')}';
    return Scaffold(
      backgroundColor: const Color(0xFF1A7A4A),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_user, color: Colors.white, size: 90),
                const SizedBox(height: 24),
                const Text('¡ACCESO CONCEDIDO!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow(Icons.location_on, 'Instalación', courtName),
                      const SizedBox(height: 12),
                      _infoRow(Icons.calendar_today, 'Fecha', '${reservationDate.day}/${reservationDate.month}/${reservationDate.year}'),
                      const SizedBox(height: 12),
                      _infoRow(Icons.access_time, 'Hora', hora),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF1A7A4A), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                    child: const Text('IR AL INICIO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, color: Colors.white70, size: 18),
      const SizedBox(width: 10),
      Text('$label: ', style: const TextStyle(color: Colors.white60, fontSize: 14)),
      Flexible(child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
    ]);
  }
}