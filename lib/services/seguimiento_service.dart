import 'package:dio/dio.dart';
import '../models/avance_model.dart';
import '../../utils/dio_client.dart';

class SeguimientoService {
  final DioClient _dioClient = DioClient();

  Future<List<AvanceModel>> getAvances() async {
    try {
      // AQUÍ HARÍAS LA PETICIÓN REAL:
      // final response = await _dioClient.dio.get('/avances');
      
      // --- SIMULACIÓN DE RESPUESTA (MOCK) ---
      await Future.delayed(const Duration(seconds: 2)); // Simula espera de red
      final List<dynamic> datosSimulados = [
        {
          "id": 1,
          "title": "Diagnóstico Inicial Completo",
          "date": "13 Dic. 10:45 am",
          "image": "https://images.unsplash.com/photo-1487754180451-c456f719a1fc?w=400"
        },
        {
          "id": 2,
          "title": "Desmontaje de Ruedas",
          "date": "15 Dic. 12:10 am",
          "image": "https://images.unsplash.com/photo-1578844251758-2f71da645217?w=400"
        },
        {
          "id": 3,
          "title": "Reparación de Motor",
          "date": "18 Dic. 09:30 am",
          "image": "https://images.unsplash.com/photo-1597762470488-387751f538c6?w=400"
        },
      ];
      // --------------------------------------

      // Convertimos la lista de mapas (JSON) a lista de objetos AvanceModel
      return datosSimulados.map((json) => AvanceModel.fromJson(json)).toList();

    } on DioException catch (e) {
      // Manejo de errores de Dio
      print("Error de conexión: ${e.message}");
      return [];
    } catch (e) {
      print("Error desconocido: $e");
      return [];
    }
  }
}