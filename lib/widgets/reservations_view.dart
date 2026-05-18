import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReservationsView extends StatefulWidget {
  const ReservationsView({Key? key}) : super(key: key);

  @override
  State<ReservationsView> createState() => _ReservationsViewState();
}

class _ReservationsViewState extends State<ReservationsView> {
  final String baseUrl = 'http://localhost:8080/api';

  Future<List<dynamic>> fetchReservations() async {
    final response = await http.get(Uri.parse('$baseUrl/reservations'));
    if (response.statusCode == 200) return jsonDecode(utf8.decode(response.bodyBytes));
    throw Exception('Error al cargar reservas');
  }

  Future<List<dynamic>> fetchUsers() async => jsonDecode(utf8.decode((await http.get(Uri.parse('$baseUrl/users'))).bodyBytes));
  Future<List<dynamic>> fetchCourts() async => jsonDecode(utf8.decode((await http.get(Uri.parse('$baseUrl/courts'))).bodyBytes));

  Future<void> _deleteReservation(int id) async {
    bool confirm = await _showConfirmDialog();
    if (!confirm) return;

    final response = await http.delete(Uri.parse('$baseUrl/reservations/$id'));
    if (response.statusCode == 200 || response.statusCode == 204) {
      setState(() {});
      _showSnackBar('📅 Reserva cancelada correctamente');
    }
  }

  // 🛠️ Pasamos la lista de todas las reservas para saber qué horas están ocupadas
  void _showReservationForm(List<dynamic> allReservations, {Map<String, dynamic>? reservation}) async {
    final isEditing = reservation != null;

    final users = await fetchUsers();
    final courts = await fetchCourts();

    int? selectedUserId = reservation?['user']?['id'] as int?;
    int? selectedCourtId = reservation?['court']?['id'] as int?;
    bool hasReferee = reservation?['arbitro'] as bool? ?? false;
    String score = reservation?['resultado']?.toString() ?? '';
    final scoreCtrl = TextEditingController(text: score);

    // Variables para el nuevo calendario interactivo
    DateTime? selectedDate;
    String? selectedTime;

    if (isEditing && reservation?['fechaHoraInicio'] != null) {
      final dateTimeParts = reservation!['fechaHoraInicio'].toString().split('T');
      selectedDate = DateTime.tryParse(dateTimeParts[0]);
      if (dateTimeParts.length > 1) {
        selectedTime = dateTimeParts[1].substring(0, 5); // Coge "10:00" de "10:00:00"
      }
    }

    // Todas las horas posibles de apertura del polideportivo
    final List<String> allHours = [
      '09:00', '10:00', '11:00', '12:00',
      '16:00', '17:00', '18:00', '19:00', '20:00', '21:00'
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setDialogState) {

              // Función interna para calcular qué horas están ocupadas para el día y pista seleccionados
              List<String> getOccupiedHours() {
                if (selectedDate == null || selectedCourtId == null) return [];

                String dateStr = "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

                return allReservations.where((res) {
                  // Ignoramos la reserva actual si estamos editando (para no bloquear nuestra propia hora)
                  if (isEditing && res['id'] == reservation['id']) return false;

                  bool isSameCourt = res['court']?['id'] == selectedCourtId;
                  bool isSameDay = res['fechaHoraInicio'].toString().startsWith(dateStr);
                  return isSameCourt && isSameDay;
                }).map((res) {
                  // Extraemos la hora "HH:MM"
                  return res['fechaHoraInicio'].toString().split('T')[1].substring(0, 5);
                }).toList();
              }

              final occupiedHours = getOccupiedHours();

              return AlertDialog(
                title: Text(isEditing ? 'Editar Reserva #${reservation['id']}' : 'Nueva Reserva Manual', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                content: SizedBox(
                  width: 400, // Le damos un poco más de anchura para el calendario
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<int>(
                          value: selectedUserId,
                          decoration: const InputDecoration(labelText: 'Usuario', border: OutlineInputBorder()),
                          items: users.map((u) => DropdownMenuItem<int>(value: u['id'], child: Text(u['nombre'] ?? 'Sin nombre'))).toList(),
                          onChanged: (val) => setDialogState(() => selectedUserId = val),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: selectedCourtId,
                          decoration: const InputDecoration(labelText: 'Pista', border: OutlineInputBorder()),
                          items: courts.map((c) => DropdownMenuItem<int>(value: c['id'], child: Text(c['nombre'] ?? 'Pista'))).toList(),
                          // Si cambiamos la pista, reseteamos la hora porque cambian las disponibilidades
                          onChanged: (val) => setDialogState(() {
                            selectedCourtId = val;
                            selectedTime = null;
                          }),
                        ),
                        const SizedBox(height: 24),

                        // 🛠️ BOTÓN DEL CALENDARIO
                        Text('Fecha del Partido', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.grey[700])),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime.now(), // No dejar reservar en el pasado
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                selectedDate = picked;
                                selectedTime = null; // Reseteamos la hora al cambiar de día
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedDate != null
                                      ? "${selectedDate!.day.toString().padLeft(2,'0')}/${selectedDate!.month.toString().padLeft(2,'0')}/${selectedDate!.year}"
                                      : "Seleccionar día en el calendario...",
                                  style: TextStyle(color: selectedDate != null ? Colors.black : Colors.grey[600], fontSize: 16),
                                ),
                                const Icon(Icons.calendar_month, color: Colors.blue),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 🛠️ SELECTOR INTERACTIVO DE HORAS
                        if (selectedDate != null && selectedCourtId != null) ...[
                          Text('Horas Disponibles', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.grey[700])),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: allHours.map((hour) {
                              bool isOccupied = occupiedHours.contains(hour);
                              bool isSelected = selectedTime == hour;

                              return ChoiceChip(
                                label: Text(hour, style: TextStyle(color: isOccupied ? Colors.white : (isSelected ? Colors.white : Colors.black))),
                                selected: isSelected,
                                // Si está ocupado es rojo, si está seleccionado es azul, si está libre es gris claro
                                selectedColor: Colors.blue,
                                disabledColor: Colors.red[400],
                                backgroundColor: Colors.grey[200],
                                onSelected: isOccupied ? null : (bool selected) {
                                  setDialogState(() {
                                    selectedTime = selected ? hour : null;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ] else if (selectedCourtId == null) ...[
                          Text('Selecciona una pista para ver las horas libres.', style: TextStyle(color: Colors.orange[800], fontStyle: FontStyle.italic)),
                        ],

                        const SizedBox(height: 24),
                        CheckboxListTile(
                          title: const Text('Solicitar Árbitro (+15€)', style: TextStyle(fontWeight: FontWeight.bold)),
                          value: hasReferee,
                          activeColor: Colors.red,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) => setDialogState(() => hasReferee = val!),
                        ),
                        if (isEditing)
                          TextField(
                            controller: scoreCtrl,
                            decoration: const InputDecoration(labelText: 'Resultado (ej: 6-2, 3-0)', border: OutlineInputBorder()),
                          ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
                    onPressed: () async {
                      if (selectedUserId == null || selectedCourtId == null || selectedDate == null || selectedTime == null) {
                        _showSnackBar('Por favor, selecciona todos los campos');
                        return;
                      }

                      // 1. Formateo de fechas
                      String dia = selectedDate!.day.toString().padLeft(2, '0');
                      String mes = selectedDate!.month.toString().padLeft(2, '0');
                      String anio = selectedDate!.year.toString();

                      String fechaInicio = "$anio-$mes-$dia" + "T" + "$selectedTime:00";

                      int horaFinInt = int.parse(selectedTime!.split(':')[0]) + 1;
                      String horaFin = horaFinInt.toString().padLeft(2, '0') + ":00:00";
                      String fechaFin = "$anio-$mes-$dia" + "T" + horaFin;

                      // 2. EL TRUCO DE LA APP MÓVIL
                      String detalles = hasReferee ? "Árbitro Oficial" : "Sin material";
                      double precioExtra = hasReferee ? 15.0 : 0.0;

                      // 3. BUSCAMOS AL USUARIO COMPLETO PARA SACAR SUS CREDENCIALES
                      // (users es la lista que descargamos al principio con fetchUsers)
                      final usuarioSeleccionado = users.firstWhere((u) => u['id'] == selectedUserId);

                      // 4. Empaquetamos todo con el MISMO FORMATO que payment_screen.dart
                      final datosReserva = {
                        "user": {
                          "id": selectedUserId, // Mantenemos el ID por si acaso
                          "firebaseUid": usuarioSeleccionado['firebase_uid'] ?? usuarioSeleccionado['firebaseUid'] ?? "12345",
                          "email": usuarioSeleccionado['email'] ?? "sin_email@app.com",
                          "nombre": usuarioSeleccionado['nombre'] ?? "Usuario Manual"
                        },
                        "court": {"id": selectedCourtId},
                        "fechaInicio": fechaInicio,
                        "fechaFin": fechaFin,
                        "resultadoPartido": scoreCtrl.text,
                        "estado": "CONFIRMADA",
                        "precioMaterial": precioExtra,
                        "detallesMaterial": detalles
                      };

                      try {
                        final respuesta = await http.post(
                          Uri.parse('http://localhost:8080/api/reservations'),
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode(datosReserva),
                        );

                        if (respuesta.statusCode == 200 || respuesta.statusCode == 201) {
                          Navigator.pop(context); // Cerramos el popup
                          setState(() {}); // Recargamos la tabla
                          _showSnackBar('✅ Reserva guardada con éxito');
                        } else {
                          print("Fallo del servidor: ${respuesta.body}");
                          _showSnackBar('Error: Verifica los datos. (Mira la consola)');
                        }
                      } catch (e) {
                        _showSnackBar('Error de conexión con el servidor');
                      }
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<List<dynamic>>(
        future: fetchReservations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text('No hay reservas registradas.', style: GoogleFonts.poppins(fontSize: 16)));

          final reservationsList = snapshot.data!;

          return ListView.builder(
            itemCount: reservationsList.length,
            itemBuilder: (context, index) {
              final res = reservationsList[index];
              bool needsReferee = res['arbitro'] ?? false;
              String result = res['resultado'] ?? '';

              // Formateo de fecha visual (de "YYYY-MM-DDT10:00:00" a "DD/MM/YYYY a las 10:00")
              String displayDate = res['fechaHoraInicio'].toString();
              if (displayDate.contains('T')) {
                final parts = displayDate.split('T');
                final dateParts = parts[0].split('-');
                if (dateParts.length == 3) {
                  displayDate = "${dateParts[2]}/${dateParts[1]}/${dateParts[0]} a las ${parts[1].substring(0,5)}";
                }
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange[50],
                    child: const Icon(Icons.calendar_today, color: Colors.orange),
                  ),
                  title: Text(
                    '${res['court']?['nombre'] ?? 'Pista'} - ${res['user']?['nombre'] ?? 'Usuario'}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(displayDate),
                      if (result.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.blueGrey[50], borderRadius: BorderRadius.circular(4)),
                          child: Text('Marcador Final: $result', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey[800])),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (needsReferee)
                        const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Tooltip(message: 'Árbitro solicitado', child: Icon(Icons.sports_rounded, color: Colors.redAccent, size: 28)),
                        ),
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showReservationForm(reservationsList, reservation: res)),
                      IconButton(icon: const Icon(Icons.cancel, color: Colors.red), onPressed: () => _deleteReservation(res['id'])),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FutureBuilder<List<dynamic>>(
        // Para el FAB de crear, también necesitamos pasar todas las reservas para la comprobación
          future: fetchReservations(),
          builder: (context, snapshot) {
            return FloatingActionButton.extended(
              onPressed: () => _showReservationForm(snapshot.data ?? []),
              label: const Text('Añadir Reserva'),
              icon: const Icon(Icons.add),
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: Colors.white,
            );
          }
      ),
    );
  }

  Future<bool> _showConfirmDialog() async {
    return await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Anular reserva?'),
        content: const Text('Esta acción notificará al usuario y liberará la pista.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Volver')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), child: const Text('Anular')),
        ],
      ),
    ) ?? false;
  }

  void _showSnackBar(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}