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
      setState(() {}); // Recarga la pantalla para mover la incidencia de pestaña
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Incidencia resuelta')));
    }
  }

  // FUNCIÓN LIGHTBOX: Mostrar la imagen en grande al hacer clic
  void _showFullImage(BuildContext context, String base64String) {
    showDialog(
      context: context,
      builder: (context) => Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.black.withOpacity(0.8)),
            ),
          ),
          InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 5.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                base64Decode(base64String),
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.8,
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 40,
            child: Material(
              color: Colors.white24,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC), // Fondo gris clarito pro
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.white,
            child: TabBar(
              indicatorColor: const Color(0xFF1E293B), // Línea inferior azul oscuro
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.dangerous, color: Colors.red), // Icono rojo
                      const SizedBox(width: 8),
                      Text('PENDIENTES', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green), // Icono verde
                      const SizedBox(width: 8),
                      Text('RESUELTAS', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: FutureBuilder<List<dynamic>>(
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

            // SEPARAMOS LAS INCIDENCIAS EN DOS LISTAS SEGÚN EL ESTADO
            final todas = snapshot.data!;
            final pendientes = todas.where((inc) => inc['estado'] == 'ABIERTA').toList();
            final resueltas = todas.where((inc) => inc['estado'] == 'RESUELTA').toList();

            return TabBarView(
              children: [
                _buildIncidentList(pendientes, isAbierta: true),
                _buildIncidentList(resueltas, isAbierta: false),
              ],
            );
          },
        ),
      ),
    );
  }

  // FUNCIÓN AUXILIAR PARA DIBUJAR LAS LISTAS FILTRADAS
  Widget _buildIncidentList(List<dynamic> lista, {required bool isAbierta}) {
    if (lista.isEmpty) {
      return Center(
        child: Text(
          isAbierta ? '🎉 ¡No hay ninguna incidencia pendiente!' : 'No hay incidencias resueltas todavía.',
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24.0),
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final incidencia = lista[index];
        String userName = incidencia['reportadoPor']?['nombre'] ?? 'Usuario Desconocido';
        String userEmail = incidencia['reportadoPor']?['email'] ?? '';
        bool hasImage = incidencia['imagenBase64'] != null && incidencia['imagenBase64'].toString().isNotEmpty;

        // Extracción y formateo de la fecha
        String fechaFormat = 'Fecha desconocida';
        // Buscamos el nombre del campo que envíe tu backend
        var fechaCruda = incidencia['fechaReporte'] ?? incidencia['fecha'] ?? incidencia['createdAt'];

        if (fechaCruda != null) {
          try {
            DateTime date = DateTime.parse(fechaCruda.toString());
            String dia = date.day.toString().padLeft(2, '0');
            String mes = date.month.toString().padLeft(2, '0');
            String hora = date.hour.toString().padLeft(2, '0');
            String min = date.minute.toString().padLeft(2, '0');
            fechaFormat = '$dia/$mes/${date.year} a las $hora:$min';
          } catch (e) {
            fechaFormat = fechaCruda.toString(); // Si falla el formateo, pinta lo que llegue
          }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Miniatura clickeable con efecto lupa
                MouseRegion(
                  cursor: hasImage ? SystemMouseCursors.click : SystemMouseCursors.basic,
                  child: GestureDetector(
                    onTap: () {
                      if (hasImage) _showFullImage(context, incidencia['imagenBase64']);
                    },
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: hasImage
                              ? Image.memory(base64Decode(incidencia['imagenBase64']), width: 90, height: 90, fit: BoxFit.cover)
                              : Container(width: 90, height: 90, color: Colors.grey[100], child: const Icon(Icons.image_not_supported, color: Colors.grey)),
                        ),
                        if (hasImage)
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                              child: const Icon(Icons.zoom_in, color: Colors.white, size: 14),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                // Detalles texto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Problema en: ${incidencia['court']?['nombre'] ?? 'Pista desconocida'}',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        incidencia['descripcion'] ?? 'Sin descripción',
                        style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 14),
                      ),
                      const SizedBox(height: 12),

                      // INFO USUARIO Y FECHA
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            userEmail.isNotEmpty ? '$userName ($userEmail)' : userName,
                            style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
                          ),
                          const SizedBox(width: 16), // Separador
                          const Icon(Icons.access_time, size: 16, color: Colors.grey), // Icono de relojito
                          const SizedBox(width: 6),
                          Text(
                            fechaFormat, // Aquí pintamos la fecha
                            style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // CHIP DE ESTADO EN ROJO Y VERDE
                      Chip(
                        label: Text(
                          incidencia['estado'],
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: isAbierta ? Colors.red[800] : Colors.green[800]),
                        ),
                        backgroundColor: isAbierta ? Colors.red[50] : Colors.green[50],
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      )
                    ],
                  ),
                ),

                // Botón Acción a la derecha
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isAbierta
                        ? ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.check, size: 18),
                      label: Text('Resolver', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      onPressed: () => _resolverIncidencia(incidencia['id']),
                    )
                        : const Padding(
                      padding: EdgeInsets.only(top: 16.0, right: 16.0),
                      child: Icon(Icons.check_circle, color: Color(0xFF10B981), size: 40),
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
}