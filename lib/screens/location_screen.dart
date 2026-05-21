import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  // Coordenadas del Palacio de Deportes de Cartagena
  static const LatLng _center = LatLng(37.6200, -0.9960);

  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // ✅ Scaffold toma scaffoldBackgroundColor del tema automáticamente
      appBar: AppBar(
        title: const Text('Nuestra Ubicación', style: TextStyle(fontWeight: FontWeight.bold)),
        // ✅ Fondo del AppBar adaptado al tema (era Colors.white)
        backgroundColor: colorScheme.surface,
        // ✅ Color de iconos y texto del AppBar adaptado al tema (era Color(0xFF1B263B))
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: _center,
          zoom: 15.0,
        ),
        markers: {
          const Marker(
            markerId: MarkerId('polideportivo_cartagena'),
            position: _center,
            infoWindow: InfoWindow(
              title: 'Palacio de Deportes',
              snippet: 'Cartagena, Murcia',
            ),
          ),
        },
      ),
    );
  }
}