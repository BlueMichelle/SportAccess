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

  Map<String, Set<String>> _occupiedSlots = {};

  Map<String, int> _selectedMaterials = {};
  bool _wantsReferee = false;
  final double _refereePrice = 15.0;

  final List<String> _availableTimes = [
    '09:00', '10:00', '11:00', '12:00', '16:00',
    '17:00', '18:00', '19:00', '20:00', '21:00'
  ];
  final List<int> _hourOptions = [1, 2, 3];

  @override
  void initState() {
    super.initState();
    _loadCourtReservations();
  }

  List<Map<String, dynamic>> get _availableEquipment {
    final name = widget.court.name.toLowerCase();
    if (name.contains('pádel') || name.contains('tenis')) {
      return [
        {'name': 'Raqueta / Pala', 'price': 3.0},
        {'name': 'Bote de Bolas', 'price': 1.5}
      ];
    } else if (name.contains('fútbol') || name.contains('sala')) {
      return [
        {'name': 'Balón de Fútbol', 'price': 2.0},
        {'name': 'Petos (10 uds)', 'price': 4.0}
      ];
    } else if (name.contains('baloncesto')) {
      return [{'name': 'Balón de Baloncesto', 'price': 2.0}];
    }
    return [{'name': 'Botella de Agua 1.5L', 'price': 1.0}];
  }

  double get _totalMaterialPrice {
    double total = 0;
    for (var item in _availableEquipment) {
      int qty = _selectedMaterials[item['name']] ?? 0;
      total += qty * (item['price'] as double);
    }
    return total;
  }

  double get _totalExtrasPrice =>
      _totalMaterialPrice + (_wantsReferee ? _refereePrice : 0);

  String get _extraDetails {
    List<String> details = [];
    if (_wantsReferee) details.add('Árbitro Oficial');
    for (var item in _availableEquipment) {
      int qty = _selectedMaterials[item['name']] ?? 0;
      if (qty > 0) details.add('${qty}x ${item['name']}');
    }
    return details.isEmpty ? "Sin extras" : details.join(', ');
  }

  Future<void> _loadCourtReservations() async {
    setState(() => _loadingReservations = true);
    final reservations =
    await ApiService().getReservationsForCourt(widget.court.id);
    final Map<String, Set<String>> slots = {};

    for (var r in reservations) {
      try {
        final inicio = DateTime.parse(r['fechaInicio']);
        final fin = DateTime.parse(r['fechaFin']);
        final dateKey = DateFormat('yyyy-MM-dd').format(inicio);
        int duracionHoras = fin.difference(inicio).inHours;
        for (int i = 0; i < duracionHoras; i++) {
          final horaOcupada = inicio.hour + i;
          final timeKey = '${horaOcupada.toString().padLeft(2, '0')}:00';
          slots.putIfAbsent(dateKey, () => <String>{}).add(timeKey);
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _occupiedSlots = slots;
        _loadingReservations = false;
      });
    }
  }

  String _dateKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  bool _isDayFullyOccupied(DateTime day) {
    final set = _occupiedSlots[_dateKey(day)];
    if (set == null) return false;
    return _availableTimes
        .every((t) => set.contains(t) || _isTimeInPast(day, t));
  }

  bool _isSlotOccupied(DateTime? day, String time, int duration) {
    if (day == null) return false;
    final set = _occupiedSlots[_dateKey(day)];
    if (set == null) return false;
    int startHour = int.parse(time.split(':')[0]);
    for (int i = 0; i < duration; i++) {
      String checkTime = '${(startHour + i).toString().padLeft(2, '0')}:00';
      if (set.contains(checkTime)) return true;
    }
    return false;
  }

  bool _isTimeInPast(DateTime? day, String time) {
    if (day == null) return false;
    final now = DateTime.now();
    int startHour = int.parse(time.split(':')[0]);
    int startMinute = int.parse(time.split(':')[1]);
    final slotDateTime =
    DateTime(day.year, day.month, day.day, startHour, startMinute);
    return slotDateTime.isBefore(now);
  }

  bool get _currentSlotOccupied =>
      _isSlotOccupied(_selectedDay, _selectedTime, _selectedHours);
  bool get _isCurrentlySelectedTimeInPast =>
      _isTimeInPast(_selectedDay, _selectedTime);

  double get totalPrice =>
      (widget.court.pricePerHour * _selectedHours) + _totalExtrasPrice;

  String get _timeRange {
    try {
      final hour = int.parse(_selectedTime.split(':')[0]);
      final endHour = hour + _selectedHours;
      return '$_selectedTime a ${endHour.toString().padLeft(2, '0')}:00';
    } catch (e) {
      return _selectedTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Configurar Reserva',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_loadingReservations)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFFF05B3A)),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadCourtReservations,
              tooltip: 'Actualizar disponibilidad',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // IMAGEN PISTA
            Container(
              margin: const EdgeInsets.all(16),
              height: 160,
              width: double.infinity,
              decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(20)),
              child: Hero(
                tag: 'court-${widget.court.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    widget.court.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, e, s) => Container(
                      color: isDark
                          ? colorScheme.surfaceVariant
                          : const Color(0xFFEEF2F7),
                      child: const Icon(Icons.sports_tennis,
                          size: 48, color: Color(0xFFF05B3A)),
                    ),
                  ),
                ),
              ),
            ),

            // CALENDARIO
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06), blurRadius: 12)
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime(2035, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) => setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                }),
                calendarFormat: CalendarFormat.month,
                rowHeight: 44,
                daysOfWeekHeight: 28,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  leftChevronIcon:
                  Icon(Icons.chevron_left, color: colorScheme.onSurface),
                  rightChevronIcon:
                  Icon(Icons.chevron_right, color: colorScheme.onSurface),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                  weekendStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: TextStyle(color: colorScheme.onSurface),
                  weekendTextStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                  disabledTextStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.3)),
                  outsideTextStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.3)),
                  todayDecoration: const BoxDecoration(
                    color: Colors.transparent,
                    border: Border.fromBorderSide(
                        BorderSide(color: Color(0xFFF05B3A), width: 1.5)),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFFF05B3A),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                eventLoader: (day) =>
                _occupiedSlots.containsKey(_dateKey(day)) ? [true] : [],
                enabledDayPredicate: (day) => !_isDayFullyOccupied(day),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NOMBRE Y UBICACIÓN PISTA
                  Text(
                    widget.court.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(widget.court.location,
                      style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.6))),
                  const SizedBox(height: 20),

                  // SELECTOR DE HORA Y DURACIÓN
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedTime,
                          dropdownColor: isDark ? colorScheme.surfaceVariant : null,
                          items: _availableTimes.map((t) {
                            final occupied = _isSlotOccupied(_selectedDay, t, 1);
                            final isPast = _isTimeInPast(_selectedDay, t);
                            final unavailable = occupied || isPast;
                            return DropdownMenuItem(
                              value: t,
                              child: Row(children: [
                                Text(t,
                                    style: TextStyle(
                                        color: unavailable
                                            ? Colors.red
                                            : colorScheme.onSurface)),
                                if (unavailable)
                                  const Icon(Icons.block,
                                      size: 14, color: Colors.red),
                              ]),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedTime = val!),
                          decoration: _inputDecor('Entrada', context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedHours,
                          dropdownColor: isDark ? colorScheme.surfaceVariant : null,
                          items: _hourOptions
                              .map((h) => DropdownMenuItem(
                              value: h, child: Text('$h h')))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedHours = val!),
                          decoration: _inputDecor('Horas', context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ACORDEÓN DE MATERIAL
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: colorScheme.outline.withOpacity(0.3)),
                    ),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: const Icon(Icons.sports_baseball,
                            color: Color(0xFFF05B3A)),
                        title: Text(
                          'Añadir Material',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface),
                        ),
                        subtitle: Text(
                          _totalMaterialPrice > 0
                              ? '+${_totalMaterialPrice.toStringAsFixed(2)}€'
                              : 'Opcional',
                          style: TextStyle(
                              color: _totalMaterialPrice > 0
                                  ? Colors.green
                                  : Colors.grey),
                        ),
                        children: _availableEquipment.map((item) {
                          int currentQty =
                              _selectedMaterials[item['name']] ?? 0;
                          return ListTile(
                            title: Text(item['name'],
                                style:
                                TextStyle(color: colorScheme.onSurface)),
                            subtitle: Text(
                                '+${item['price'].toStringAsFixed(2)}€ / ud',
                                style: const TextStyle(
                                    color: Colors.green, fontSize: 12)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline,
                                      color: Colors.red),
                                  onPressed: currentQty > 0
                                      ? () => setState(() =>
                                  _selectedMaterials[item['name']] =
                                      currentQty - 1)
                                      : null,
                                ),
                                Text('$currentQty',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: colorScheme.onSurface)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline,
                                      color: Colors.green),
                                  onPressed: currentQty < 10
                                      ? () => setState(() =>
                                  _selectedMaterials[item['name']] =
                                      currentQty + 1)
                                      : null,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // SELECTOR DE ÁRBITRO
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: colorScheme.outline.withOpacity(0.3)),
                    ),
                    child: SwitchListTile(
                      title: Text(
                        'Solicitar Árbitro',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface),
                      ),
                      subtitle: const Text(
                        'Juega como un profesional (+15.00€)',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                      secondary: const Icon(Icons.sports,
                          color: Color(0xFFF05B3A)),
                      activeColor: const Color(0xFFF05B3A),
                      value: _wantsReferee,
                      onChanged: (bool value) =>
                          setState(() => _wantsReferee = value),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // RESUMEN
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10)
                      ],
                    ),
                    child: Column(children: [
                      _summaryRow(
                        Icons.calendar_today,
                        'Día',
                        _selectedDay != null
                            ? DateFormat('dd/MMM/yyyy').format(_selectedDay!)
                            : '-',
                        context,
                      ),
                      const Divider(height: 12),
                      _summaryRow(
                          Icons.access_time, 'Horario', _timeRange, context),
                      if (_totalExtrasPrice > 0) ...[
                        const Divider(height: 12),
                        _summaryRow(
                          Icons.add_shopping_cart,
                          'Extras',
                          '+${_totalExtrasPrice.toStringAsFixed(2)} €',
                          context,
                        ),
                      ],
                      const Divider(height: 12),
                      _summaryRow(
                        Icons.payments,
                        'Coste Total',
                        '${totalPrice.toStringAsFixed(2)} €',
                        context,
                        isTotal: true,
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // INDICADOR OCUPADO O PASADO
                  if (_currentSlotOccupied || _isCurrentlySelectedTimeInPast)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.block, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            _isCurrentlySelectedTimeInPast
                                ? 'HORA YA PASADA'
                                : 'FRANJA OCUPADA',
                            style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),

                  // BOTÓN RESERVAR
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_currentSlotOccupied ||
                          _isCurrentlySelectedTimeInPast ||
                          _selectedDay == null)
                          ? null
                          : () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => PaymentScreen(
                                  court: widget.court,
                                  date: _selectedDay!,
                                  time: _selectedTime,
                                  duration: _selectedHours,
                                  total: totalPrice,
                                  materialDetails: _extraDetails,
                                )));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF05B3A),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        (_currentSlotOccupied || _isCurrentlySelectedTimeInPast)
                            ? 'NO DISPONIBLE'
                            : 'RESERVAR AHORA',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
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

  Widget _summaryRow(
      IconData icon,
      String label,
      String value,
      BuildContext context, {
        bool isTotal = false,
      }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(children: [
      Icon(icon, size: 18, color: colorScheme.onSurface),
      const SizedBox(width: 12),
      Text(
        label,
        style: TextStyle(
          color: isTotal ? colorScheme.onSurface : Colors.grey,
          fontSize: 14,
          fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      const Spacer(),
      Expanded(
        child: Text(
          value,
          textAlign: TextAlign.right,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 18 : 14,
            color: isTotal ? const Color(0xFFF05B3A) : colorScheme.onSurface,
          ),
        ),
      ),
    ]);
  }

  // Ahora recibe context para acceder al tema
  InputDecoration _inputDecor(String label, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: isDark ? colorScheme.surfaceVariant : colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        BorderSide(color: colorScheme.outline.withOpacity(0.3)),
      ),
    );
  }
}