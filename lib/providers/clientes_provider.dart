import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/index.dart';

class ClientesProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Cliente> _clientes = [];
  List<Cliente> _clientesFiltrados = [];

  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  int _limit = 10;
  String _currentQuery = "";
  Timer? _debounce;

  ClientesProvider(this._apiService);

  List<Cliente> get clientes => _clientesFiltrados;

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

  // Carga una página específica (10 clientes por página) - Reemplaza la lista actual
  Future<void> loadClientes({int page = 1, int limit = 10}) async {
    _isLoading = true;
    _error = null;
    _limit = limit;
    notifyListeners();

    final result = await _apiService.getClientes(page: page, limit: limit);

    if (result['success'] == true) {
      _clientes = result['clientes'];

      _currentPage = int.tryParse(result['pagina'].toString()) ?? page;
      _total = int.tryParse(result['total'].toString()) ?? 0;
      _totalPages = (_total / limit).ceil();
      if (_totalPages < 1) _totalPages = 1;
      _error = null;

      if (_currentQuery.isEmpty) {
        _clientesFiltrados = List.from(_clientes);
      }
    } else {
      _error = result['error'];
      _clientes = [];
      _clientesFiltrados = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> paginaSiguiente() async {
    if (hasNextPage) {
      await loadClientes(page: _currentPage + 1, limit: _limit);
    }
  }

  Future<void> paginaAnterior() async {
    if (hasPreviousPage) {
      await loadClientes(page: _currentPage - 1, limit: _limit);
    }
  }

  // Busca en todos los clientes del backend, no solo en la página actualmente
  // cargada. Usa debounce para no disparar una petición por cada tecla.
  void buscarCliente(String query) {
    _currentQuery = query;
    _debounce?.cancel();

    if (query.isEmpty) {
      // Forzamos isLoading a false por si había una búsqueda en curso: al
      // ya no coincidir con _currentQuery, esa búsqueda se descartará sola
      // pero sin esto dejaría el spinner colgado indefinidamente.
      _isLoading = false;
      _clientesFiltrados = List.from(_clientes);
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

    final result = await _apiService.getClientes(
      page: 1,
      limit: _total > 0 ? _total : 100000,
    );

    // Si el usuario siguió escribiendo mientras esperábamos la respuesta,
    // descartamos este resultado obsoleto.
    if (query != _currentQuery) return;

    if (result['success'] == true) {
      final List<Cliente> todos = result['clientes'];
      final busqueda = query.toLowerCase();
      _clientesFiltrados = todos.where((cliente) {
        final nombre = cliente.nombre.toLowerCase();
        final ruc = cliente.ruc.toLowerCase();
        return nombre.contains(busqueda) || ruc.contains(busqueda);
      }).toList();
    } else {
      _error = result['error'];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Cliente?> loadCliente(int id) async {
    final result = await _apiService.getCliente(id);
    if (result['success'] == true) {
      return result['cliente'];
    } else {
      _error = result['error'];
      notifyListeners();
      return null;
    }
  }
}