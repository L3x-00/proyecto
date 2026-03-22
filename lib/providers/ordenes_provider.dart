import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/index.dart';

class OrdenesProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Orden> _ordenes = [];
  List<Orden> _ordenesFiltradas = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  String _currentQuery = "";

  OrdenesProvider(this._apiService);

  List<Orden> get ordenes => _ordenesFiltradas;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMorePages => _currentPage < _totalPages;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get total => _total;

  // Carga inicial (Página 1) - Reemplaza toda la lista
  Future<void> loadOrdenes({int limit = 10}) async {
    _isLoading = true;
    _error = null;
    _currentPage = 1;
    notifyListeners();

    final result =
        await _apiService.getOrdenes(page: _currentPage, limit: limit);

    if (result['success'] == true) {
      _ordenes = result['ordenes'];

      // Leemos la página actual desde la respuesta usando 'pagina' (en español)
      _currentPage = int.tryParse(result['pagina'].toString()) ?? 1;
      _total = int.tryParse(result['total'].toString()) ?? 0;
      _totalPages = (_total / limit).ceil();
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

  // Carga la siguiente página y la AÑADE a la lista existente
  Future<void> loadMoreOrdenes({int limit = 10}) async {
    if (_isLoadingMore || !hasMorePages) return;

    _isLoadingMore = true;
    notifyListeners();

    final nextPage = _currentPage + 1;
    final result = await _apiService.getOrdenes(page: nextPage, limit: limit);

    if (result['success'] == true) {
      _currentPage = nextPage;

      List<Orden> nuevasOrdenes = result['ordenes'];
      _ordenes.addAll(nuevasOrdenes);

      buscarOrden(_currentQuery);
    } else {
      debugPrint("Error cargando más órdenes: ${result['error']}");
    }

    _isLoadingMore = false;
    notifyListeners();
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
