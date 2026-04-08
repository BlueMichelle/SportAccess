import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'models.dart';
import 'qr_screen.dart';

class BookingScreen extends StatefulWidget {
  final Court court;
  const BookingScreen({Key? key, required this.court}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _selectedHours = 1;
  String _selectedTime = '18:00';
  
  final List<String> _availableTimes = ['16:00', '17:00', '18:00', '19:00', '20:00', '21:00'];
  final List<int> _hourOptions = [1, 2, 3];

  double get totalPrice => widget.court.pricePerHour * _selectedHours;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reserva de Pista')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Diseño lateral: Foto a la izquierda, Calendario a la derecha
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(widget.court.imageUrl, fit: BoxFit.cover, height: 180, width: double.infinity),
                      ),
                      const SizedBox(height: 12),
                      Text(widget.court.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          Text(widget.court.location, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${widget.court.pricePerHour.toStringAsFixed(2)} €/h', style: const TextStyle(color: Color(0xFFF05B3A), fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                    child: TableCalendar(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 30)),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; });
                      },
                      calendarFormat: CalendarFormat.month,
                      headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true, headerPadding: EdgeInsets.zero),
                      rowHeight: 40,
                      calendarStyle: CalendarStyle(
                        selectedDecoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                        todayDecoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.4), shape: BoxShape.circle),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Selector de horas compacto
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Hora de inicio', border: OutlineInputBorder()),
                    value: _selectedTime,
                    items: _availableTimes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setState(() => _selectedTime = val!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Duración (Horas)', border: OutlineInputBorder()),
                    value: _selectedHours,
                    items: _hourOptions.map((h) => DropdownMenuItem(value: h, child: Text('$h h'))).toList(),
                    onChanged: (val) => setState(() => _selectedHours = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Resumen de Pago Detallado (Como pediste, mostrando todo antes de pagar)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1B263B), // Azul Oscuro para destacer el checkout
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Resumen de tu Reserva', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(color: Colors.white30),
                  const SizedBox(height: 8),
                  
                  // Fecha
                  Text(_selectedDay != null ? 'Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDay!)}' : 'Fecha: No seleccionada', style: const TextStyle(color: Colors.white70)),
                  // Horario
                  Text('Horario: $_selectedTime a ${int.parse(_selectedTime.split(':')[0]) + _selectedHours}:00', style: const TextStyle(color: Colors.white70)),
                  // Pista
                  Text('Instalación: ${widget.court.name}', style: const TextStyle(color: Colors.white70)),
                  
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total a pagar:', style: TextStyle(color: Colors.white, fontSize: 16)),
                      Text('${totalPrice.toStringAsFixed(2)} €', style: const TextStyle(color: Color(0xFFF05B3A), fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedDay == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona un día en el calendario')));
                        return;
                      }
                      Navigator.push(context, MaterialPageRoute(builder: (_) => QRScreen(
                        court: widget.court,
                        date: _selectedDay!,
                        time: _selectedTime,
                        total: totalPrice,
                      )));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF05B3A), padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('CONFIRMAR Y PAGAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
