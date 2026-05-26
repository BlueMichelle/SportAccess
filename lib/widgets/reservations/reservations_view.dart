import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'tabs/crud_tab.dart';
import 'tabs/calendar_tab.dart';
import 'tabs/upcoming_tab.dart';
import 'reservation_form.dart';

class ReservationsView extends StatefulWidget {
  const ReservationsView({Key? key}) : super(key: key);

  @override
  State<ReservationsView> createState() => _ReservationsViewState();
}

class _ReservationsViewState extends State<ReservationsView> with SingleTickerProviderStateMixin {
  final String baseUrl = 'http://localhost:8080/api';
  late TabController _tabController;

  List<dynamic> _allReservations = [];
  List<dynamic> _dayReservations = [];
  List<dynamic> _courts = []; // ✨ Necesario para las columnas del calendario

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _isLoadingDay = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    await _fetchCourts();
    await _fetchAllReservations();
    await _fetchDayReservations(_selectedDay);
  }

  Future<void> _fetchCourts() async {
    final response = await http.get(Uri.parse('$baseUrl/courts'));
    if (response.statusCode == 200) {
      setState(() => _courts = jsonDecode(utf8.decode(response.bodyBytes)));
    }
  }

  Future<void> _fetchAllReservations() async {
    final response = await http.get(Uri.parse('$baseUrl/reservations'));
    if (response.statusCode == 200) {
      setState(() => _allReservations = jsonDecode(utf8.decode(response.bodyBytes)));
    }
  }

  Future<void> _fetchDayReservations(DateTime date) async {
    setState(() => _isLoadingDay = true);
    final queryDate = DateFormat('yyyy-MM-dd').format(date);
    try {
      final response = await http.get(Uri.parse('$baseUrl/reservations/date/$queryDate'));
      if (response.statusCode == 200) {
        setState(() => _dayReservations = jsonDecode(utf8.decode(response.bodyBytes)));
      }
    } finally {
      setState(() => _isLoadingDay = false);
    }
  }

  Future<void> _deleteReservation(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/reservations/$id'));
    if (response.statusCode == 200 || response.statusCode == 204) {
      _loadAllData();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📅 Reserva cancelada')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gestión de Reservas', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const SizedBox(height: 20),
            TabBar(
              controller: _tabController, labelColor: Colors.blueGrey[900], unselectedLabelColor: Colors.grey, indicatorColor: Colors.blueGrey[900], labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(icon: Icon(Icons.list), text: 'Reservas'),
                Tab(icon: Icon(Icons.calendar_month), text: 'Calendario'),
                Tab(icon: Icon(Icons.update), text: 'Recurrentes')
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  CrudTab(reservations: _allReservations, onDelete: _deleteReservation, onEdit: (res) => showReservationForm(context, _allReservations, _loadAllData, reservaEdit: res)),
                  CalendarTab(
                    focusedDay: _focusedDay, selectedDay: _selectedDay, dayReservations: _dayReservations, courts: _courts, isLoading: _isLoadingDay, onDelete: _deleteReservation,
                    onDaySelected: (sDay, fDay) {
                      setState(() { _selectedDay = sDay; _focusedDay = fDay; });
                      _fetchDayReservations(sDay);
                    },
                    // ✨ Enlace mágico: Si pulsa "Añadir" en la cuadrícula, abre el formulario pre-relleno
                    onAddReservation: (fecha, pistaId, hora) {
                      showReservationForm(context, _allReservations, _loadAllData, fechaInicial: fecha, horaInicial: hora, pistaInicial: pistaId);
                    },
                    onEdit: (res) => showReservationForm(context, _allReservations, _loadAllData, reservaEdit: res),
                  ),
                  UpcomingTab(reservations: _allReservations, onDelete: _deleteReservation),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showReservationForm(context, _allReservations, _loadAllData),
        label: const Text('Añadir Reserva'), icon: const Icon(Icons.add), backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white,
      ),
    );
  }
}