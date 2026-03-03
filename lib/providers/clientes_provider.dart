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

  ClientesProvider(this._apiService);

  List<Cliente> get clientes => _clientesFiltrados; 
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get total => _total;

  Future<void> loadClientes({int page = 1, int limit = 10}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _apiService.getClientes(page: page, limit: limit);
    
    if (result['success'] == true) {
      _clientes = result['clientes'];
      _clientesFiltrados = List.from(_clientes); 
      
      _currentPage = int.tryParse(result['page'].toString()) ?? 1;
      _total = int.tryParse(result['total'].toString()) ?? 0;
      _totalPages = (_total / limit).ceil();
      _error = null;
    } else {
      _error = result['error'];
      _clientes = [];
      _clientesFiltrados = [];
    }
    
    _isLoading = false;
    notifyListeners();
  }

  void buscarCliente(String query) {
    if (query.isEmpty) {
      _clientesFiltrados = List.from(_clientes);
    } else {
      _clientesFiltrados = _clientes.where((cliente) {
        final nombre = cliente.nombre.toLowerCase();
        final ruc = cliente.ruc.toLowerCase();
        final busqueda = query.toLowerCase();
        
        return nombre.contains(busqueda) || ruc.contains(busqueda);
      }).toList();
    }
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