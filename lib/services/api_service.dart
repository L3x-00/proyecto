import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/index.dart';

class ApiService {
  static const String baseUrl =
      'https://www.xtremeperformancepe.com/public/api';
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
        if (data['success'] == true || data['status'] == 'success') {
          final token = data['data']['token'];
          final usuario = Usuario.fromJson(data['data']['usuario']);

          await _prefs.setString(_tokenKey, token);
          await _prefs.setString(_userKey, jsonEncode(usuario.toJson()));

          return {'success': true, 'token': token, 'usuario': usuario};
        } else {
          return {
            'success': false,
            'error': data['message'] ?? 'Error en login'
          };
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

  Future<Map<String, dynamic>> getClientes(
      {int page = 1, int limit = 10}) async {
    try {
      final token = getToken();
      if (token == null) {
        return {'success': false, 'error': 'No token disponible'};
      }

      final response = await http.get(
        Uri.parse(
            '$baseUrl/?resource=clientes&action=list&page=$page&limit=$limit'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true || data['status'] == 'success') {
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
        if (data['success'] == true || data['status'] == 'success') {
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

      String url =
          '$baseUrl/?resource=vehiculos&action=list&page=$page&limit=$limit';
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
        if (data['success'] == true || data['status'] == 'success') {
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

  Future<Map<String, dynamic>> getOrdenes(
      {int page = 1, int limit = 10}) async {
    try {
      final token = getToken();
      if (token == null) {
        return {'success': false, 'error': 'No token disponible'};
      }

      final response = await http.get(
        Uri.parse(
            '$baseUrl/?resource=ordenes&action=list&page=$page&limit=$limit'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true || data['status'] == 'success') {
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
        if (data['success'] == true || data['status'] == 'success') {
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

  // DASHBOARD

  Future<Map<String, dynamic>> getKpis() async {
    try {
      final token = getToken();
      if (token == null) {
        return {'success': false, 'error': 'No token disponible'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/?resource=tablero&action=kpis'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('DEBUG: URL = $baseUrl/?resource=tablero&action=kpis');
      print('DEBUG: Status = ${response.statusCode}');
      String bodyLog = response.body.length > 500
          ? response.body.substring(0, 500) + '...'
          : response.body;
      print('DEBUG: Body = $bodyLog'); // Primeros 500 chars

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          // ACEPTAMOS AMBOS FORMATOS (Booleano o Texto)
          if (data is Map &&
              (data['success'] == true || data['status'] == 'success')) {
            return {
              'success': true,
              'kpis': data['data'],
            };
          } else if (data is Map) {
            return {
              'success': false,
              'error': data['message'] ?? 'Error desconocido'
            };
          } else {
            return {
              'success': false,
              'error': 'Respuesta inesperada del servidor',
              'body': response.body,
            };
          }
        } catch (err) {
          return {
            'success': false,
            'error': 'No se pudo parsear JSON: ${err.toString()}',
            'body': response.body,
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Error ${response.statusCode}',
          'body': response.body
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getIngresosMensuales({int meses = 6}) async {
    try {
      final token = getToken();
      if (token == null) {
        return {'success': false, 'error': 'No token disponible'};
      }

      final response = await http.get(
        Uri.parse(
            '$baseUrl/?resource=tablero&action=ingresos_mensuales&meses=$meses'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          // ACEPTAMOS AMBOS FORMATOS (Booleano o Texto)
          if (data is Map &&
              (data['success'] == true || data['status'] == 'success')) {
            return {
              'success': true,
              'ingresos': data['data'],
            };
          } else if (data is Map) {
            return {
              'success': false,
              'error': data['message'] ?? 'Error desconocido'
            };
          } else {
            return {
              'success': false,
              'error': 'Respuesta inesperada del servidor',
              'body': response.body,
            };
          }
        } catch (err) {
          return {
            'success': false,
            'error': 'No se pudo parsear JSON: ${err.toString()}',
            'body': response.body,
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Error ${response.statusCode}',
          'body': response.body
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
// Función para actualizar el perfil
  Future<Map<String, dynamic>> actualizarPerfil(int id, String nombres, String apellidos, String telefono, String correo) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/endpoints/editar_perfil.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': id,
          'nombres': nombres,
          'apellidos': apellidos,
          'telefono': telefono,
          'correo': correo,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'error': 'Error de servidor: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> getSeguimientos(int idOrden) async {
    try {
      final token = getToken();
      if (token == null) {
        return {'success': false, 'error': 'No token disponible'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/?resource=seguimientos&action=listar&idOrden=$idOrden'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data is Map &&
              (data['success'] == true || data['status'] == 'success')) {
            final List<dynamic> seguimientosJson = data['data'] ?? [];
            return {
              'success': true,
              'seguimientos': seguimientosJson,
            };
          } else if (data is Map) {
            return {
              'success': false,
              'error': data['message'] ?? 'Error desconocido'
            };
          } else {
            return {
              'success': false,
              'error': 'Respuesta inesperada del servidor',
              'body': response.body,
            };
          }
        } catch (err) {
          return {
            'success': false,
            'error': 'No se pudo parsear JSON: ${err.toString()}',
            'body': response.body,
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Error ${response.statusCode}',
          'body': response.body
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> postSeguimiento(int idOrden, String observacion) async {
    try {
      final token = getToken();
      if (token == null) {
        return {'success': false, 'error': 'No token disponible'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/?resource=seguimientos&action=alta'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'idOrdenReparacion': idOrden.toString(),
          'observacion': observacion,
          'fecha': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data is Map &&
              (data['success'] == true || data['status'] == 'success')) {
            return {
              'success': true,
              'id': data['data']['id'],
            };
          } else if (data is Map) {
            return {
              'success': false,
              'error': data['message'] ?? 'Error desconocido'
            };
          } else {
            return {
              'success': false,
              'error': 'Respuesta inesperada del servidor',
              'body': response.body,
            };
          }
        } catch (err) {
          return {
            'success': false,
            'error': 'No se pudo parsear JSON: ${err.toString()}',
            'body': response.body,
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Error ${response.statusCode}',
          'body': response.body
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
