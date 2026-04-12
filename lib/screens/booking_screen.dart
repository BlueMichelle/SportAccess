import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:app/models/models.dart' hide isSameDay;
import 'package:app/screens/payment_screen.dart';
import 'package:app/services/api_service.dart';

class BookingScreen extends StatefulWidget {
  final Court court;
  const BookingScreen({Key? key, required this.court}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  int _selectedHours = 1;
  String _selectedTime = '18:00';
  bool _loadingReservations = true;

  // Franjas ocupadas: Map<"yyyy-MM-dd", Set<"HH:00">>
  Map<String, Set<String>> _occupiedSlots = {};

  final List<String> _availableTimes = ['09:00', '10:00', '11:00', '12:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00'];
  final List<int> _hourOptions = [1, 2, 3];

  @override
  void initState() {
    super.initState();
    _loadCourtReservations();
  }

  Future<void> _loadCourtReservations() async {
    setState(() => _loadingReservations = true);
    final reservations = await ApiService().getReservationsForCourt(widget.court.id);
    final Map<String, Set<String>> slots = {};
    for (var r in reservations) {
      try {
        final inicio = DateTime.parse(r['fechaInicio']);
        final dateKey = DateFormat('yyyy-MM-dd').format(inicio);
        final timeKey = '${inicio.hour.toString().padLeft(2, '0')}:00';
        slots.putIfAbsent(dateKey, () => <String>{}).add(timeKey);
      } catch (_) {}
    }
    // También bloquear reservas locales (mockReservations) del usuario actual
    for (var r in mockReservations) {
      if (r['courtName'] == widget.court.name && r['date'] is DateTime) {
        final dateKey = DateFormat('yyyy-MM-dd').format(r['date'] as DateTime);
        final timeKey = r['time'] as String? ?? '';
        if (timeKey.isNotEmpty) slots.putIfAbsent(dateKey, () => <String>{}).add(timeKey);
      }
    }
    if (mounted) setState(() { _occupiedSlots = slots; _loadingReservations = false; });
  }

  String _dateKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  bool _isDayFullyOccupied(DateTime day) {
    final set = _occupiedSlots[_dateKey(day)];
    if (set == null) return false;
    // Si todas las horas disponibles están ocupadas
    return _availableTimes.every((t) => set.contains(t));
  }

  bool _isSlotOccupied(DateTime? day, String time) {
    if (day == null) return false;
    return _occupiedSlots[_dateKey(day)]?.contains(time) ?? false;
  }

  bool get _currentSlotOccupied => _isSlotOccupied(_selectedDay, _selectedTime);

  double get totalPrice => widget.court.pricePerHour * _selectedHours;

  String get _timeRange {
    try {
      final hour = int.parse(_selectedTime.split(':')[0]);
      final endHour = hour + _selectedHours;
      return '$_selectedTime a ${endHour.toString().padLeft(2, '0')}:00';
    } catch (e) { return _selectedTime; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFD),
      appBar: AppBar(
        title: const Text('Configurar Reserva', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_loadingReservations)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF05B3A)))),
            )
          else
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadCourtReservations, tooltip: 'Actualizar disponibilidad'),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Imagen arriba a pantalla completa
            Container(
              margin: const EdgeInsets.all(16),
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
              child: Hero(
                tag: 'court-${widget.court.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    widget.court.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, p) => p == null ? child : Container(color: const Color(0xFFEEF2F7), child: const Center(child: CircularProgressIndicator(color: Color(0xFFF05B3A), strokeWidth: 2))),
                    errorBuilder: (ctx, e, s) => Container(
                      color: const Color(0xFFEEF2F7),
                      child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.sports_tennis, size: 48, color: Color(0xFFF05B3A)),
                        SizedBox(height: 8),
                        Text('Instalación', style: TextStyle(color: Colors.grey)),
                      ]),
                    ),
                  ),
                ),
              ),
            ),

            // Calendario completo y bien visible
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
              ),
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime(2035, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; });
                },
                calendarFormat: CalendarFormat.month,
                rowHeight: 44,
                daysOfWeekHeight: 28,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B263B)),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFFF05B3A)),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFFF05B3A)),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1B263B)),
                  weekendStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFF05B3A)),
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: const TextStyle(fontSize: 15, color: Color(0xFF1B263B)),
                  weekendTextStyle: const TextStyle(fontSize: 15, color: Color(0xFFF05B3A)),
                  outsideTextStyle: const TextStyle(fontSize: 15, color: Colors.grey),
                  todayTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFF05B3A)),
                  todayDecoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFF05B3A), width: 1.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(color: Color(0xFFF05B3A), shape: BoxShape.circle),
                  selectedTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  markerDecoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  markersMaxCount: 1,
                ),
                // Marcamos con punto rojo los días con al menos una franja ocupada
                eventLoader: (day) {
                  final key = _dateKey(day);
                  return _occupiedSlots.containsKey(key) ? [true] : [];
                },
                // Deshabilitar días completamente ocupados
                enabledDayPredicate: (day) => !_isDayFullyOccupied(day),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.court.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B263B))),
                  Text(widget.court.location, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),

                  // Selector de hora y duración
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedTime,
                          items: _availableTimes.map((t) {
                            final occupied = _isSlotOccupied(_selectedDay, t);
                            return DropdownMenuItem(
                              value: t,
                              child: Row(children: [
                                Text(t, style: TextStyle(color: occupied ? Colors.red : const Color(0xFF1B263B))),
                                if (occupied) ...[const SizedBox(width: 4), const Icon(Icons.block, size: 14, color: Colors.red)],
                              ]),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedTime = val!),
                          decoration: _inputDecor('Entrada'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedHours,
                          items: _hourOptions.map((h) => DropdownMenuItem(value: h, child: Text('$h h'))).toList(),
                          onChanged: (val) => setState(() => _selectedHours = val!),
                          decoration: _inputDecor('Horas'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Resumen
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
                    child: Column(children: [
                      _summaryRow(Icons.calendar_today, 'Día', _selectedDay != null ? DateFormat('dd/MMM/yyyy').format(_selectedDay!) : '-'),
                      const Divider(height: 20),
                      _summaryRow(Icons.access_time, 'Horario', _timeRange),
                      const Divider(height: 20),
                      _summaryRow(Icons.payments, 'Coste Total', '${totalPrice.toStringAsFixed(2)} €'),
                    ]),
                  ),

                  const SizedBox(height: 16),

                  // Indicador disponibilidad
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _currentSlotOccupied ? Colors.red.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _currentSlotOccupied ? Colors.red.shade200 : Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_currentSlotOccupied ? Icons.block : Icons.check_circle_outline,
                            color: _currentSlotOccupied ? Colors.red : Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          _currentSlotOccupied ? 'FRANJA OCUPADA — Elige otra hora' : 'INSTALACIÓN LIBRE',
                          style: TextStyle(color: _currentSlotOccupied ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_currentSlotOccupied || _selectedDay == null) ? null : () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen(
                          court: widget.court,
                          date: _selectedDay!,
                          time: _selectedTime,
                          duration: _selectedHours,
                          total: totalPrice,
                        )));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF05B3A),
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentSlotOccupied ? 'NO DISPONIBLE' : 'RESERVAR AHORA',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, size: 18, color: const Color(0xFF1B263B)),
      const SizedBox(width: 12),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      const Spacer(),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B263B))),
    ]);
  }

  InputDecoration _inputDecor(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
    );
  }
}
