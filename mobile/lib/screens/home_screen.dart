import 'package:flutter/material.dart';
import 'package:app/models/models.dart';
import 'package:app/screens/booking_screen.dart';
import 'package:app/screens/history_screen.dart';
import 'package:app/screens/scanner_screen.dart';
import 'package:app/screens/login_screen.dart';
import 'package:app/services/api_service.dart';
import 'package:app/main.dart';

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
        _courts    = apiCourts;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCourts = _courts.where((c) {
      final q = _searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
             c.location.toLowerCase().contains(q) ||
             c.sports.any((s) => s.toLowerCase().contains(q));
    }).toList();

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kCard,
        title: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [kPrimary, Color(0xFFFF8C42)]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.sports_tennis, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('SportAccess', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kTextPri)),
          ],
        ),
        actions: [
          _navBtn(Icons.qr_code_scanner, 'Escanear QR', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen()))),
          _navBtn(Icons.history, 'Mis Reservas', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()))),
          const SizedBox(width: 4),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          // ── Buscador ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            color: kCard,
            child: Container(
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kBorder),
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(color: kTextPri),
                decoration: const InputDecoration(
                  hintText: 'Buscar pista o deporte...',
                  hintStyle: TextStyle(color: kTextSec),
                  prefixIcon: Icon(Icons.search, color: kTextSec),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // ── Subtítulo ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Text('Instalaciones disponibles', style: TextStyle(color: kTextSec, fontSize: 13, fontWeight: FontWeight.w600)),
                const Spacer(),
                if (!_isLoading)
                  Text('${filteredCourts.length} pistas', style: const TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // ── Lista ────────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: kPrimary))
                : filteredCourts.isEmpty
                    ? const Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 56, color: kTextSec),
                          SizedBox(height: 12),
                          Text('Sin resultados', style: TextStyle(color: kTextSec)),
                        ],
                      ))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        itemCount: filteredCourts.length,
                        itemBuilder: (ctx, i) => _buildCourtCard(ctx, filteredCourts[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon, String tooltip, VoidCallback onTap) {
    return IconButton(icon: Icon(icon, color: kPrimary), tooltip: tooltip, onPressed: onTap);
  }

  Widget _buildCourtCard(BuildContext context, Court court) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(court: court))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kBorder, width: 0.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Imagen
              Hero(
                tag: 'court-${court.id}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), bottomLeft: Radius.circular(18)),
                  child: SizedBox(
                    width: 95,
                    child: Image.network(
                      court.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: kSurface,
                        child: const Icon(Icons.sports_tennis, color: kPrimary, size: 32),
                      ),
                    ),
                  ),
                ),
              ),

              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(court.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kTextPri)),
                      const SizedBox(height: 5),
                      Row(children: [
                        const Icon(Icons.location_on, size: 12, color: kTextSec),
                        const SizedBox(width: 4),
                        Expanded(child: Text(court.location, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: kTextSec))),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: kPrimary.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                          child: Text('${court.pricePerHour.toStringAsFixed(2)}€/h', style: const TextStyle(color: kPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        const SizedBox(width: 8),
                        if (court.sports.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: kBorder)),
                            child: Text(court.sports.first, style: const TextStyle(color: kTextSec, fontSize: 10)),
                          ),
                      ]),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.chevron_right, color: kTextSec, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: kCard,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(loggedUserName, style: const TextStyle(fontWeight: FontWeight.bold, color: kTextPri)),
            accountEmail: Text(loggedUserEmail, style: const TextStyle(color: kTextSec)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: kPrimary.withOpacity(0.2),
              child: Text(
                loggedUserName.isNotEmpty ? loggedUserName[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 24, color: kPrimary, fontWeight: FontWeight.bold),
              ),
            ),
            decoration: BoxDecoration(
              color: kBg,
              border: const Border(bottom: BorderSide(color: kBorder)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history, color: kTextSec),
            title: const Text('Mis Reservas', style: TextStyle(color: kTextPri)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner, color: kTextSec),
            title: const Text('Escanear Acceso', style: TextStyle(color: kTextPri)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen())),
          ),
          const Spacer(),
          const Divider(color: kBorder),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFFF85149)),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Color(0xFFF85149))),
            onTap: () {
              loggedUserName  = '';
              loggedUserEmail = '';
              saveData();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
