import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarTab extends StatefulWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final List<dynamic> dayReservations;
  final List<dynamic> courts;
  final bool isLoading;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(int) onDelete;
  final Function(DateTime, int, String) onAddReservation;
  final Function(Map<String, dynamic>) onEdit; // ✨ NUEVO: Para editar desde calendario

  const CalendarTab({
    Key? key,
    required this.focusedDay,
    required this.selectedDay,
    required this.dayReservations,
    required this.courts,
    required this.isLoading,
    required this.onDaySelected,
    required this.onDelete,
    required this.onAddReservation,
    required this.onEdit, // ✨ NUEVO
  }) : super(key: key);

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  int? _selectedCourtId;

  @override
  void initState() {
    super.initState();
    if (widget.courts.isNotEmpty) {
      _selectedCourtId = widget.courts.first['id'];
    }
  }

  @override
  void didUpdateWidget(covariant CalendarTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedCourtId == null && widget.courts.isNotEmpty) {
      setState(() {
        _selectedCourtId = widget.courts.first['id'];
      });
    }
  }

  String _extractHour(String isoDate) {
    try { return isoDate.split('T')[1].substring(0, 5); } catch (e) { return '--:--'; }
  }

  @override
  Widget build(BuildContext context) {
    // Horario completo compacto
    final List<String> hours = ['09:00', '10:00', '11:00', '12:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 📅 COLUMNA IZQUIERDA: EL MES (Diseño más limpio)
        Expanded(
          flex: 4,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0), // Más compacto
              child: TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: widget.focusedDay,
                selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
                startingDayOfWeek: StartingDayOfWeek.monday,
                onDaySelected: widget.onDaySelected,
                rowHeight: 38, // ✨ Compactar calendario
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(color: Colors.blueGrey, shape: BoxShape.circle),
                  todayDecoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                  outsideDaysVisible: false,
                ),
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true, titleTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),

        // 📋 COLUMNA DERECHA: HORARIO VERTICAL MUY COMPACTO
        Expanded(
          flex: 5,
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.only(left: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Más compacto
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CABECERA CON EL SELECTOR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Horario del ${DateFormat('dd/MM/yyyy').format(widget.selectedDay)}',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold), // Texto un poco más pequeño
                      ),
                      if (widget.courts.isNotEmpty)
                        Container(
                          height: 35, // ✨ Selector más bajo
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                              color: Colors.blueGrey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blueGrey[200]!)
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedCourtId,
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.blueGrey, size: 18),
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.blueGrey[900], fontSize: 12),
                              items: widget.courts.map((c) => DropdownMenuItem<int>(
                                value: c['id'],
                                child: Text(c['nombre'] ?? 'Pista'),
                              )).toList(),
                              onChanged: (val) { setState(() { _selectedCourtId = val; }); },
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Divider(height: 16), // Menos espacio

                  // LISTA DE HORARIOS (Súper Compacta para evitar Scroll)
                  Expanded(
                    child: widget.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _selectedCourtId == null
                        ? const Center(child: Text('Cargando pistas...'))
                        : ListView.builder(
                      itemCount: hours.length,
                      padding: EdgeInsets.zero, // ✨ Quitar padding de la lista
                      itemBuilder: (context, index) {
                        final horaStr = hours[index];
                        final horaFinInt = int.parse(horaStr.split(':')[0]) + 1;
                        final rangoHora = '$horaStr - $horaFinInt:00';

                        // Buscamos reserva
                        final reserva = widget.dayReservations.firstWhere(
                              (r) => r['court']?['id'] == _selectedCourtId && _extractHour(r['fechaInicio']) == horaStr,
                          orElse: () => null,
                        );

                        // Altura fija baja para todas las tarjetas
                        const double containerHeight = 45.0; // ✨ ALTURA SÚPER BAJA PARA COMPACTAR

                        if (reserva != null) {
                          // 🔴 HORARIO OCUPADO (Diseño plano y compacto)
                          final cliente = reserva['user'] == null ? '${reserva['nombreInvitado']} (Invitado)' : reserva['user']['nombre'];
                          return Container(
                            height: containerHeight,
                            margin: const EdgeInsets.only(bottom: 4), // Mínimo margen
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.blueGrey[100]!)
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.lock, color: Colors.red[300], size: 16),
                                const SizedBox(width: 8),
                                Text(rangoHora, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                const SizedBox(width: 12),
                                Expanded(child: Text('Cliente: $cliente', style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)),

                                // ✨ ICONO DE MODIFICAR AÑADIDO (Azul)
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 18),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  tooltip: 'Modificar Reserva',
                                  onPressed: () => widget.onEdit(reserva),
                                ),
                                const SizedBox(width: 6),

                                // Icono de cancelar (Rojo)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  tooltip: 'Cancelar Reserva',
                                  onPressed: () => widget.onDelete(reserva['id']),
                                ),
                              ],
                            ),
                          );
                        } else {
                          // 🟢 HORARIO LIBRE (Plano y compacto con botón verde claro)
                          return Container(
                            height: containerHeight,
                            margin: const EdgeInsets.only(bottom: 4), // Mínimo margen
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                                color: Colors.green[50], // Fondo verde clarito
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.green[100]!)
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_outline, color: Colors.green[400], size: 16),
                                const SizedBox(width: 8),
                                Text(rangoHora, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green[800])),
                                const Spacer(),
                                TextButton.icon(
                                  icon: const Icon(Icons.add_circle_outline, size: 16),
                                  label: const Text('Reservar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.green[100],
                                    foregroundColor: Colors.green[900],
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                    minimumSize: const Size(0, 30),
                                  ),
                                  onPressed: () => widget.onAddReservation(widget.selectedDay, _selectedCourtId!, horaStr),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}