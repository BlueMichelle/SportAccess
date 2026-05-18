import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CourtsView extends StatefulWidget {
  const CourtsView({Key? key}) : super(key: key);

  @override
  State<CourtsView> createState() => _CourtsViewState();
}

class _CourtsViewState extends State<CourtsView> {
  final String baseUrl = 'http://localhost:8080/api/courts';

  Future<List<dynamic>> fetchCourts() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Error al cargar pistas');
  }

  Future<void> _deleteCourt(int id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Borrar pista?'),
        content: const Text('Si borras esta pista, podrían fallar las reservas asociadas. Es mejor "Desactivarla" si no quieres que se use.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Borrar definitivamente'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200 || response.statusCode == 204) {
      setState(() {});
      _showSnackBar('🗑️ Pista borrada correctamente');
    } else {
      _showSnackBar('Error al borrar. ¿Tiene reservas asociadas?');
    }
  }

  Future<void> _toggleStatus(Map<String, dynamic> court) async {
    bool nuevoEstado = !(court['activa'] ?? true);

    // CORRECCIÓN 1: Usamos imagen_url con barra baja
    final datosActualizados = {
      "id": court['id'],
      "nombre": court['nombre'],
      "precioPorHora": court['precioPorHora'] ?? 0.0,
      "descripcion": court['descripcion'] ?? "",
      "imagen_url": court['imagen_url'] ?? "",
      "activa": nuevoEstado,
      "tipo": court['tipo'] ?? "PADEL"
    };

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${court['id']}'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(datosActualizados),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {});
        _showSnackBar(nuevoEstado ? '✅ Pista Activada' : '⏸️ Pista Desactivada');
      } else {
        print("Fallo al cambiar estado: ${response.body}");
        _showSnackBar('Error al cambiar el estado. Mira la consola.');
      }
    } catch (e) {
      _showSnackBar('Error de conexión con el servidor');
    }
  }

  void _showCourtForm({Map<String, dynamic>? court}) {
    final isEditing = court != null;

    final nameCtrl = TextEditingController(text: court?['nombre'] ?? '');
    final priceCtrl = TextEditingController(text: court?['precioPorHora']?.toString() ?? '');
    final descCtrl = TextEditingController(text: court?['descripcion'] ?? '');
    // CORRECCIÓN 1: Leemos la imagen con barra baja
    final imageCtrl = TextEditingController(text: court?['imagen_url'] ?? '');

    bool isActive = court?['activa'] ?? true;

    // CORRECCIÓN 2: Lista cerrada de deportes para no romper el Enum de Java
    final List<String> tiposPermitidos = ['PADEL', 'TENIS', 'FUTBOL_SALA', 'BALONCESTO'];
    String selectedType = court?['tipo'] ?? 'PADEL';

    if (!tiposPermitidos.contains(selectedType)) {
      selectedType = 'PADEL';
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Editar Pista' : 'Nueva Pista', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre de la pista (Ej: Pádel Premium)', border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Precio (€)', border: OutlineInputBorder()))),
                          const SizedBox(width: 12),
                          // CORRECCIÓN 2: Desplegable seguro
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedType,
                              decoration: const InputDecoration(labelText: 'Deporte', border: OutlineInputBorder()),
                              items: tiposPermitidos.map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo))).toList(),
                              onChanged: (val) => setDialogState(() => selectedType = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción / Ubicación', border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: 'URL de la imagen (Link)', border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Pista Activa (Visible en la app)'),
                        value: isActive,
                        activeColor: Colors.green,
                        onChanged: (val) => setDialogState(() => isActive = val),
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) {
                      _showSnackBar('Nombre y Precio son obligatorios');
                      return;
                    }

                    final datosPista = {
                      "nombre": nameCtrl.text,
                      "precioPorHora": double.tryParse(priceCtrl.text) ?? 0.0,
                      "descripcion": descCtrl.text,
                      "imagen_url": imageCtrl.text, // Enviamos con barra baja
                      "activa": isActive,
                      "tipo": selectedType // Enviamos la opción del desplegable
                    };

                    final url = isEditing ? '$baseUrl/${court['id']}' : baseUrl;
                    final response = await (isEditing ? http.put : http.post)(
                      Uri.parse(url),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode(datosPista),
                    );

                    if (response.statusCode == 200 || response.statusCode == 201) {
                      Navigator.pop(context);
                      setState(() {});
                      _showSnackBar(isEditing ? '✅ Pista actualizada' : '✅ Pista creada');
                    } else {
                      print("Error del servidor: ${response.body}");
                      _showSnackBar('Error: Verifica la consola');
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<List<dynamic>>(
        future: fetchCourts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));

          final courts = snapshot.data ?? [];

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: DataTable(
              headingTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87),
              dataTextStyle: GoogleFonts.poppins(color: Colors.black87),
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Nombre')),
                DataColumn(label: Text('Precio')),
                DataColumn(label: Text('Tipo')),
                DataColumn(label: Text('Estado')),
                DataColumn(label: Text('Acciones')),
              ],
              rows: courts.map((court) {
                bool activa = court['activa'] ?? true;
                String precio = court['precioPorHora']?.toString() ?? '0';
                String tipo = court['tipo'] ?? '-';

                return DataRow(
                  cells: [
                    DataCell(Text(court['id'].toString())),
                    DataCell(Text(court['nombre'] ?? 'Sin nombre')),
                    DataCell(Text('$precio €')),
                    DataCell(Text(tipo)),
                    DataCell(
                      InkWell(
                        onTap: () => _toggleStatus(court),
                        child: Chip(
                          label: Text(activa ? 'Activa' : 'Inactiva', style: TextStyle(color: activa ? Colors.green[800] : Colors.red[800], fontSize: 12, fontWeight: FontWeight.bold)),
                          backgroundColor: activa ? Colors.green[100] : Colors.red[100],
                          side: BorderSide.none,
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'Editar',
                            onPressed: () => _showCourtForm(court: court),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Borrar',
                            onPressed: () => _deleteCourt(court['id']),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCourtForm(),
        label: const Text('Nueva Pista'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showSnackBar(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}