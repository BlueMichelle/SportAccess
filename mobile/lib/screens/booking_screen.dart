import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:app/models/models.dart' hide isSameDay;
import 'package:app/screens/payment_screen.dart';
import 'package:app/services/api_service.dart';
import 'package:app/main.dart';

class BookingScreen extends StatefulWidget {
  final Court court;
  const BookingScreen({Key? key, required this.court}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _focusedDay   = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  int _selectedHours     = 1;
  String _selectedTime   = '18:00';
  bool _loadingReservations = true;

  Map<String, Set<String>> _occupiedSlots = {};

  final List<String> _availableTimes  = ['09:00','10:00','11:00','12:00','16:00','17:00','18:00','19:00','20:00','21:00'];
  final List<int>    _hourOptions     = [1, 2, 3];

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
        final inicio   = DateTime.parse(r['fechaInicio']);
        final dateKey  = DateFormat('yyyy-MM-dd').format(inicio);
        final timeKey  = '${inicio.hour.toString().padLeft(2,'0')}:00';
        slots.putIfAbsent(dateKey, () => <String>{}).add(timeKey);
      } catch (_) {}
    }
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
    return set != null && _availableTimes.every((t) => set.contains(t));
  }

  bool _isSlotOccupied(DateTime? day, String time) {
    if (day == null) return false;
    return _occupiedSlots[_dateKey(day)]?.contains(time) ?? false;
  }

  bool get _currentSlotOccupied => _isSlotOccupied(_selectedDay, _selectedTime);
  double get totalPrice => widget.court.pricePerHour * _selectedHours;

  String get _timeRange {
    try {
      final hour    = int.parse(_selectedTime.split(':')[0]);
      final endHour = hour + _selectedHours;
      return '$_selectedTime a ${endHour.toString().padLeft(2,'0')}:00';
    } catch (e) { return _selectedTime; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kCard,
        title: const Text('Configurar Reserva'),
        actions: [
          if (_loadingReservations)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: kPrimary))),
            )
          else
            IconButton(icon: const Icon(Icons.refresh, color: kTextSec), onPressed: _loadCourtReservations, tooltip: 'Actualizar disponibilidad'),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Imagen ────────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.all(16),
              height: 170,
              width: double.infinity,
              child: Hero(
                tag: 'court-${widget.court.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    widget.court.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, p) => p == null ? child : Container(color: kSurface, child: const Center(child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2))),
                    errorBuilder: (ctx, e, s) => Container(color: kSurface, child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.sports_tennis, size: 48, color: kPrimary), SizedBox(height: 8), Text('Instalación', style: TextStyle(color: kTextSec))])),
                  ),
                ),
              ),
            ),

            // ── Calendario ────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kBorder),
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
                  titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextPri),
                  leftChevronIcon:  Icon(Icons.chevron_left,  color: kPrimary),
                  rightChevronIcon: Icon(Icons.chevron_right, color: kPrimary),
                  headerPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kTextSec),
                  weekendStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kPrimary),
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle:  const TextStyle(fontSize: 15, color: kTextPri),
                  weekendTextStyle:  const TextStyle(fontSize: 15, color: kPrimary),
                  outsideTextStyle:  const TextStyle(fontSize: 15, color: kBorder),
                  todayTextStyle:    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kPrimary),
                  todayDecoration:   BoxDecoration(border: Border.all(color: kPrimary, width: 1.5), shape: BoxShape.circle),
                  selectedDecoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle),
                  selectedTextStyle:  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  markerDecoration:   const BoxDecoration(color: Color(0xFFF85149), shape: BoxShape.circle),
                  markersMaxCount:    1,
                  disabledTextStyle:  const TextStyle(color: kBorder),
                ),
                eventLoader: (day) {
                  final key = _dateKey(day);
                  return _occupiedSlots.containsKey(key) ? [true] : [];
                },
                enabledDayPredicate: (day) => !_isDayFullyOccupied(day),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.court.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kTextPri)),
                  const SizedBox(height: 4),
                  Text(widget.court.location, style: const TextStyle(color: kTextSec)),
                  const SizedBox(height: 20),

                  // ── Selectores hora / duración ────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedTime,
                          dropdownColor: kSurface,
                          style: const TextStyle(color: kTextPri),
                          items: _availableTimes.map((t) {
                            final occupied = _isSlotOccupied(_selectedDay, t);
                            return DropdownMenuItem(
                              value: t,
                              child: Row(children: [
                                Text(t, style: TextStyle(color: occupied ? const Color(0xFFF85149) : kTextPri)),
                                if (occupied) ...[const SizedBox(width: 4), const Icon(Icons.block, size: 14, color: Color(0xFFF85149))],
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
                          dropdownColor: kSurface,
                          style: const TextStyle(color: kTextPri),
                          items: _hourOptions.map((h) => DropdownMenuItem(value: h, child: Text('$h h'))).toList(),
                          onChanged: (val) => setState(() => _selectedHours = val!),
                          decoration: _inputDecor('Horas'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Resumen ───────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
                    child: Column(children: [
                      _summaryRow(Icons.calendar_today, 'Día', _selectedDay != null ? DateFormat('dd/MMM/yyyy').format(_selectedDay!) : '-'),
                      Divider(height: 20, color: kBorder),
                      _summaryRow(Icons.access_time, 'Horario', _timeRange),
                      Divider(height: 20, color: kBorder),
                      _summaryRow(Icons.payments, 'Coste Total', '${totalPrice.toStringAsFixed(2)} €'),
                    ]),
                  ),

                  const SizedBox(height: 16),

                  // ── Disponibilidad ────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _currentSlotOccupied ? const Color(0xFFF85149).withOpacity(0.1) : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _currentSlotOccupied ? const Color(0xFFF85149).withOpacity(0.4) : Colors.green.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_currentSlotOccupied ? Icons.block : Icons.check_circle_outline,
                            color: _currentSlotOccupied ? const Color(0xFFF85149) : Colors.greenAccent),
                        const SizedBox(width: 8),
                        Text(
                          _currentSlotOccupied ? 'FRANJA OCUPADA — Elige otra hora' : 'INSTALACIÓN LIBRE',
                          style: TextStyle(
                            color: _currentSlotOccupied ? const Color(0xFFF85149) : Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Botón Reservar ────────────────────────────────────
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
                        backgroundColor: kPrimary,
                        disabledBackgroundColor: kSurface,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentSlotOccupied ? 'NO DISPONIBLE' : 'RESERVAR AHORA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _currentSlotOccupied ? kTextSec : Colors.white,
                        ),
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
      Icon(icon, size: 18, color: kTextSec),
      const SizedBox(width: 12),
      Text(label, style: const TextStyle(color: kTextSec, fontSize: 14)),
      const Spacer(),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kTextPri)),
    ]);
  }

  InputDecoration _inputDecor(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: kTextSec),
      filled: true,
      fillColor: kSurface,
      border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimary, width: 1.5)),
    );
  }
}
