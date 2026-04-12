import 'package:flutter/material.dart';
import 'package:app/models/models.dart';
import 'package:app/screens/booking_screen.dart';
import 'package:app/screens/history_screen.dart';
import 'package:app/screens/scanner_screen.dart';
import 'package:app/screens/login_screen.dart';
import 'package:app/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  List<Court> _courts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourts();
  }

  Future<void> _loadCourts() async {
    final apiCourts = await ApiService().getCourts();
    if (mounted) {
      setState(() {
        _courts = apiCourts;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Court> filteredCourts = _courts.where((Court court) {
      final queryLower = _searchQuery.toLowerCase();
      return court.name.toLowerCase().contains(queryLower) ||
             court.location.toLowerCase().contains(queryLower) ||
             court.sports.any((s) => s.toLowerCase().contains(queryLower));
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFD),
      appBar: AppBar(
        title: const Text('SportAccess', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B263B))),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Color(0xFFF05B3A)),
            tooltip: 'Escanear QR',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.location_on, color: Color(0xFFF05B3A)),
            tooltip: 'Check-in (GPS)',
            onPressed: () {
              // Simulación de validación de GPS para el usuario
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Validación GPS', style: TextStyle(fontWeight: FontWeight.bold)),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.gps_fixed, size: 48, color: Colors.green),
                      SizedBox(height: 16),
                      Text('Comprobando tu ubicación actual en el centro deportivo...'),
                      SizedBox(height: 8),
                      Text('Coordenadas: 37.9922, -1.1307', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Color(0xFFF05B3A)),
            tooltip: 'Mis Reservas',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          // BUSCADOR COMPACTO
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            color: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: const InputDecoration(
                  hintText: 'Buscar pista o deporte...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          // LISTA DE PISTAS
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFF05B3A)))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredCourts.length,
              itemBuilder: (context, index) {
                final court = filteredCourts[index];
                return _buildCourtCard(context, court);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourtCard(BuildContext context, Court court) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(court: court))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Hero(
                tag: 'court-${court.id}',
                child: Container(
                  width: 90,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                    image: DecorationImage(image: NetworkImage(court.imageUrl), fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(court.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B263B))),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(court.location, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${court.pricePerHour.toStringAsFixed(2)}€/h', style: const TextStyle(color: Color(0xFFF05B3A), fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              const SizedBox(width: 12),
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
              child: Text(loggedUserName.isNotEmpty ? loggedUserName[0].toUpperCase() : 'U', style: const TextStyle(fontSize: 24.0, color: Color(0xFFF05B3A))),
            ),
            decoration: const BoxDecoration(color: Color(0xFF1B263B)),
          ),
          ListTile(leading: const Icon(Icons.history), title: const Text('Mis Reservas'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()))),
          ListTile(leading: const Icon(Icons.qr_code_scanner), title: const Text('Escanear Acceso'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen()))),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red), 
            title: const Text('Cerrar Sesión'), 
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
