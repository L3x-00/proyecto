import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/index.dart';

class ApiService {
  static const String baseUrl = 'https://www.xtremeperformancepe.com/public/api';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }


  Future<Map<String, dynamic>> login(String correo, String clave) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/?resource=auth&action=login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'correo': correo,
          'clave': clave,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final token = data['data']['token'];
          final usuario = Usuario.fromJson(data['data']['usuario']);
          
          await _prefs.setString(_tokenKey, token);
          await _prefs.setString(_userKey, jsonEncode(usuario.toJson()));
          
          return {'success': true, 'token': token, 'usuario': usuario};
        } else {
          return {'success': false, 'error': data['message'] ?? 'Error en login'};
        }
      } else {
        return {'success': false, 'error': 'Error ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<bool> logout() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
    return true;
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Usuario? getUsuario() {
    final userData = _prefs.getString(_userKey);
    if (userData != null) {
      return Usuario.fromJson(jsonDecode(userData));
    }
    return null;
  }

  bool isLogged() {
    return getToken() != null;
  }

  // CLIENTES

  Future<Map<String, dynamic>> getClientes({int page = 1, int limit = 10}) async {
    try {
      final token = getToken();
      if (token == null) {
        return {'success': false, 'error': 'No token disponible'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/?resource=clientes&action=list&page=$page&limit=$limit'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> clientesJson = data['data']['clientes'] ?? [];
          final clientes = clientesJson
              .map((json) => Cliente.fromJson(json as Map<String, dynamic>))
              .toList();
          return {
            'success': true,
            'clientes': clientes,
            'total': data['data']['total'],
            'page': data['data']['page'],
            'limit': data['data']['limit'],
          };
        } else {
          return {'success': false, 'error': data['message']};
        }
      } else {
        return {'success': false, 'error': 'Error ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getCliente(int id) async {
    try {
      final token = getToken();
      if (token == null) {
        return {'success': false, 'error': 'No token disponible'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/?resource=clientes&action=get&id=$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'cliente': Cliente.fromJson(data['data']),
          };
        } else {
          return {'success': false, 'error': data['message']};
        }
      } else {
        return {'success': false, 'error': 'Error ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // VEHÍCULOS

  Future<Map<String, dynamic>> getVehiculos({
    int? idCliente,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final token = getToken();
      if (token == null) {
        return {'success': false, 'error': 'No token disponible'};
      }

      String url = '$baseUrl/?resource=vehiculos&action=list&page=$page&limit=$limit';
      if (idCliente != null) {
        url += '&idCliente=$idCliente';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> vehiculosJson = data['data']['vehiculos'] ?? [];
          final vehiculos = vehiculosJson
              .map((json) => Vehiculo.fromJson(json as Map<String, dynamic>))
              .toList();
          return {
            'success': true,
            'vehiculos': vehiculos,
            'total': data['data']['total'],
            'page': data['data']['page'],
            'limit': data['data']['limit'],
          };
        } else {
          return {'success': false, 'error': data['message']};
        }
      } else {
        return {'success': false, 'error': 'Error ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ÓRDENES

  Future<Map<String, dynamic>> getOrdenes({int page = 1, int limit = 10}) async {
    try {
      final token = getToken();
      if (token == null) {
        return {'success': false, 'error': 'No token disponible'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/?resource=ordenes&action=list&page=$page&limit=$limit'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> ordenesJson = data['data']['ordenes'] ?? [];
          final ordenes = ordenesJson
              .map((json) => Orden.fromJson(json as Map<String, dynamic>))
              .toList();
          return {
            'success': true,
            'ordenes': ordenes,
            'total': data['data']['total'],
            'page': data['data']['page'],
            'limit': data['data']['limit'],
          };
        } else {
          return {'success': false, 'error': data['message']};
        }
      } else {
        return {'success': false, 'error': 'Error ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getOrden(int id) async {
    try {
      final token = getToken();
      if (token == null) {
        return {'success': false, 'error': 'No token disponible'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/?resource=ordenes&action=get&id=$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'orden': Orden.fromJson(data['data']),
          };
        } else {
          return {'success': false, 'error': data['message']};
        }
      } else {
        return {'success': false, 'error': 'Error ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
