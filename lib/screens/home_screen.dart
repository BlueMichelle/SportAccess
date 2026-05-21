import 'package:flutter/material.dart';
import 'package:app/models/models.dart';
import 'package:app/screens/booking_screen.dart';
import 'package:app/screens/history_screen.dart';
import 'package:app/screens/scanner_screen.dart';
import 'package:app/screens/login_screen.dart';
import 'package:app/services/api_service.dart';
import 'package:app/screens/contact_screen.dart';
import 'package:app/screens/report_incident_screen.dart';
import 'package:app/screens/location_screen.dart';
import 'package:app/screens/community_screen.dart';
import 'package:app/screens/live_match_screen.dart';
import 'package:app/screens/profile_screen.dart';

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
      final apiCourts = await ApiService().getCourts();
      if (mounted) {
        setState(() {
          _courts = apiCourts;
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Court> filteredCourts = _courts.where((Court court) {
      final queryLower = _searchQuery.toLowerCase();
      final matchesSearch = court.name.toLowerCase().contains(queryLower) ||
          court.location.toLowerCase().contains(queryLower);
      final matchesSport = _selectedSport == 'Todos' || court.sports.contains(_selectedSport);
      return matchesSearch && matchesSport;
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'SportAccess',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Color(0xFFF05B3A)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.location_on, color: Color(0xFFF05B3A)),
            tooltip: 'Nuestra Ubicación',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LocationScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Color(0xFFF05B3A)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.report_problem_outlined, color: Color(0xFFF05B3A)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReportIncidentScreen()),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BARRA DE BÚSQUEDA
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            color: colorScheme.surface,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? colorScheme.surfaceVariant : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Buscar instalación...',
                  hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                  prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.5)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          // FILTROS DE DEPORTE
          Container(
            color: colorScheme.surface,
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
                      label: Text(
                        sport,
                        style: TextStyle(
                          color: isSelected ? Colors.white : colorScheme.onSurface,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFFF05B3A),
                      backgroundColor: isDark ? colorScheme.surfaceVariant : null,
                      onSelected: (bool selected) {
                        setState(() => _selectedSport = sport);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          // LISTA DE PISTAS
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFF05B3A)))
                : filteredCourts.isEmpty
                ? Center(
              child: Text(
                'No hay pistas disponibles',
                style: TextStyle(color: colorScheme.onSurface),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredCourts.length,
              itemBuilder: (context, index) =>
                  _buildPremiumCourtCard(context, filteredCourts[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCourtCard(BuildContext context, Court court) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => BookingScreen(court: court))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'court-${court.id}',
                child: Image.network(
                  "${court.imageUrl}?t=${DateTime.now().millisecondsSinceEpoch}",
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, e, s) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.sports_tennis, size: 64, color: Colors.grey),
                  ),
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
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF05B3A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${court.pricePerHour.toStringAsFixed(2)}€ /h',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      court.name,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            court.location,
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              loggedUserName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(loggedUserEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                loggedUserName.isNotEmpty ? loggedUserName[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 24.0, color: Color(0xFFF05B3A)),
              ),
            ),
            // Usamos el color secondary del tema (azul oscuro en claro, naranja en oscuro)
            decoration: BoxDecoration(color: colorScheme.secondary),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.indigo),
            title: const Text('Mi Perfil y Estadísticas',
                style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Mis Reservas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('Escanear Acceso'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const ScannerScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Contacto y FAQ'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const ContactScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.report_problem_outlined, color: Color(0xFFF05B3A)),
            title: const Text('Reportar Incidencia'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ReportIncidentScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.people_alt, color: Colors.green),
            title: const Text('Comunidad y Eventos',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Partidas abiertas y torneos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CommunityScreen()));
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              loggedUserName = "";
              loggedUserEmail = "";
              saveData();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}