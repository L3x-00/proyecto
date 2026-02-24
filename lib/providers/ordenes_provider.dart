import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/index.dart';

class OrdenesProvider extends ChangeNotifier {
  final ApiService _apiService;
  List<Orden> _ordenes = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;

  OrdenesProvider(this._apiService);

  List<Orden> get ordenes => _ordenes;
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
      
      _currentPage = int.tryParse(result['page'].toString()) ?? 1;
      _total = int.tryParse(result['total'].toString()) ?? 0;
      _totalPages = (_total / limit).ceil();
      _error = null;
    } else {
      _error = result['error'];
      _ordenes = [];
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<Orden?> loadOrden(int id) async {
    final result = await _apiService.getOrden(id);
    if (result['success'] == true) {
      return result['orden'];
    } else {
      _error = result['error'];
      notifyListeners();
      return null;
    }
  }
}
