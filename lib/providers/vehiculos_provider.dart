import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/index.dart';

class VehiculosProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<Vehiculo> _vehiculos = [];
  List<Vehiculo> _vehiculosFiltrados = [];

  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  int _limit = 10;
  int? _idCliente;
  String _currentQuery = "";

  VehiculosProvider(this._apiService);

  List<Vehiculo> get vehiculos => _vehiculosFiltrados;

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get total => _total;
  bool get hasPreviousPage => _currentPage > 1;
  bool get hasNextPage => _currentPage < _totalPages;

  // Carga una página específica (10 vehículos por página) - Reemplaza la lista actual
  Future<void> loadVehiculos({int? idCliente, int page = 1, int limit = 10}) async {
    _isLoading = true;
    _error = null;
    _idCliente = idCliente;
    _limit = limit;
    notifyListeners();

    final result = await _apiService.getVehiculos(idCliente: idCliente, page: page, limit: limit);

    if (result['success'] == true) {
      _vehiculos = result['vehiculos'];

      _currentPage = int.tryParse(result['pagina'].toString()) ?? page;
      _total = int.tryParse(result['total'].toString()) ?? 0;
      _totalPages = (_total / limit).ceil();
      if (_totalPages < 1) _totalPages = 1;
      _error = null;

      buscarVehiculo(_currentQuery);
    } else {
      _error = result['error'];
      _vehiculos = [];
      _vehiculosFiltrados = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> paginaSiguiente() async {
    if (hasNextPage) {
      await loadVehiculos(idCliente: _idCliente, page: _currentPage + 1, limit: _limit);
    }
  }

  Future<void> paginaAnterior() async {
    if (hasPreviousPage) {
      await loadVehiculos(idCliente: _idCliente, page: _currentPage - 1, limit: _limit);
    }
  }

  void buscarVehiculo(String query) {
    _currentQuery = query;
    if (query.isEmpty) {
      _vehiculosFiltrados = List.from(_vehiculos);
    } else {
      _vehiculosFiltrados = _vehiculos.where((vehiculo) {
        final placa = vehiculo.placas.toLowerCase();
        final modelo = vehiculo.modelo.toLowerCase(); 
        final busqueda = query.toLowerCase();
        
        return placa.contains(busqueda) || modelo.contains(busqueda);
      }).toList();
    }
    notifyListeners();
  }
}