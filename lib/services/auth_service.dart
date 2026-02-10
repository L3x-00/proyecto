import 'package:dio/dio.dart';
import '../utils/dio_client.dart';

class AuthService {
  final DioClient _dioClient = DioClient();

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        print("Token recibido: ${response.data['token']}");
        return true;
      }
      return false;
    } on DioException catch (e) {
      print("Error de Login: ${e.response?.data['message'] ?? e.message}");
      return false;
    }
  }
}
