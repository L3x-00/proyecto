import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SeguimientosProvider with ChangeNotifier {
  final ApiService _apiService;

  SeguimientosProvider(this._apiService);

  List<Map<String, dynamic>> _seguimientos = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get seguimientos => _seguimientos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSeguimientos(int idOrden) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.getSeguimientos(idOrden);
      if (result['success']) {
        _seguimientos = List<Map<String, dynamic>>.from(result['seguimientos']);
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addSeguimiento(int idOrden, String observacion) async {
    try {
      final result = await _apiService.postSeguimiento(idOrden, observacion);
      if (result['success']) {
        // Recargar seguimientos después de agregar
        await loadSeguimientos(idOrden);
        return true;
      } else {
        _error = result['error'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}