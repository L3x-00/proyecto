import 'dart:async';
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
  Timer? _debounce;

  VehiculosProvider(this._apiService);

  List<Vehiculo> get vehiculos => _vehiculosFiltrados;

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get total => _total;
  bool get hasPreviousPage => _currentPage > 1;
  bool get hasNextPage => _currentPage < _totalPages;
  bool get isSearching => _currentQuery.isNotEmpty;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

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

      if (_currentQuery.isEmpty) {
        _vehiculosFiltrados = List.from(_vehiculos);
      }
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

  // Busca en todos los vehículos del backend, no solo en la página actualmente
  // cargada. Usa debounce para no disparar una petición por cada tecla.
  void buscarVehiculo(String query) {
    _currentQuery = query;
    _debounce?.cancel();

    if (query.isEmpty) {
      // Forzamos isLoading a false por si había una búsqueda en curso: al
      // ya no coincidir con _currentQuery, esa búsqueda se descartará sola
      // pero sin esto dejaría el spinner colgado indefinidamente.
      _isLoading = false;
      _vehiculosFiltrados = List.from(_vehiculos);
      notifyListeners();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _ejecutarBusqueda(query);
    });
  }

  Future<void> _ejecutarBusqueda(String query) async {
    _isLoading = true;
    notifyListeners();

    final result = await _apiService.getVehiculos(
      idCliente: _idCliente,
      page: 1,
      limit: _total > 0 ? _total : 100000,
    );

    // Si el usuario siguió escribiendo mientras esperábamos la respuesta,
    // descartamos este resultado obsoleto.
    if (query != _currentQuery) return;

    if (result['success'] == true) {
      final List<Vehiculo> todos = result['vehiculos'];
      final busqueda = query.toLowerCase();
      _vehiculosFiltrados = todos.where((vehiculo) {
        final placa = vehiculo.placas.toLowerCase();
        final modelo = vehiculo.modelo.toLowerCase();
        return placa.contains(busqueda) || modelo.contains(busqueda);
      }).toList();
    } else {
      _error = result['error'];
    }

    _isLoading = false;
    notifyListeners();
  }
}