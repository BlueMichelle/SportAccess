import 'package:flutter/material.dart';

class LiveMatchScreen extends StatefulWidget {
  final Map<String, dynamic> reservation;

  const LiveMatchScreen({Key? key, required this.reservation}) : super(key: key);

  @override
  State<LiveMatchScreen> createState() => _LiveMatchScreenState();
}

class _LiveMatchScreenState extends State<LiveMatchScreen> {
  // Puntuación General
  int _scoreA = 0;
  int _scoreB = 0;

  // Específico Tenis/Pádel
  final List<String> _padelPoints = ['0', '15', '30', '40', 'Ad'];
  int _padelIndexA = 0;
  int _padelIndexB = 0;
  int _gamesA = 0;
  int _gamesB = 0;
  int _setsA = 0;
  int _setsB = 0;

  late String sportType;

  @override
  void initState() {
    super.initState();
    // Detectamos el deporte de la reserva
    String tipo = (widget.reservation['court']['tipo'] ?? '').toString().toLowerCase();
    if (tipo.contains('padel') || tipo.contains('tenis')) {
      sportType = 'raqueta';
    } else if (tipo.contains('baloncesto') || tipo.contains('basket')) {
      sportType = 'basket';
    } else {
      sportType = 'futbol';
    }
  }

  void _finishMatch() {
    String finalResult = '';
    if (sportType == 'raqueta') {
      finalResult = '$_setsA - $_setsB (Sets)';
    } else {
      finalResult = '$_scoreA - $_scoreB';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Finalizar Partido?'),
        content: Text('Resultado final:\nLocal $finalResult Visitante'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF05B3A)),
            onPressed: () {
              // Devolvemos el resultado a la pantalla anterior para guardarlo
              Navigator.pop(ctx);
              Navigator.pop(context, finalResult);
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B263B),
      appBar: AppBar(
        title: Text(widget.reservation['court']['nombre'].toString().toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Text('MARCADOR EN DIRECTO', style: TextStyle(color: Color(0xFFF05B3A), fontWeight: FontWeight.bold, letterSpacing: 2)),
            const Spacer(),

            // PANEL CENTRAL DEPENDIENDO DEL DEPORTE
            if (sportType == 'raqueta') _buildRaquetaBoard()
            else if (sportType == 'basket') _buildBasketBoard()
            else _buildFutbolBoard(),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text('GUARDAR Y FINALIZAR', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF05B3A), padding: const EdgeInsets.symmetric(vertical: 20)),
                  onPressed: _finishMatch,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- INTERFAZ FÚTBOL (+1, -1) ---
  Widget _buildFutbolBoard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _teamScoreColumn('LOCAL', _scoreA, () => setState(() => _scoreA++), () => setState(() => _scoreA > 0 ? _scoreA-- : null)),
        const Text('-', style: TextStyle(color: Colors.white54, fontSize: 60)),
        _teamScoreColumn('VISITANTE', _scoreB, () => setState(() => _scoreB++), () => setState(() => _scoreB > 0 ? _scoreB-- : null)),
      ],
    );
  }

  // --- INTERFAZ BALONCESTO (+1, +2, +3) ---
  Widget _buildBasketBoard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _basketTeamColumn('LOCAL', _scoreA, true),
        const Text('-', style: TextStyle(color: Colors.white54, fontSize: 60)),
        _basketTeamColumn('VISITANTE', _scoreB, false),
      ],
    );
  }

  Widget _basketTeamColumn(String name, int score, bool isTeamA) {
    return Column(
      children: [
        Text(name, style: const TextStyle(color: Colors.white70, fontSize: 20)),
        Text('$score', style: const TextStyle(color: Colors.white, fontSize: 80, fontWeight: FontWeight.bold)),
        Row(
          children: [
            ElevatedButton(onPressed: () => setState(() => isTeamA ? _scoreA+=1 : _scoreB+=1), child: const Text('+1')),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: () => setState(() => isTeamA ? _scoreA+=2 : _scoreB+=2), child: const Text('+2')),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: () => setState(() => isTeamA ? _scoreA+=3 : _scoreB+=3), child: const Text('+3')),
          ],
        )
      ],
    );
  }

  // --- INTERFAZ PÁDEL / TENIS (Sets, Juegos, Puntos) ---
  Widget _buildRaquetaBoard() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _box(_setsA, 'SETS', Colors.orange), const SizedBox(width: 20),
            _box(_gamesA, 'JUEGOS', Colors.blue), const SizedBox(width: 40),
            _box(_gamesB, 'JUEGOS', Colors.blue), const SizedBox(width: 20),
            _box(_setsB, 'SETS', Colors.orange),
          ],
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _padelTeamColumn('LOCAL', _padelPoints[_padelIndexA], true),
            const Text('-', style: TextStyle(color: Colors.white54, fontSize: 60)),
            _padelTeamColumn('VISITANTE', _padelPoints[_padelIndexB], false),
          ],
        )
      ],
    );
  }

  Widget _box(int val, String label, Color c) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
          child: Text('$val', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _padelTeamColumn(String name, String points, bool isTeamA) {
    return Column(
      children: [
        Text(name, style: const TextStyle(color: Colors.white70, fontSize: 20)),
        Text(points, style: const TextStyle(color: Colors.white, fontSize: 80, fontWeight: FontWeight.bold)),
        ElevatedButton(
          onPressed: () {
            setState(() {
              if (isTeamA) {
                _padelIndexA = (_padelIndexA + 1) % 5; // Pasa por 0, 15, 30, 40, Ad
              } else {
                _padelIndexB = (_padelIndexB + 1) % 5;
              }
            });
          },
          child: const Text('Punto'),
        ),
        Row(
          children: [
            TextButton(onPressed: () => setState(() => isTeamA ? _gamesA++ : _gamesB++), child: const Text('+ Juego')),
            TextButton(onPressed: () => setState(() => isTeamA ? _setsA++ : _setsB++), child: const Text('+ Set')),
          ],
        )
      ],
    );
  }

  Widget _teamScoreColumn(String name, int score, VoidCallback onAdd, VoidCallback onSub) {
    return Column(
      children: [
        Text(name, style: const TextStyle(color: Colors.white70, fontSize: 20)),
        Text('$score', style: const TextStyle(color: Colors.white, fontSize: 100, fontWeight: FontWeight.bold)),
        Row(
          children: [
            IconButton(icon: const Icon(Icons.remove_circle, color: Colors.white54, size: 40), onPressed: onSub),
            const SizedBox(width: 20),
            IconButton(icon: const Icon(Icons.add_circle, color: Color(0xFFF05B3A), size: 50), onPressed: onAdd),
          ],
        )
      ],
    );
  }
}