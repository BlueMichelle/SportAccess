import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Variable para saber en qué pestaña estamos (0=Pistas, 1=Incidencias, 2=Usuarios, 3=Reservas)
  int _indiceSeleccionado = 0;

  // ==========================================
  // 1. LÓGICA DE LAS PISTAS
  // ==========================================
  Future<List<dynamic>> fetchCourts() async {
    final response = await http.get(Uri.parse('http://localhost:8080/api/courts'));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Fallo al cargar las pistas');
    }
  }

  Future<void> _eliminarPista(int id) async {
    final response = await http.delete(Uri.parse('http://localhost:8080/api/courts/$id'));
    if (response.statusCode == 200 || response.statusCode == 204) {
      setState(() {}); // Recarga la tabla
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Pista eliminada')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar: ${response.statusCode}')));
    }
  }

  void _mostrarFormularioNuevaPista() {
    final nombreCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    String tipoSeleccionado = 'PADEL';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Añadir Nueva Pista'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: precioCtrl, decoration: const InputDecoration(labelText: 'Precio/h (€)'), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: tipoSeleccionado,
                decoration: const InputDecoration(labelText: 'Deporte'),
                items: ['PADEL', 'TENIS', 'FUTBOL_SALA', 'BALONCESTO'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (v) => tipoSeleccionado = v!,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final response = await http.post(
                  Uri.parse('http://localhost:8080/api/courts'),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({"nombre": nombreCtrl.text, "tipo": tipoSeleccionado, "precioPorHora": double.tryParse(precioCtrl.text) ?? 0.0, "activa": true}),
                );
                if (response.statusCode == 201 || response.statusCode == 200) {
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // 2. LÓGICA DE INCIDENCIAS
  // ==========================================
  Future<List<dynamic>> fetchIncidents() async {
    final response = await http.get(Uri.parse('http://localhost:8080/api/incidents'));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Fallo al cargar incidencias');
    }
  }

  Future<void> _resolverIncidencia(int id) async {
    final response = await http.put(Uri.parse('http://localhost:8080/api/incidents/$id/status?newStatus=RESUELTA'));
    if (response.statusCode == 200) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Incidencia resuelta')));
    }
  }

  // ==========================================
  // 3. LÓGICA DE USUARIOS Y RESERVAS
  // ==========================================
  Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(Uri.parse('http://localhost:8080/api/users'));
    if (response.statusCode == 200) return jsonDecode(utf8.decode(response.bodyBytes));
    throw Exception('Fallo al cargar usuarios');
  }

  Future<void> _eliminarUsuario(int id) async {
    final response = await http.delete(Uri.parse('http://localhost:8080/api/users/$id'));
    if (response.statusCode == 200 || response.statusCode == 204) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('👤 Usuario eliminado')));
    }
  }

  Future<List<dynamic>> fetchReservations() async {
    final response = await http.get(Uri.parse('http://localhost:8080/api/reservations'));
    if (response.statusCode == 200) return jsonDecode(utf8.decode(response.bodyBytes));
    throw Exception('Fallo al cargar reservas');
  }

  Future<void> _eliminarReserva(int id) async {
    final response = await http.delete(Uri.parse('http://localhost:8080/api/reservations/$id'));
    if (response.statusCode == 200 || response.statusCode == 204) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📅 Reserva cancelada')));
    }
  }

  // ==========================================
  // 4. CONSTRUCCIÓN DE LA VISTA PRINCIPAL
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración PoliRent'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _indiceSeleccionado,
            onDestinationSelected: (int index) {
              setState(() { _indiceSeleccionado = index; });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.white,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.sports_tennis), label: Text('Pistas')),
              NavigationRailDestination(icon: Icon(Icons.report_problem), label: Text('Incidencias')),
              NavigationRailDestination(icon: Icon(Icons.people), label: Text('Usuarios')),
              NavigationRailDestination(icon: Icon(Icons.calendar_month), label: Text('Reservas')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // El cuerpo de la pantalla cambia según el botón seleccionado
          Expanded(child: _obtenerVistaActual()),
        ],
      ),
      floatingActionButton: _indiceSeleccionado == 0
          ? FloatingActionButton.extended(
        onPressed: _mostrarFormularioNuevaPista,
        label: const Text('Nueva Pista'),
        icon: const Icon(Icons.add),
      )
          : null,
    );
  }

  // Interruptor para cambiar de pantalla
  Widget _obtenerVistaActual() {
    switch (_indiceSeleccionado) {
      case 0: return _buildPistasView();
      case 1: return _buildIncidenciasView();
      case 2: return _buildUsuariosView();
      case 3: return _buildReservasView();
      default: return _buildPistasView();
    }
  }

  // ==========================================
  // 5. DISEÑO DE LAS TABLAS (VISTAS)
  // ==========================================

  Widget _buildPistasView() {
    return FutureBuilder<List<dynamic>>(
      future: fetchCourts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No hay pistas'));

        return ListView(
          padding: const EdgeInsets.all(32.0),
          children: [
            Card(
              elevation: 4,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Precio', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: snapshot.data!.map((c) {
                  return DataRow(cells: [
                    DataCell(Text(c['id'].toString())),
                    DataCell(Text(c['nombre'] ?? '')),
                    DataCell(Text('${c['precioPorHora']} €')),
                    DataCell(Chip(label: Text(c['activa'] ? 'Activa' : 'Inactiva'), backgroundColor: c['activa'] ? Colors.green[100] : Colors.red[100])),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminarPista(c['id']),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIncidenciasView() {
    return FutureBuilder<List<dynamic>>(
      future: fetchIncidents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('¡Genial! No hay incidencias.'));

        return ListView(
          padding: const EdgeInsets.all(32.0),
          children: snapshot.data!.map((incidencia) {
            bool isAbierta = incidencia['estado'] == 'ABIERTA';
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 4,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: (incidencia['imagenUrl'] != null && incidencia['imagenUrl'].toString().isNotEmpty)
                    ? Image.network(incidencia['imagenUrl'], width: 60, height: 60, fit: BoxFit.cover)
                    : const Icon(Icons.image_not_supported, size: 40),
                title: Text('Problema en: ${incidencia['court']?['nombre'] ?? 'Pista desconocida'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text('Descripción: ${incidencia['descripcion']}'),
                    Text('Reportado por usuario ID: ${incidencia['reportadoPor']?['id'] ?? '?'}'),
                    const SizedBox(height: 8),
                    Chip(label: Text(incidencia['estado']), backgroundColor: isAbierta ? Colors.orange[100] : Colors.green[100])
                  ],
                ),
                trailing: isAbierta
                    ? ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  icon: const Icon(Icons.check),
                  label: const Text('Resolver'),
                  onPressed: () => _resolverIncidencia(incidencia['id']),
                )
                    : const Icon(Icons.check_circle, color: Colors.green, size: 32),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildUsuariosView() {
    return FutureBuilder<List<dynamic>>(
      future: fetchUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text('Aún no hay conexión con Usuarios.'));
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No hay usuarios registrados'));

        return ListView(
          padding: const EdgeInsets.all(32.0),
          children: [
            Card(
              elevation: 4,
              child: DataTable(
                // ... dentro de tu DataTable de usuarios ...
                columns: const [
                  DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Rol', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))), // NUEVA
                ],
                rows: snapshot.data!.map((u) {
                  return DataRow(cells: [
                    DataCell(Text(u['id'].toString())),
                    DataCell(Text(u['nombre'] ?? 'Sin nombre')),
                    DataCell(Text(u['email'] ?? '')),
                    DataCell(Chip(label: Text(u['rol'] ?? 'USER'), backgroundColor: Colors.blueGrey[100])),
                    DataCell( // BOTÓN NUEVO
                      IconButton(
                        icon: const Icon(Icons.person_remove, color: Colors.red),
                        onPressed: () => _eliminarUsuario(u['id']),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReservasView() {
    return FutureBuilder<List<dynamic>>(
      future: fetchReservations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text('Aún no hay conexión con Reservas.'));
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No hay reservas activas'));

        return ListView(
          padding: const EdgeInsets.all(32.0),
          children: snapshot.data!.map((reserva) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 4,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const Icon(Icons.event_available, color: Colors.blue, size: 40),
                title: Text('Reserva #${reserva['id']} - Pista: ${reserva['court']?['nombre'] ?? '?'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Usuario: ${reserva['user']?['nombre'] ?? '?'} \nFecha: ${reserva['fechaHoraInicio']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text(reserva['estado'] ?? 'CONFIRMADA'),
                      backgroundColor: Colors.blue[100],
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      tooltip: 'Cancelar Reserva',
                      onPressed: () => _eliminarReserva(reserva['id']),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}