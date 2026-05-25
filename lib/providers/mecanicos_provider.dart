import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/index.dart';

class MecanicosProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<Mecanico> _mecanicos = [];
  List<Mecanico> _mecanicosFiltrados = []; 
  
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;

  MecanicosProvider(this._apiService);

  List<Mecanico> get mecanicos => _mecanicosFiltrados; 
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get total => _total;

  Future<void> loadMecanicos({int page = 1, int limit = 10}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _apiService.getMecanicos(page: page, limit: limit);
    
    if (result['success'] == true) {
      _mecanicos = result['mecanicos'];
      _mecanicosFiltrados = List.from(_mecanicos); 
      
      _currentPage = int.tryParse(result['pagina'].toString()) ?? 1;
      _total = int.tryParse(result['total'].toString()) ?? 0;
      _totalPages = (_total / limit).ceil();
      _error = null;
    } else {
      _error = result['error'];
      _mecanicos = [];
      _mecanicosFiltrados = [];
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMecanico(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _apiService.getMecanico(id);
    
    if (result['success'] == true) {
      final mecanico = result['mecanico'] as Mecanico;
      final index = _mecanicos.indexWhere((m) => m.id == id);
      if (index != -1) {
        _mecanicos[index] = mecanico;
        _mecanicosFiltrados = List.from(_mecanicos);
      } else {
        _mecanicos.add(mecanico);
        _mecanicosFiltrados = List.from(_mecanicos);
      }
      _error = null;
    } else {
      _error = result['error'];
    }
    
    _isLoading = false;
    notifyListeners();
  }

  void filtrarPorEspecialidad(int especialidad) {
    if (especialidad == 0) {
      _mecanicosFiltrados = List.from(_mecanicos);
    } else {
      _mecanicosFiltrados = _mecanicos
          .where((mecanico) => mecanico.idTipoMecanico == especialidad)
          .toList();
    }
    notifyListeners();
  }

  void filtrarPorEstado(int estado) {
    if (estado == 0) {
      _mecanicosFiltrados = List.from(_mecanicos);
    } else {
      _mecanicosFiltrados = _mecanicos
          .where((mecanico) => mecanico.estado == estado)
          .toList();
    }
    notifyListeners();
  }

  List<Mecanico> get mecanicosdisponibles {
    return _mecanicos.where((mecanico) => mecanico.estaDisponible).toList();
  }

  List<Mecanico> get mecanicosOcupados {
    return _mecanicos.where((mecanico) => mecanico.estaOcupado).toList();
  }

  List<Mecanico> get mecanicosEnVacaciones {
    return _mecanicos.where((mecanico) => mecanico.estaEnVacaciones).toList();
  }
}
