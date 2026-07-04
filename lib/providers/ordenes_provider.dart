import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/index.dart';

class OrdenesProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Orden> _ordenes = [];
  List<Orden> _ordenesFiltradas = [];

  bool _isLoading = false;
  String? _error;

  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  int _limit = 10;
  String _currentQuery = "";
  Timer? _debounce;

  OrdenesProvider(this._apiService);

  List<Orden> get ordenes => _ordenesFiltradas;

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

  // Carga una página específica (10 órdenes por página) - Reemplaza la lista actual
  Future<void> loadOrdenes({int page = 1, int limit = 10}) async {
    _isLoading = true;
    _error = null;
    _limit = limit;
    notifyListeners();

    final result = await _apiService.getOrdenes(page: page, limit: limit);

    if (result['success'] == true) {
      _ordenes = result['ordenes'];

      // Leemos la página actual desde la respuesta usando 'pagina' (en español)
      _currentPage = int.tryParse(result['pagina'].toString()) ?? page;
      _total = int.tryParse(result['total'].toString()) ?? 0;
      _totalPages = (_total / limit).ceil();
      if (_totalPages < 1) _totalPages = 1;
      _error = null;

      if (_currentQuery.isEmpty) {
        _ordenesFiltradas = List.from(_ordenes);
      }
    } else {
      _error = result['error'];
      _ordenes = [];
      _ordenesFiltradas = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Carga las órdenes del cliente autenticado, ya filtradas por el backend
  // (no paginadas), a diferencia de loadOrdenes() que trae la lista global.
  Future<void> loadMisOrdenes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _apiService.getOrdenesCliente();

    if (result['success'] == true) {
      _ordenes = result['ordenes'];
      _total = _ordenes.length;
      _currentPage = 1;
      _totalPages = 1;
      _error = null;

      if (_currentQuery.isEmpty) {
        _ordenesFiltradas = List.from(_ordenes);
      }
    } else {
      _error = result['error'];
      _ordenes = [];
      _ordenesFiltradas = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> paginaSiguiente() async {
    if (hasNextPage) {
      await loadOrdenes(page: _currentPage + 1, limit: _limit);
    }
  }

  Future<void> paginaAnterior() async {
    if (hasPreviousPage) {
      await loadOrdenes(page: _currentPage - 1, limit: _limit);
    }
  }

  // Busca en todas las órdenes del backend, no solo en la página actualmente
  // cargada. Usa debounce para no disparar una petición por cada tecla.
  void buscarOrden(String query) {
    _currentQuery = query;
    _debounce?.cancel();

    if (query.isEmpty) {
      // Forzamos isLoading a false por si había una búsqueda en curso: al
      // ya no coincidir con _currentQuery, esa búsqueda se descartará sola
      // pero sin esto dejaría el spinner colgado indefinidamente.
      _isLoading = false;
      _ordenesFiltradas = List.from(_ordenes);
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

    final result = await _apiService.getOrdenes(
      page: 1,
      limit: _total > 0 ? _total : 100000,
    );

    // Si el usuario siguió escribiendo mientras esperábamos la respuesta,
    // descartamos este resultado obsoleto.
    if (query != _currentQuery) return;

    if (result['success'] == true) {
      final List<Orden> todas = result['ordenes'];
      final busqueda = query.toLowerCase();
      _ordenesFiltradas = todas.where((orden) {
        final id = orden.id.toString();
        final estado = orden.estadoText.toLowerCase();
        final cliente = orden.cliente.toLowerCase();
        return id.contains(busqueda) ||
            estado.contains(busqueda) ||
            cliente.contains(busqueda);
      }).toList();
    } else {
      _error = result['error'];
    }

    _isLoading = false;
    notifyListeners();
  }
}
