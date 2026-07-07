import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import '../models/index.dart';

class ApiService {
  static const String baseUrl =
      'https://www.xtremeperformancepe.com/public/api';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
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
        print('Login response body: ${response.body}');
        if (data['success'] == true || data['status'] == 'success') {
          final token = data['data']['token'];
          final usuario = Usuario.fromJson(data['data']['usuario']);
          print('Parsed usuario.tipo=${usuario.tipo} for login');

          await _prefs!.setString(_tokenKey, token);
          await _prefs!.setString(_userKey, jsonEncode(usuario.toJson()));

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
    await _prefs?.remove(_tokenKey);
    await _prefs?.remove(_userKey);
    return true;
  }

  String? getToken() {
    return _prefs?.getString(_tokenKey);
  }

  Usuario? getUsuario() {
    final userData = _prefs?.getString(_userKey);
    if (userData != null) {
      return Usuario.fromJson(jsonDecode(userData));
    }
    return null;
  }

  Future<void> guardarUsuario(Usuario usuario) async {
    await _prefs?.setString(_userKey, jsonEncode(usuario.toJson()));
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

      // CORRECCIÓN: Usando 'pagina' y 'limite' para PHP
      final response = await http.get(
        Uri.parse(
            '$baseUrl/?resource=clientes&action=list&pagina=$page&limite=$limit'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      // === AGREGA ESTO PARA DESCUBRIR EL PROBLEMA ===
      print('--- DEBUG VEHÍCULOS ---');
      print('URL SOLICITADA: $baseUrl');
      print('CÓDIGO HTTP: ${response.statusCode}');
      print('RESPUESTA DEL SERVIDOR: ${response.body}');
      print('-----------------------');

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
            'pagina': data['data']['pagina'] ?? page,
            'limite': data['data']['limite'] ?? limit,
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

      // CORRECCIÓN: Usando 'pagina' y 'limite' para PHP
      String url =
          '$baseUrl/?resource=vehiculos&action=list&pagina=$page&limite=$limit';
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
            'pagina': data['data']['pagina'] ?? page,
            'limite': data['data']['limite'] ?? limit,
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

      // CORRECCIÓN PRINCIPAL: Aquí cambiamos a variables en español para PHP
      final response = await http.get(
        Uri.parse(
            '$baseUrl/?resource=ordenes&action=list&pagina=$page&limite=$limit'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data;
        try {
          data = jsonDecode(response.body);
        } on FormatException {
          // El backend devolvió algo que no es JSON (p. ej. un warning/error
          // PHP impreso como HTML). Se imprime el cuerpo crudo para poder
          // diagnosticar el endpoint desde los logs de debug.
          print('Respuesta no-JSON en ordenes.list: ${response.body}');
          return {
            'success': false,
            'error':
                'El servidor devolvió una respuesta inválida al listar las órdenes. Intenta de nuevo más tarde.',
          };
        }

        if (data['success'] == true || data['status'] == 'success') {
          final List<dynamic> ordenesJson = data['data']['ordenes'] ?? [];
          final ordenes = ordenesJson
              .map((json) => Orden.fromJson(json as Map<String, dynamic>))
              .toList();
          return {
            'success': true,
            'ordenes': ordenes,
            'total': data['data']['total'],
            'pagina': data['data']['pagina'] ?? page, // Devuelve 'pagina'
            'limite': data['data']['limite'] ?? limit, // Devuelve 'limite'
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

// VEHCÍCULOS DEL CLIENTE
  // VEHÍCULOS DEL CLIENTE (FILTRADOS)
  Future<List<dynamic>> obtenerMisVehiculos() async {
    try {
      // 1. Usamos tu función interna para obtener el token
      final token = getToken();
      if (token == null) {
        throw Exception('No token disponible');
      }

      // 2. Usamos tu baseUrl.
      // Dependiendo de cómo guardaste el archivo PHP, usa una de estas dos rutas.
      // Si subiste el archivo directamente a la carpeta api/endpoints/:
      final url = Uri.parse('$baseUrl/endpoints/mis_vehiculos.php');

      // (OPCIONAL) Si tu API usa el enrutador como en getOrden, sería algo así:
      // final url = Uri.parse('$baseUrl/?resource=vehiculos&action=mis_vehiculos');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // (Opcional) Un print limpio para verificar en consola
      print('=== DEBUG MIS VEHÍCULOS ===');
      print('URL SOLICITADA: $url');
      print('===========================');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Verificamos si la respuesta del PHP fue exitosa
        if (data['success'] == true || data['status'] == 'success') {
          return data['data']['vehiculos'] ?? [];
        } else {
          throw Exception(data['message'] ?? 'Error al obtener vehículos');
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en la petición de vehículos: $e');
      rethrow;
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

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
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

  Future<Map<String, dynamic>> actualizarPerfil(int id, String nombres,
      String apellidos, String telefono, String correo) async {
    try {
      final token = getToken();
      if (token == null) {
        return {'success': false, 'error': 'No token disponible'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/endpoints/editar_perfil.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
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
        return {
          'success': false,
          'error': 'Error de servidor: ${response.statusCode}'
        };
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
        Uri.parse(
            '$baseUrl/?resource=seguimientos&action=listar&idOrden=$idOrden'),
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

  Future<Map<String, dynamic>> postSeguimiento(
      int idOrden, String observacion, {File? imagen}) async {
    try {
      final token = getToken();
      if (token == null) {
        return {'success': false, 'error': 'No token disponible'};
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/?resource=seguimientos&action=alta'),
      );
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      request.fields['idOrdenReparacion'] = idOrden.toString();
      request.fields['observacion'] = observacion;
      request.fields['fecha'] = DateTime.now().toIso8601String();

      if (imagen != null) {
        request.files
            .add(await http.MultipartFile.fromPath('fotos[]', imagen.path));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

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

  // CHATBOT ("Maestrito")
  // Unifica el envío de mensajes de texto y, opcionalmente, una foto para
  // diagnóstico visual (testigo del tablero, fuga, pieza dañada, etc.). La
  // imagen va como base64 dentro del mismo JSON porque chatbot_pro.php lee
  // el body con json_decode(php://input) y toda su lógica de roles depende
  // de ese formato (no vale la pena migrar a multipart solo por esto).
  Future<Map<String, dynamic>> enviarMensajeChatbot({
    required String mensaje,
    File? imagen,
  }) async {
    try {
      final token = getToken();
      final usuario = getUsuario();

      final body = <String, dynamic>{
        'mensaje': mensaje,
        // El backend deriva rol/id del token; se mantienen solo por
        // compatibilidad (mismo comentario que tenía chatbot_screen.dart).
        'rol': usuario != null ? _rolParaChatbot(usuario.tipo) : 'VISITANTE',
        'id_usuario': usuario?.id ?? 0,
      };

      if (imagen != null) {
        final bytes = await imagen.readAsBytes();
        body['imagen_base64'] = base64Encode(bytes);
        body['imagen_mime'] = 'image/jpeg';
      }

      final response = await http.post(
        Uri.parse('$baseUrl/endpoints/chatbot_pro.php'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'respuesta': data['respuesta'] ?? '',
          'chart': data['chart'],
        };
      } else {
        return {'success': false, 'error': 'Error ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Mismo mapeo de roles que usaba chatbot_screen.dart::_rolParaChatbot; el
  // backend (chatbot_pro.php) solo reconoce 'ADMON', 'CLIENTE' y 'MECANICO'.
  String _rolParaChatbot(int tipo) {
    switch (tipo) {
      case 1: // admin
      case 2: // operador
        return 'ADMON';
      case 3: // mecanico
        return 'MECANICO';
      case 4: // cliente
        return 'CLIENTE';
      default:
        return 'VISITANTE';
    }
  }

  // MECÁNICOS
  Future<Map<String, dynamic>> getMecanicos(
      {int page = 1, int limit = 10}) async {
    try {
      final token = getToken();
      if (token == null) {
        return {'success': false, 'error': 'No token disponible'};
      }

      final response = await http.get(
        Uri.parse(
            '$baseUrl/?resource=mecanicos&action=list&pagina=$page&limite=$limit'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true || data['status'] == 'success') {
          final List<dynamic> mecanicosJson = data['data']['mecanicos'] ?? [];
          final mecanicos = mecanicosJson
              .map((json) => Mecanico.fromJson(json as Map<String, dynamic>))
              .toList();
          return {
            'success': true,
            'mecanicos': mecanicos,
            'total': data['data']['total'],
            'pagina': data['data']['pagina'] ?? page,
            'limite': data['data']['limite'] ?? limit,
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

  Future<Map<String, dynamic>> getMecanico(int id) async {
    try {
      final token = getToken();
      if (token == null) {
        return {'success': false, 'error': 'No token disponible'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/?resource=mecanicos&action=get&id=$id'),
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
            'mecanico': Mecanico.fromJson(data['data']),
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

  Future<Map<String, dynamic>> getOrdenesMecanico(int idMecanico) async {
    try {
      final token = getToken();
      if (token == null)
        return {'success': false, 'error': 'No token disponible'};

      final response = await http.get(
        Uri.parse(
            '$baseUrl/?resource=ordenes&action=list&idMecanico=$idMecanico&limite=100'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true || data['status'] == 'success') {
          final List<dynamic> json = data['data']['ordenes'] ?? [];
          return {
            'success': true,
            'ordenes': json
                .map((j) => Orden.fromJson(j as Map<String, dynamic>))
                .toList(),
          };
        }
        return {
          'success': false,
          'error': data['message'] ?? 'Error desconocido'
        };
      }
      return {'success': false, 'error': 'Error ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getOrdenesCliente() async {
    try {
      // Leemos todo directo de la memoria
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final userData = prefs.getString(_userKey);

      if (token == null || userData == null) {
        return {'success': false, 'error': 'No token disponible'};
      }

      // Extraemos el ID
      final usuario = Usuario.fromJson(jsonDecode(userData));
      final idCliente = usuario.id;

      // Armamos la URL usando el routing de tu index.php
      final url = Uri.parse(
          '$baseUrl/?resource=ordenes&action=list&idCliente=$idCliente');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true || data['status'] == 'success') {
          // 1. Extraemos la lista cruda (JSON) que viene de PHP
          final List<dynamic> ordenesJson =
              data['data']['ordenes'] ?? data['data'] ?? [];

          // 2. Traducimos cada elemento JSON a un objeto de tu clase 'Orden'
          final ordenes = ordenesJson
              .map((json) => Orden.fromJson(json as Map<String, dynamic>))
              .toList();

          return {
            'success': true,
            'ordenes':
                ordenes, // <-- Ahora sí enviamos la lista de objetos Orden listos para usarse
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

  Future<Map<String, dynamic>> actualizarPerfilUsuario(
      int id, String nombres, String apellidos) async {
    try {
      final token = getToken();
      if (token == null)
        return {'success': false, 'error': 'No token disponible'};

      final response = await http.post(
        Uri.parse('$baseUrl/?resource=usuarios&action=actualizar'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body:
            jsonEncode({'id': id, 'nombres': nombres, 'apellidos': apellidos}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true || data['status'] == 'success') {
          return {'success': true};
        }
        return {
          'success': false,
          'error': data['message'] ?? 'Error al actualizar'
        };
      }
      return {'success': false, 'error': 'Error ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> cambiarClave(int id, String nuevaClave) async {
    try {
      final token = getToken();
      if (token == null)
        return {'success': false, 'error': 'No token disponible'};

      final response = await http.post(
        Uri.parse('$baseUrl/?resource=usuarios&action=cambiar_clave'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'id': id, 'clave': nuevaClave}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true || data['status'] == 'success') {
          return {'success': true};
        }
        return {
          'success': false,
          'error': data['message'] ?? 'Error al cambiar clave'
        };
      }
      return {'success': false, 'error': 'Error ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
