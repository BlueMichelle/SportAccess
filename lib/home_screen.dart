import 'package:flutter/material.dart';
import 'models.dart';
import 'booking_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuestras Instalaciones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Mis Reservas',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Más compacto (2 columnas)
          childAspectRatio: 0.8, // Tarjetas más alargadas
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: mockCourts.length,
        itemBuilder: (context, index) {
          final court = mockCourts[index];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(court: court))),
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 4,
                    child: Image.network(
                      court.imageUrl, 
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Espacio ajustado
                        children: [
                          Text(court.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(court.location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          Wrap(
                            spacing: 4,
                            runSpacing: 2,
                            children: court.sports.map((s) => Text(s, style: const TextStyle(fontSize: 10, color: Color(0xFFF05B3A), fontWeight: FontWeight.bold))).toList(),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
