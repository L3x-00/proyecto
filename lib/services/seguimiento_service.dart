import 'package:dio/dio.dart';
import '../models/avance_model.dart';
import '../utils/dio_client.dart';

class SeguimientoService {
  final DioClient _dioClient = DioClient();

  Future<List<AvanceModel>> getAvances() async {
    try {
      final response = await _dioClient.dio.get('/seguimientos');

      if (response.statusCode == 200) {
        final List<dynamic> datos = response.data;
        return datos.map((json) => AvanceModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error obteniendo avances: $e");
      return [];
    }
  }
}
