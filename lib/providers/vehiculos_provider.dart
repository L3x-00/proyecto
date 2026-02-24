import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/index.dart';

class VehiculosProvider extends ChangeNotifier {
  final ApiService _apiService;
  List<Vehiculo> _vehiculos = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;

  VehiculosProvider(this._apiService);

  List<Vehiculo> get vehiculos => _vehiculos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get total => _total;

  Future<void> loadVehiculos({
    int? idCliente,
    int page = 1,
    int limit = 10,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _apiService.getVehiculos(
      idCliente: idCliente,
      page: page,
      limit: limit,
    );
    
    if (result['success'] == true) {
      _vehiculos = result['vehiculos'];
      
      _currentPage = int.tryParse(result['page'].toString()) ?? 1;
      _total = int.tryParse(result['total'].toString()) ?? 0;
      _totalPages = (_total / limit).ceil();
      _error = null;
    }else {
      _error = result['error'];
      _vehiculos = [];
    }
    
    _isLoading = false;
    notifyListeners();
  }
}
