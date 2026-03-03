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

  OrdenesProvider(this._apiService);

  List<Orden> get ordenes => _ordenesFiltradas;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get total => _total;

  Future<void> loadOrdenes({int page = 1, int limit = 10}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _apiService.getOrdenes(page: page, limit: limit);
    
    if (result['success'] == true) {
      _ordenes = result['ordenes'];
      _ordenesFiltradas = List.from(_ordenes);
      
      _currentPage = int.tryParse(result['page'].toString()) ?? 1;
      _total = int.tryParse(result['total'].toString()) ?? 0;
      _totalPages = (_total / limit).ceil();
      _error = null;
    } else {
      _error = result['error'];
      _ordenes = [];
      _ordenesFiltradas = [];
    }
    
    _isLoading = false;
    notifyListeners();
  }

  void buscarOrden(String query) {
    if (query.isEmpty) {
      _ordenesFiltradas = List.from(_ordenes);
    } else {
      _ordenesFiltradas = _ordenes.where((orden) {
        final id = orden.id.toString();
        // Usamos estadoText en lugar de estado
        final estado = orden.estadoText.toLowerCase(); 
        final cliente = orden.cliente.toLowerCase();
        final busqueda = query.toLowerCase();
        
        return id.contains(busqueda) || estado.contains(busqueda) || cliente.contains(busqueda);
      }).toList();
    }
    notifyListeners();
  }
}