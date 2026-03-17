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
        final List<dynamic> datosRaw = result['seguimientos'] ?? [];

        List<Map<String, dynamic>> listaTemporal =
            datosRaw.map((e) => Map<String, dynamic>.from(e)).toList();

        listaTemporal.sort((a, b) {
          int idA = int.parse(a['id'].toString());
          int idB = int.parse(b['id'].toString());
          return idB.compareTo(idA);
        });

        _seguimientos = listaTemporal;
      } else {
        _error = result['error']?.toString();
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
