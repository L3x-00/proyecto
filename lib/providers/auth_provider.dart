import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/index.dart'; // O la ruta correcta a tu usuario.dart

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  Usuario? _usuario;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._apiService);

  Usuario? get usuario => _usuario;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLogged => _apiService.isLogged();

  Future<bool> login(String correo, String clave) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _apiService.login(correo, clave);
    
    if (result['success'] == true) {
      _usuario = result['usuario'];
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = result['error'];
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    await _apiService.logout();
    _usuario = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  void restoreSession() {
    _usuario = _apiService.getUsuario();
    notifyListeners();
  }

  void actualizarUsuarioActual(String nuevosNombres, String nuevosApellidos, String nuevoTelefono, String nuevoCorreo) {
    if (_usuario != null) {
      _usuario = Usuario(
        id: _usuario!.id,
        nombres: nuevosNombres,
        apellidos: nuevosApellidos,
        correo: nuevoCorreo,
        tipo: _usuario!.tipo,
        token: _usuario!.token,
        telefono: nuevoTelefono,
      );
      notifyListeners(); 
    }
  }
}