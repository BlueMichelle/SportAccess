import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

final String baseUrl = 'http://localhost:8080/api';

Future<void> showReservationForm(
    BuildContext context,
    List<dynamic> allReservations,
    VoidCallback onSaved,
    {
      Map<String, dynamic>? reservaEdit,
      DateTime? fechaInicial,
      String? horaInicial,
      int? pistaInicial,
    }
    ) async {
  final isEditing = reservaEdit != null;
  final usersRes = await http.get(Uri.parse('$baseUrl/users'));
  final courtsRes = await http.get(Uri.parse('$baseUrl/courts'));

  final users = jsonDecode(utf8.decode(usersRes.bodyBytes)) as List<dynamic>;
  final courts = jsonDecode(utf8.decode(courtsRes.bodyBytes)) as List<dynamic>;

  bool isGuest = isEditing ? (reservaEdit['user'] == null) : false;
  final guestNameCtrl = TextEditingController(text: isEditing ? reservaEdit['nombreInvitado'] : '');
  String metodoPago = isEditing ? (reservaEdit['metodoPago'] ?? 'TARJETA') : 'TARJETA';
  String estadoPago = isEditing ? (reservaEdit['estadoPago'] ?? 'PAGADO') : 'PAGADO';
  int semanasRepeticion = 1;

  int? selectedUserId;
  int? selectedCourtId = pistaInicial;

  DateTime? formSelectedDate = fechaInicial ?? DateTime.now();
  String? formSelectedTime = horaInicial;

  if (isEditing && reservaEdit != null) {
    if (reservaEdit['user'] != null) selectedUserId = reservaEdit['user']['id'] as int?;
    if (reservaEdit['court'] != null) selectedCourtId = reservaEdit['court']['id'] as int?;

    if (reservaEdit['fechaInicio'] != null) {
      final parts = reservaEdit['fechaInicio'].toString().split('T');
      formSelectedDate = DateTime.tryParse(parts[0]);
      if (parts.length > 1) formSelectedTime = parts[1].substring(0, 5);
    }
  }

  final List<String> allHours = ['09:00', '10:00', '11:00', '12:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00'];

  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
          builder: (context, setDialogState) {
            List<String> getOccupiedHours() {
              if (formSelectedDate == null || selectedCourtId == null) return [];
              String dateStr = DateFormat('yyyy-MM-dd').format(formSelectedDate!);
              return allReservations.where((res) {
                if (isEditing && res['id'] == reservaEdit['id']) return false;
                bool isSameCourt = res['court']?['id'] == selectedCourtId;
                bool isSameDay = res['fechaInicio'].toString().startsWith(dateStr);
                return isSameCourt && isSameDay;
              }).map((res) => res['fechaInicio'].toString().split('T')[1].substring(0, 5)).toList();
            }

            final occupiedHours = getOccupiedHours();

            return AlertDialog(
              title: Text(isEditing ? 'Editar Reserva' : 'Nueva Reserva', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 550, // Lo he hecho un pelín más ancho para que quepan los 3 campos bien
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isEditing)
                        Row(
                          children: [
                            Expanded(child: RadioListTile<bool>(title: const Text('Usuario App'), value: false, groupValue: isGuest, onChanged: (val) => setDialogState(() => isGuest = val!))),
                            Expanded(child: RadioListTile<bool>(title: const Text('Invitado (Manual)'), value: true, groupValue: isGuest, onChanged: (val) => setDialogState(() => isGuest = val!))),
                          ],
                        ),
                      if (!isGuest)
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          value: selectedUserId,
                          decoration: const InputDecoration(labelText: 'Usuario Registrado', border: OutlineInputBorder()),
                          items: users.map((u) => DropdownMenuItem<int>(value: u['id'], child: Text(u['nombre'] ?? 'Sin nombre'))).toList(),
                          onChanged: (val) => setDialogState(() => selectedUserId = val),
                        )
                      else
                        TextField(
                          controller: guestNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nombre y Apellidos del Invitado',
                            hintText: 'Ej. Juan Pérez',
                            prefixIcon: Icon(Icons.person_outline, color: Colors.blueGrey),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // ✨ FILA MODIFICADA CON EL ESTADO DE PAGO
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: DropdownButtonFormField<int>(
                              isExpanded: true,
                              value: selectedCourtId,
                              decoration: const InputDecoration(labelText: 'Pista', border: OutlineInputBorder()),
                              items: courts.map((c) => DropdownMenuItem<int>(value: c['id'], child: Text(c['nombre'] ?? 'Pista'))).toList(),
                              onChanged: (val) => setDialogState(() { selectedCourtId = val; formSelectedTime = null; }),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: metodoPago, decoration: const InputDecoration(labelText: 'Método', border: OutlineInputBorder()),
                              items: ['TARJETA', 'EFECTIVO'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                              onChanged: (val) => setDialogState(() => metodoPago = val!),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: estadoPago, decoration: const InputDecoration(labelText: 'Estado', border: OutlineInputBorder()),
                              items: ['PAGADO', 'PENDIENTE'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (val) => setDialogState(() => estadoPago = val!),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      Text('Fecha de Inicio', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(context: context, initialDate: formSelectedDate ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                          if (picked != null) setDialogState(() { formSelectedDate = picked; formSelectedTime = null; });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey[400]!), borderRadius: BorderRadius.circular(4)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(formSelectedDate != null ? DateFormat('dd/MM/yyyy').format(formSelectedDate!) : "Seleccionar día..."),
                              const Icon(Icons.calendar_month, color: Colors.blue),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (!isEditing)
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          value: semanasRepeticion,
                          decoration: const InputDecoration(labelText: '¿Repetir reserva?', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('Solo esta vez')),
                            DropdownMenuItem(value: 4, child: Text('1 mes (4 semanas)')),
                            DropdownMenuItem(value: 12, child: Text('3 meses (12 semanas)')),
                          ],
                          onChanged: (val) => setDialogState(() => semanasRepeticion = val!),
                        ),
                      const SizedBox(height: 24),
                      if (formSelectedDate != null && selectedCourtId != null) ...[
                        Text('Horas Disponibles', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: allHours.map((hour) {
                            bool isOccupied = occupiedHours.contains(hour);
                            bool isSelected = formSelectedTime == hour;
                            return ChoiceChip(
                              label: Text(hour, style: TextStyle(color: isOccupied ? Colors.white : (isSelected ? Colors.white : Colors.black))),
                              selected: isSelected, selectedColor: Colors.blue, disabledColor: Colors.red[400], backgroundColor: Colors.grey[200],
                              onSelected: isOccupied ? null : (selected) => setDialogState(() => formSelectedTime = selected ? hour : null),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
                  onPressed: () async {
                    if (selectedCourtId == null || formSelectedDate == null || formSelectedTime == null) return;

                    if (isGuest && guestNameCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, escribe el nombre del invitado')));
                      return;
                    }

                    String dia = formSelectedDate!.day.toString().padLeft(2, '0');
                    String mes = formSelectedDate!.month.toString().padLeft(2, '0');
                    String anio = formSelectedDate!.year.toString();
                    String fechaInicio = "$anio-$mes-$dia" + "T" + "$formSelectedTime:00";
                    int horaFinInt = int.parse(formSelectedTime!.split(':')[0]) + 1;
                    String fechaFin = "$anio-$mes-$dia" + "T" + horaFinInt.toString().padLeft(2, '0') + ":00:00";

                    Map<String, dynamic> body = {
                      "court": {"id": selectedCourtId},
                      "fechaInicio": fechaInicio, "fechaFin": fechaFin,
                      "estado": "CONFIRMADA", "metodoPago": metodoPago, "estadoPago": estadoPago,
                    };

                    if (isGuest) {
                      body["nombreInvitado"] = guestNameCtrl.text.trim();
                      body["user"] = null;
                    } else {
                      final u = users.firstWhere((u) => u['id'] == selectedUserId);
                      body["user"] = {"id": selectedUserId, "firebaseUid": u['firebaseUid'] ?? u['firebase_uid'], "email": u['email'], "nombre": u['nombre']};
                    }

                    // ✨ AQUÍ ESTÁ LA LÓGICA CORREGIDA (PUT vs POST)
                    try {
                      http.Response respuesta;

                      if (isEditing) {
                        // ACTUALIZAR (No duplica)
                        respuesta = await http.put(
                          Uri.parse('$baseUrl/reservations/${reservaEdit['id']}'),
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode(body),
                        );
                      } else {
                        // CREAR NUEVA
                        respuesta = await http.post(
                          Uri.parse('$baseUrl/reservations?semanasRepeticion=$semanasRepeticion'),
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode(body),
                        );
                      }

                      if (respuesta.statusCode == 200 || respuesta.statusCode == 201) {
                        if (context.mounted) Navigator.pop(context);
                        onSaved();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Revisa los datos o solapes de hora.')));
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de conexión.')));
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