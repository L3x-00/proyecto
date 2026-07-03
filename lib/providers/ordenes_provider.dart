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

  OrdenesProvider(this._apiService);

  List<Orden> get ordenes => _ordenesFiltradas;

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get total => _total;
  bool get hasPreviousPage => _currentPage > 1;
  bool get hasNextPage => _currentPage < _totalPages;

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

      buscarOrden(_currentQuery);
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

  void buscarOrden(String query) {
    _currentQuery = query;

    if (query.isEmpty) {
      _ordenesFiltradas = List.from(_ordenes);
    } else {
      _ordenesFiltradas = _ordenes.where((orden) {
        final id = orden.id.toString();
        final estado = orden.estadoText.toLowerCase();
        final cliente = orden.cliente.toLowerCase();
        final busqueda = query.toLowerCase();

        return id.contains(busqueda) ||
            estado.contains(busqueda) ||
            cliente.contains(busqueda);
      }).toList();
    }
    notifyListeners();
  }
}
