import 'package:dio/dio.dart';

class ApiService {
  // Aquí usamos la IP genérica del simulador Android hacia el localhost del ordenador
  // Si usáis iOS, cambiad el 10.0.2.2 por localhost
  static const String baseUrl = 'http://10.0.2.2:8080/api';
  final Dio dio = Dio(BaseOptions(baseUrl: baseUrl));

  // 1. Obtener todas las pistas
  Future<List<dynamic>> getCourts() async {
    try {
      final response = await dio.get('/courts');
      return response.data;
    } catch (e) {
      print('Error al obtener pistas: $e');
      return [];
    }
  }

  // 2. Hacer una reserva
  Future<dynamic> createReservation(Map<String, dynamic> data) async {
    try {
      // Endpoint que el Miembro 2 debería haber creado
      final response = await dio.post('/reservations', data: data);
      return response.data; // Aquí debe retornar el UUID del QR
    } catch (e) {
      print('Error creando reserva: $e');
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
}
