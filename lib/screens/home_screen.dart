import 'package:flutter/material.dart';
import 'package:app/models/models.dart';
import 'package:app/screens/booking_screen.dart';
import 'package:app/screens/history_screen.dart';
import 'package:app/screens/scanner_screen.dart';
import 'package:app/screens/login_screen.dart';
import 'package:app/services/api_service.dart';
import 'package:app/screens/contact_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _selectedSport = 'Todos';
  List<Court> _courts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourts();
  }

  Future<void> _loadCourts() async {
    try {
      setState(() => _isLoading = true);
      // Petición directa a la API
      final apiCourts = await ApiService().getCourts();

      if (mounted) {
        setState(() {
          _courts = apiCourts; // Ya no hay mockCourts aquí
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ ERROR CRÍTICO AL CARGAR PISTAS: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al conectar con la base de datos')),
        );
      }
    }
  }

  List<String> get _availableSports {
    Set<String> sports = {'Todos'};
    for (var c in _courts) {
      sports.addAll(c.sports);
    }
    return sports.toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Court> filteredCourts = _courts.where((Court court) {
      final queryLower = _searchQuery.toLowerCase();
      final matchesSearch = court.name.toLowerCase().contains(queryLower) ||
          court.location.toLowerCase().contains(queryLower);
      final matchesSport = _selectedSport == 'Todos' || court.sports.contains(_selectedSport);
      return matchesSearch && matchesSport;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFD),
      appBar: AppBar(
        title: const Text('SportAccess', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B263B))),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF1B263B)),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Color(0xFFF05B3A)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.location_on, color: Color(0xFFF05B3A)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Validación GPS'),
                  content: const Text('Comprobando ubicación...'),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Color(0xFFF05B3A)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            color: Colors.white,
            child: Container(
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: const InputDecoration(
                  hintText: 'Buscar instalación...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _availableSports.length,
                itemBuilder: (context, index) {
                  final sport = _availableSports[index];
                  final isSelected = _selectedSport == sport;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(sport, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF1B263B))),
                      selected: isSelected,
                      selectedColor: const Color(0xFFF05B3A),
                      onSelected: (bool selected) {
                        setState(() => _selectedSport = sport);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFF05B3A)))
                : filteredCourts.isEmpty
                ? const Center(child: Text('No hay pistas disponibles'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredCourts.length,
              itemBuilder: (context, index) => _buildPremiumCourtCard(context, filteredCourts[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCourtCard(BuildContext context, Court court) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(court: court))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'court-${court.id}',
                child: Image.network(
                  // FIX: Añadimos timestamp para forzar el refresco de la imagen y saltar la caché
                  "${court.imageUrl}?t=${DateTime.now().millisecondsSinceEpoch}",
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, e, s) => Container(color: Colors.grey.shade300, child: const Icon(Icons.sports_tennis, size: 64, color: Colors.grey)),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: 16, right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFF05B3A), borderRadius: BorderRadius.circular(20)),
                  child: Text('${court.pricePerHour.toStringAsFixed(2)}€ /h', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              Positioned(
                bottom: 16, left: 16, right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(court.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Expanded(child: Text(court.location, style: const TextStyle(color: Colors.white70, fontSize: 14))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(loggedUserName, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(loggedUserEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(loggedUserName.isNotEmpty ? loggedUserName[0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 24.0, color: Color(0xFFF05B3A))),
            ),
            decoration: const BoxDecoration(color: Color(0xFF1B263B)),
          ),
          ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Mis Reservas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
              }
          ),
          ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Escanear Acceso'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen()));
              }
          ),
          ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Contacto y FAQ'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactScreen()));
              }
          ),
          const Spacer(),
          const Divider(),
          ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                loggedUserName = "";
                loggedUserEmail = "";
                saveData();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
              }
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}