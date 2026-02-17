import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/dio_client.dart';

class AuthService {
  final DioClient _dioClient = DioClient();

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        '/login.php',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final String token = response.data['token'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        
        print("Token guardado exitosamente: $token");
        return true;
      }
      return false;
    } on DioException catch (e) {
      print("Error Login: ${e.response?.data['message'] ?? e.message}");
      return false;
    } catch (e) {
      print("Error desconocido: $e");
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    print("Sesión cerrada y token eliminado");
  }
}