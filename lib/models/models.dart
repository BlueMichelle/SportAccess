import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Court {
  final String id;
  final String name;
  final List<String> sports;
  final String imageUrl;
  final double pricePerHour;
  final String location;

  Court({
    required this.id,
    required this.name,
    required this.sports,
    required this.imageUrl,
    required this.pricePerHour,
    required this.location,
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id'].toString(),
      name: json['nombre'] ?? 'Sin Nombre',
      sports: [(json['tipo'] ?? '').toString().replaceAll('_', ' ')],
      imageUrl: (json['imagenUrl'] != null && (json['imagenUrl'] as String).isNotEmpty)
          ? json['imagenUrl']
          : 'https://picsum.photos/seed/court${json["id"]}/800/600',
      pricePerHour: (json['precioPorHora'] ?? 0).toDouble(),
      location: json['descripcion'] ?? '',
    );
  }
}

// Globales del usuario para la sesión y BD simulada
String loggedUserName = "";
String loggedUserEmail = "";
String loggedUserUid = "";

// Lista de usuarios registrados localmente simulando Firebase Auth
List<Map<String, String>> mockRegisteredUsers = [];

// Lista global de reservas para simular el historial
List<Map<String, dynamic>> mockReservations = [];

// Datos falsos (MOCK) imitando la Región de Murcia
List<Court> mockCourts = [
  Court(
    id: '1',
    name: 'Pabellón Príncipe de Asturias',
    sports: ['Fútbol Sala', 'Baloncesto', 'Voleibol'],
    imageUrl: 'https://picsum.photos/seed/padel1/800/600',
    pricePerHour: 15.0,
    location: 'Murcia Centro',
  ),
  Court(
    id: '2',
    name: 'Polideportivo San Javier',
    sports: ['Tenis', 'Pádel'],
    imageUrl: 'https://picsum.photos/seed/tenis2/800/600',
    pricePerHour: 12.50,
    location: 'San Javier',
  ),
  Court(
    id: '3',
    name: 'Palacio de Deportes',
    sports: ['Baloncesto'],
    imageUrl: 'https://picsum.photos/seed/basket3/800/600',
    pricePerHour: 20.0,
    location: 'Cartagena',
  ),
  Court(
    id: '4',
    name: 'Polideportivo José Barnés',
    sports: ['Pádel', 'Tenis', 'Atletismo'],
    imageUrl: 'https://picsum.photos/seed/sport4/800/600',
    pricePerHour: 10.0,
    location: 'Murcia Norte',
  ),
  Court(
    id: '5',
    name: 'Centro Deportivo Inacua',
    sports: ['Natación', 'Pádel'],
    imageUrl: 'https://picsum.photos/seed/pool5/800/600',
    pricePerHour: 18.0,
    location: 'Murcia Sur',
  ),
  Court(
    id: '6',
    name: 'Pistas de Alcantarilla',
    sports: ['Fútbol 7', 'Fútbol Sala'],
    imageUrl: 'https://picsum.photos/seed/futbol6/800/600',
    pricePerHour: 14.0,
    location: 'Alcantarilla',
  ),
  Court(
    id: '7',
    name: 'Pabellón Fausto Vicent',
    sports: ['Baloncesto', 'Gimnasia'],
    imageUrl: 'https://picsum.photos/seed/gym7/800/600',
    pricePerHour: 11.0,
    location: 'Alcantarilla',
  ),
  Court(
    id: '8',
    name: 'Pistas Universidad de Murcia',
    sports: ['Tenis', 'Pádel', 'Voleibol'],
    imageUrl: 'https://picsum.photos/seed/uni8/800/600',
    pricePerHour: 8.50,
    location: 'Campus de Espinardo',
  ),
  Court(
    id: '9',
    name: 'Complejo Deportivo JC1',
    sports: ['Natación', 'Pádel', 'Gimnasio'],
    imageUrl: 'https://picsum.photos/seed/jc9/800/600',
    pricePerHour: 22.0,
    location: 'Juan Carlos I, Murcia',
  ),
  Court(
    id: '10',
    name: 'Club de Tenis Cabezo de Torres',
    sports: ['Tenis'],
    imageUrl: 'https://picsum.photos/seed/tenis10/800/600',
    pricePerHour: 13.0,
    location: 'Cabezo de Torres',
  ),
];

bool isDateSame(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

Future<void> saveData() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('loggedUserName', loggedUserName);
  prefs.setString('loggedUserEmail', loggedUserEmail);
  prefs.setString('loggedUserUid', loggedUserUid);
  prefs.setString('mockRegisteredUsers', jsonEncode(mockRegisteredUsers));
  
  // Convert reservations DateTimes to Strings for JSON storage
  List<Map<String, dynamic>> resList = mockReservations.map((e) {
    Map<String, dynamic> modified = Map.from(e);
    if (modified['date'] is DateTime) {
      modified['date'] = (modified['date'] as DateTime).toIso8601String();
    }
    return modified;
  }).toList();
  prefs.setString('mockReservations', jsonEncode(resList));
}

Future<void> loadData() async {
  final prefs = await SharedPreferences.getInstance();
  loggedUserName = prefs.getString('loggedUserName') ?? "";
  loggedUserEmail = prefs.getString('loggedUserEmail') ?? "";
  loggedUserUid = prefs.getString('loggedUserUid') ?? "";
  
  try {
    String? usersStr = prefs.getString('mockRegisteredUsers');
    if (usersStr != null) {
      List<dynamic> parsedList = jsonDecode(usersStr);
      mockRegisteredUsers = parsedList.map((e) => Map<String, String>.from(e)).toList();
    }
  } catch (e) { print(e); }

  try {
    String? resStr = prefs.getString('mockReservations');
    if (resStr != null) {
      List<dynamic> parsedList = jsonDecode(resStr);
      mockReservations = parsedList.map((e) {
        Map<String, dynamic> element = Map<String, dynamic>.from(e);
        if (element['date'] is String) {
          element['date'] = DateTime.parse(element['date']);
        }
        return element;
      }).toList();
    }
  } catch (e) { print(e); }
}
