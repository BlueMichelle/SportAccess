import 'package:dio/dio.dart';
import 'package:app/models/models.dart';

class ApiService {
  // Aquí usamos la IP genérica del simulador Android hacia el localhost del ordenador
  // Si usáis iOS, cambiad el 10.0.2.2 por localhost
  static const String baseUrl = 'http://10.0.2.2:8080/api';
  final Dio dio = Dio(BaseOptions(baseUrl: baseUrl));

  // 1. Obtener todas las pistas
  Future<List<Court>> getCourts() async {
    try {
      final response = await dio.get('/courts');
      final List<dynamic> data = response.data;
      return data.map((json) => Court.fromJson(json)).toList();
    } catch (e) {
      print('Error al obtener pistas: $e');
      // En caso de que el backend caiga temporalmente o haya un timeout, devolvemos mockCourts.
      return mockCourts;
    }
  }

  // 0a. REGISTRO: crea el usuario en la base de datos del backend
  Future<Map<String, dynamic>?> registerUser(String email, String name) async {
    try {
      final fakeUid = 'fb_${email.replaceAll('@', '_').replaceAll('.', '_')}';
      
      // FIX: Guardar también en la caché local para sobrevivir a reseteos de Spring Boot
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
    } on DioException catch (e) {
      print('Error en registro: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Error genérico registro: $e');
      return null;
    }
  }

  // 0b. LOGIN: verifica que el email existe en el backend
  // Devuelve null si no existe → acceso denegado
  Future<Map<String, dynamic>?> loginUser(String email) async {
    final emailLower = email.toLowerCase();
    try {
      // Buscamos en la lista completa de usuarios del backend
      final allResponse = await dio.get('/users');
      final List<dynamic> users = allResponse.data;
      // Buscamos el que tenga ese email (insensible a mayúsculas)
      for (final u in users) {
        if ((u['email'] ?? '').toString().toLowerCase() == emailLower) {
          return u as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print('Error al buscar en backend, probando fallback: $e');
    }
    
    // Fallback: Si el backend se ha reseteado o hay fallo, comprobamos la caché local de usuarios registrados previamente
    for (final u in mockRegisteredUsers) {
      if ((u['email'] ?? '').toString().toLowerCase() == emailLower) {
        return u;
      }
    }
    
    return null; // No encontrado en ningún sitio → no está registrado
  }

  // 2. Hacer una reserva
  Future<dynamic> createReservation(Map<String, dynamic> data) async {
    try {
      final response = await dio.post('/reservations', data: data);
      return response.data; 
    } on DioException catch (e) {
      if (e.response != null) {
        print('====== ERROR EXACTO DEL SERVIDOR ======');
        print(e.response?.data);
        print('=======================================');
      } else {
        print('Error de comunicación: ${e.message}');
      }
      return null;
    } catch (e) {
      print('Error genérico: $e');
      return null;
    }
  }

  // 3. Obtener el historial de un usuario
  Future<List<dynamic>> getUserHistory(int userId) async {
    try {
      final response = await dio.get('/reservations/user/$userId');
      return response.data;
    } catch (e) {
      print('Error obteniendo historial: $e');
      return [];
    }
  }

  // 4. Obtener reservas de una pista concreta (para bloquear disponibilidad)
  Future<List<Map<String, dynamic>>> getReservationsForCourt(String courtId) async {
    try {
      final response = await dio.get('/reservations');
      final List<dynamic> all = response.data;
      // Filtramos en Flutter por la pista que nos interesa
      return all
          .where((r) => r['court'] != null && r['court']['id'].toString() == courtId)
          .map((r) => r as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error obteniendo reservas de pista: $e');
      return [];
    }
  }

  // 5. Buscar una reserva por su token QR (para validar el escáner)
  Future<Map<String, dynamic>?> getReservationByQrToken(String token) async {
    try {
      final response = await dio.get('/reservations');
      final List<dynamic> all = response.data;
      for (final r in all) {
        if (r['qrToken'] == token) return r as Map<String, dynamic>;
      }
      return null; // QR no registrado en ninguna reserva
    } catch (e) {
      print('Error buscando QR en backend: $e');
      return null;
    }
  }
}
