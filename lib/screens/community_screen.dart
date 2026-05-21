import 'package:flutter/material.dart';
import 'package:app/models/models.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<Map<String, dynamic>> _partidasAbiertas = [
    {
      'id': '1', 'deporte': 'Pádel', 'nivel': 'Intermedio',
      'lugar': 'Club Tenis Murcia', 'faltan': 1, 'hora': 'Hoy, 19:00',
      'precio': 4.50, 'unido': false
    },
    {
      'id': '2', 'deporte': 'Fútbol 7', 'nivel': 'Amateur',
      'lugar': 'Jose Barnés', 'faltan': 3, 'hora': 'Mañana, 20:30',
      'precio': 3.00, 'unido': false
    },
  ];

  void _toggleUnirse(int index) {
    final partida = _partidasAbiertas[index];
    final bool yaUnido = partida['unido'];
    final int faltan = partida['faltan'];

    if (yaUnido) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('¿Abandonar partida?'),
          content: const Text('Se te devolverá el importe y perderás tu plaza.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                setState(() {
                  _partidasAbiertas[index]['unido'] = false;
                  _partidasAbiertas[index]['faltan'] = faltan + 1;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Has abandonado la partida')));
              },
              child: const Text('Salir de la partida',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } else {
      if (faltan <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('La partida ya está llena')));
        return;
      }

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirmar y Pagar'),
          content: Text(
              'El precio de tu parte de la pista es de ${partida['precio']}€. ¿Deseas confirmar?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF05B3A)),
              onPressed: () {
                setState(() {
                  _partidasAbiertas[index]['unido'] = true;
                  _partidasAbiertas[index]['faltan'] = faltan - 1;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          '¡Pago completado! Partida añadida a tus reservas.'),
                      backgroundColor: Colors.green),
                );
              },
              child: const Text('Pagar y Unirme',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  void _crearNuevaPartida() {
    final deporteCtrl = TextEditingController();
    final nivelCtrl = TextEditingController();
    final lugarCtrl = TextEditingController();
    final huecosCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Crear Partida Abierta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: deporteCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Deporte (ej. Tenis)')),
              TextField(
                  controller: nivelCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Nivel (ej. Avanzado)')),
              TextField(
                  controller: lugarCtrl,
                  decoration:
                  const InputDecoration(labelText: 'Lugar / Pista')),
              TextField(
                  controller: huecosCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                  const InputDecoration(labelText: 'Huecos libres')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            // Usamos el color primary del tema en lugar de hardcodear
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary),
            onPressed: () {
              if (deporteCtrl.text.isNotEmpty && huecosCtrl.text.isNotEmpty) {
                setState(() {
                  _partidasAbiertas.add({
                    'id': DateTime.now().toString(),
                    'deporte': deporteCtrl.text,
                    'nivel': nivelCtrl.text.isEmpty
                        ? 'Cualquiera'
                        : nivelCtrl.text,
                    'lugar': lugarCtrl.text.isEmpty
                        ? 'Pista por definir'
                        : lugarCtrl.text,
                    'faltan': int.tryParse(huecosCtrl.text) ?? 1,
                    'hora': 'Pendiente',
                    'precio': 5.00,
                    'unido': false,
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Partida creada con éxito')));
              }
            },
            child:
            const Text('Crear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Comunidad',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: colorScheme.onSurface),
          ),
          backgroundColor: colorScheme.surface,
          iconTheme: IconThemeData(color: colorScheme.onSurface),
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Color(0xFFF05B3A),
            labelColor: Color(0xFFF05B3A),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'PARTIDAS ABIERTAS', icon: Icon(Icons.group_add)),
              Tab(text: 'EVENTOS', icon: Icon(Icons.event_available)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMatchmakingTab(),
            _buildEventsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _crearNuevaPartida,
          backgroundColor: const Color(0xFFF05B3A),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Crear Partida',
              style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildMatchmakingTab() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_partidasAbiertas.isEmpty) {
      return Center(
        child: Text(
          'No hay partidas abiertas. ¡Crea la tuya!',
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
      itemCount: _partidasAbiertas.length,
      itemBuilder: (context, index) {
        final p = _partidasAbiertas[index];
        final bool unido = p['unido'];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
                color: unido ? Colors.green : Colors.transparent, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Badge de deporte — fijo decorativo, queda bien en ambos temas
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: const Color(0xFF1B263B),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(p['deporte'].toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                    Text(p['hora'].toString(),
                        style: const TextStyle(
                            color: Color(0xFFF05B3A),
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  p['lugar'].toString(),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star_border,
                        size: 20,
                        color: colorScheme.onSurface.withOpacity(0.5)),
                    const SizedBox(width: 4),
                    Text(
                      'Nivel: ${p['nivel']}',
                      style:
                      TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          p['faltan'] == 0
                              ? Icons.person_off
                              : Icons.person_outline,
                          color: p['faltan'] == 0 ? Colors.grey : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          p['faltan'] == 0
                              ? 'COMPLETO'
                              : 'Faltan ${p['faltan']}',
                          style: TextStyle(
                              color:
                              p['faltan'] == 0 ? Colors.grey : Colors.red,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: unido
                            ? (isDark
                            ? colorScheme.surfaceVariant
                            : Colors.white)
                            : const Color(0xFFF05B3A),
                        side: BorderSide(
                            color: unido ? Colors.red : Colors.transparent),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () => _toggleUnirse(index),
                      child: Text(
                        unido ? 'Salir' : 'Unirme',
                        style: TextStyle(
                            color: unido ? Colors.red : Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventsTab() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final eventos = [
      {
        'titulo': 'Masterclass de Pádel',
        'desc': 'Aprende a hacer la bandeja perfecta.',
        'fecha': 'Sábado 15, 10:00 AM',
        'img':
        'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?q=80&w=400'
      },
      {
        'titulo': 'Torneo Benéfico Tenis',
        'desc': 'Recaudación para la ONG local.',
        'fecha': 'Domingo 23, 09:00 AM',
        'img':
        'https://images.unsplash.com/photo-1595435064215-492976d03704?q=80&w=400'
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: eventos.length,
      itemBuilder: (context, index) {
        final e = eventos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                e['img'].toString(),
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  width: double.infinity,
                  color: isDark
                      ? colorScheme.surfaceVariant
                      : Colors.grey.shade300,
                  child: const Center(
                      child: Icon(Icons.sports_soccer,
                          size: 50, color: Colors.grey)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e['fecha'].toString(),
                        style: const TextStyle(
                            color: Color(0xFFF05B3A),
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      e['titulo'].toString(),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      e['desc'].toString(),
                      style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.6)),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colorScheme.onSurface),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Inscripción registrada')));
                        },
                        child: Text(
                          'Más información / Inscribirse',
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                      ),
                    ),
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