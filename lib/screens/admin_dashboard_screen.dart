import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/home_view.dart'; // 🔴 Importamos la nueva vista
import '../widgets/courts_view.dart';
import '../widgets/incidents_view.dart';
import '../widgets/users_view.dart';
import '../widgets/reservations/reservations_view.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _indiceSeleccionado = 0;
  final Color _primaryColor = const Color(0xFF1E293B);
  final Color _accentColor = const Color(0xFFE63946);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Row(
        children: [
          // 🛠️ Menú Lateral
          Container(
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(2, 0))],
            ),
            child: NavigationRail(
              selectedIndex: _indiceSeleccionado,
              onDestinationSelected: (int index) {
                setState(() { _indiceSeleccionado = index; });
              },
              backgroundColor: Colors.white,
              indicatorColor: _accentColor.withOpacity(0.1),
              selectedIconTheme: IconThemeData(color: _accentColor, size: 28),
              unselectedIconTheme: const IconThemeData(color: Colors.grey, size: 24),
              selectedLabelTextStyle: GoogleFonts.poppins(color: _accentColor, fontWeight: FontWeight.bold),
              unselectedLabelTextStyle: GoogleFonts.poppins(color: Colors.grey),
              extended: true,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  children: [
                    Icon(Icons.sports_score, size: 48, color: _primaryColor),
                    const SizedBox(height: 8),
                    Text('PoliRent', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w900, color: _primaryColor)),
                    Text('Admin Panel', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, letterSpacing: 1.5)),
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Inicio')),
                NavigationRailDestination(icon: Icon(Icons.sports_tennis_outlined), selectedIcon: Icon(Icons.sports_tennis), label: Text('Pistas')),
                NavigationRailDestination(icon: Icon(Icons.report_problem_outlined), selectedIcon: Icon(Icons.report_problem), label: Text('Incidencias')),
                NavigationRailDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: Text('Usuarios')),
                NavigationRailDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: Text('Reservas')),
              ],
            ),
          ),
          // 🛠️ Cuerpo Principal
          Expanded(
            child: Column(
              children: [
                // Cabecera Superior
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getTituloPantalla(),
                        style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: _primaryColor),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.notifications_none, color: Colors.grey),
                          const SizedBox(width: 24),
                          CircleAvatar(backgroundColor: _primaryColor, child: const Text('AD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          const SizedBox(width: 12),
                          Text('Admin', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        ],
                      )
                    ],
                  ),
                ),
                // Contenido dinámico inyectado aquí
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _obtenerVistaActual(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTituloPantalla() {
    switch (_indiceSeleccionado) {
      case 0: return 'Resumen General';
      case 1: return 'Gestión de Pistas';
      case 2: return 'Control de Incidencias';
      case 3: return 'Directorio de Usuarios';
      case 4: return 'Calendario de Reservas';
      default: return 'Panel';
    }
  }

  Widget _obtenerVistaActual() {
    switch (_indiceSeleccionado) {
      case 0: return const HomeView(); // 🔴 Queda igual de limpio que antes
      case 1: return const CourtsView();
      case 2: return const IncidentsView();
      case 3: return const UsersView();
      case 4: return const ReservationsView();
      default: return const HomeView();
    }
  }
}