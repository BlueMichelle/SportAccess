import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Court {
  final String id;
  final String name;
  final List<String> sports;
  final String imageUrl;
  final double pricePerHour;
  final String location;
  final bool isActive;

  Court({
    required this.id,
    required this.name,
    required this.sports,
    required this.imageUrl,
    required this.pricePerHour,
    required this.location,
    required this.isActive,
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    // 1. Obtenemos la URL de la base de datos
    String dbUrl = (json['imagen_url'] ?? json['imagenUrl'] ?? '').toString();

    // 2. Si la URL está vacía o es de las antiguas (picsum), asignamos la Pro manualmente
    if (dbUrl.isEmpty || dbUrl.contains('picsum')) {
      String tipo = (json['tipo'] ?? '').toString().toLowerCase();
      if (tipo.contains('padel')) dbUrl = 'https://images.unsplash.com/photo-1626224484214-4051773c51a9?q=80&w=800';
      else if (tipo.contains('tenis')) dbUrl = 'https://images.unsplash.com/photo-1595435064215-492976d03704?q=80&w=800';
      else if (tipo.contains('futbol')) dbUrl = 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=800';
      else dbUrl = 'https://images.unsplash.com/photo-1505666287802-931dc83948e9?q=80&w=800';
    }

    bool pistaActiva = true;
    if (json.containsKey('activa') && json['activa'] != null) {
      var valor = json['activa'];

      // Imprimimos por consola lo que está llegando realmente para investigar
      print('🎾 DEBUG - Pista: ${json['nombre']} | Valor "activa": $valor | Tipo: ${valor.runtimeType}');

      // Si llega como booleano false, como número 0, o como texto "0" o "false", la apagamos
      if (valor == false || valor == 0 || valor == '0' || valor.toString().toLowerCase() == 'false') {
        pistaActiva = false;
      }
    } else {
      print('🎾 DEBUG - Pista: ${json['nombre']} | El campo "activa" NO llega en el JSON o es null');
    }

    return Court(
      id: json['id'].toString(),
      name: json['nombre'] ?? 'Instalación',
      sports: [(json['tipo'] ?? '').toString().replaceAll('_', ' ')],
      imageUrl: dbUrl,
      pricePerHour: (json['precioPorHora'] ?? 0).toDouble(),
      location: json['descripcion'] ?? 'Polideportivo',
      isActive: pistaActiva,
    );
  }
}

// Globales de sesión
String loggedUserName = "";
String loggedUserEmail = "";
String loggedUserUid = "";

List<Map<String, String>> mockRegisteredUsers = [];
List<Map<String, dynamic>> mockReservations = [];

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