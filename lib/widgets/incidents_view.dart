import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IncidentsView extends StatefulWidget {
  const IncidentsView({Key? key}) : super(key: key);

  @override
  State<IncidentsView> createState() => _IncidentsViewState();
}

class _IncidentsViewState extends State<IncidentsView> {
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchIncidents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: GoogleFonts.poppins(color: Colors.red)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('¡Genial! No hay incidencias.', style: GoogleFonts.poppins(fontSize: 16)));
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 32.0),
          children: snapshot.data!.map((incidencia) {
            bool isAbierta = incidencia['estado'] == 'ABIERTA';

            // Extraemos el nombre y el email para que sea profesional
            String userName = incidencia['reportadoPor']?['nombre'] ?? 'Usuario Desconocido';
            String userEmail = incidencia['reportadoPor']?['email'] ?? '';

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen en Base64
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: (incidencia['imagenBase64'] != null && incidencia['imagenBase64'].toString().isNotEmpty)
                          ? Image.memory(base64Decode(incidencia['imagenBase64']), width: 80, height: 80, fit: BoxFit.cover)
                          : Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.image_not_supported, color: Colors.grey)),
                    ),
                    const SizedBox(width: 20),

                    // Contenido
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Problema en: ${incidencia['court']?['nombre'] ?? 'Pista desconocida'}',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            incidencia['descripcion'] ?? 'Sin descripción',
                            style: GoogleFonts.poppins(color: Colors.grey[800]),
                          ),
                          const SizedBox(height: 8),
                          // 🛠️ AQUÍ ESTÁ EL CAMBIO PROFESIONAL
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                userEmail.isNotEmpty ? '$userName ($userEmail)' : userName,
                                style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Chip(
                            label: Text(incidencia['estado'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12, color: isAbierta ? Colors.orange[800] : Colors.green[800])),
                            backgroundColor: isAbierta ? Colors.orange[100] : Colors.green[100],
                            side: BorderSide.none,
                          )
                        ],
                      ),
                    ),

                    // Botón de Acción
                    Column(
                      children: [
                        isAbierta
                            ? ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981), // Verde esmeralda pro
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.check, size: 18),
                          label: Text('Resolver', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          onPressed: () => _resolverIncidencia(incidencia['id']),
                        )
                            : const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 36),
                      ],
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