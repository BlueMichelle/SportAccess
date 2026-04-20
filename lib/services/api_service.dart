import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:app/models/models.dart';

class ApiService {
  // IP para emulador Android. Si usas dispositivo real, cambia a tu IP de red local.
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  final Dio dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 5), // Si en 5s no conecta, salta el error
    receiveTimeout: const Duration(seconds: 3),
  ));

  // 1. OBTENER TODAS LAS PISTAS
  // 1. Obtener todas las pistas
  Future<List<Court>> getCourts() async {
    try {
      print("📡 INTENTANDO CONECTAR A: $baseUrl/courts");
      final response = await dio.get('/courts');
      print("📡 BACKEND RESPONDE: ${response.data}");

      final List<dynamic> data = response.data;
      return data.map((json) => Court.fromJson(json)).toList();
    } catch (e) {
      print('❌ ERROR DE CONEXIÓN: $e');
      return []; // <--- CAMBIA ESTO (Quita mockCourts y pon [])
    }
  }

  // 0a. REGISTRO
  Future<Map<String, dynamic>?> registerUser(String email, String name) async {
    try {
      final fakeUid = 'fb_${email.replaceAll('@', '_').replaceAll('.', '_')}';

      mockRegisteredUsers.add({
        'email': email,
        'name': name.isEmpty ? 'Usuario' : name,
        'uid': fakeUid,
      });
      await saveData();

      final response = await dio.post('/users', data: {
        'email': email,
        'nombre': name.isEmpty ? 'Usuario' : name,
        'firebaseUid': fakeUid,
        'telefono': '000000000',
        'rol': 'USER',
      });
      return response.data;
    } catch (e) {
      print('Error en registro: $e');
      return null;
    }
  }

  // 0b. LOGIN
  Future<Map<String, dynamic>?> loginUser(String email) async {
    final emailLower = email.toLowerCase();
    try {
      final allResponse = await dio.get('/users');
      final List<dynamic> users = allResponse.data;
      for (final u in users) {
        if ((u['email'] ?? '').toString().toLowerCase() == emailLower) {
          return u as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print('Error al buscar en backend, probando fallback local: $e');
    }

    for (final u in mockRegisteredUsers) {
      if ((u['email'] ?? '').toString().toLowerCase() == emailLower) {
        return u;
      }
    }
    return null;
  }

  // 2. HACER UNA RESERVA (Pago)
  Future<dynamic> createReservation(Map<String, dynamic> data) async {
    try {
      final response = await dio.post('/reservations', data: data);
      return response.data;
    } on DioException catch (e) {
      print('====== ERROR SERVIDOR ======');
      print(e.response?.data ?? 'Sin respuesta del servidor');
      return null;
    } catch (e) {
      print('Error genérico: $e');
      return null;
    }
  }

  // 3. HISTORIAL
  Future<List<dynamic>> getUserHistory(int userId) async {
    try {
      final response = await dio.get('/reservations/user/$userId');
      return response.data;
    } catch (e) {
      print('Error historial: $e');
      return [];
    }
  }

  // 4. RESERVAS DE UNA PISTA (Calendario)
  Future<List<Map<String, dynamic>>> getReservationsForCourt(String courtId) async {
    try {
      final fechaHoy = DateTime.now().toIso8601String().split('T')[0];
      final response = await dio.get('/reservations/court/$courtId/horarios?fecha=$fechaHoy');
      final List<dynamic> activas = response.data;
      return activas.map((r) => r as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error obteniendo horarios, usando fallback: $e');
      try {
        final response = await dio.get('/reservations');
        final List<dynamic> all = response.data;
        return all
            .where((r) => r['court'] != null && r['court']['id'].toString() == courtId && r['estado'] != 'CANCELADA')
            .map((r) => r as Map<String, dynamic>)
            .toList();
      } catch (_) { return []; }
    }
  }

  // 5. QR TOKEN
  Future<Map<String, dynamic>?> getReservationByQrToken(String token) async {
    try {
      final response = await dio.get('/reservations');
      final List<dynamic> all = response.data;
      for (final r in all) {
        if (r['qrToken'] == token && r['estado'] != 'CANCELADA') {
          return r as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 6. CANCELAR
  Future<bool> cancelReservation(int reservaId) async {
    try {
      final response = await dio.put('/reservations/$reservaId/cancel');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}