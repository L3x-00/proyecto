import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/index.dart';

class MecanicosProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Mecanico> _mecanicos = []; // página actual (modo normal, sin filtros)
  List<Mecanico> _mecanicosFiltrados = [];

  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  int _limit = 10;
  int _currentEstado = 0;
  String _currentQuery = "";
  Timer? _debounce;
  int _requestId = 0;

  MecanicosProvider(this._apiService);

  List<Mecanico> get mecanicos => _mecanicosFiltrados;

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get total => _total;
  bool get hasPreviousPage => _currentPage > 1;
  bool get hasNextPage => _currentPage < _totalPages;

  // Hay un filtro de texto o de estado activo: en ese caso se muestra el
  // equipo completo filtrado (no paginado) en lugar de la página cargada.
  bool get isFiltering => _currentEstado != 0 || _currentQuery.isNotEmpty;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // Carga una página específica del equipo - Reemplaza la lista actual
  Future<void> loadMecanicos({int page = 1, int limit = 10}) async {
    _isLoading = true;
    _error = null;
    _limit = limit;
    notifyListeners();

    final result = await _apiService.getMecanicos(page: page, limit: limit);

    if (result['success'] == true) {
      _mecanicos = result['mecanicos'];

      _currentPage = int.tryParse(result['pagina'].toString()) ?? page;
      _total = int.tryParse(result['total'].toString()) ?? 0;
      _totalPages = (_total / limit).ceil();
      if (_totalPages < 1) _totalPages = 1;
      _error = null;

      if (!isFiltering) {
        _mecanicosFiltrados = List.from(_mecanicos);
      }
    } else {
      _error = result['error'];
      _mecanicos = [];
      _mecanicosFiltrados = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> paginaSiguiente() async {
    if (hasNextPage) {
      await loadMecanicos(page: _currentPage + 1, limit: _limit);
    }
  }

  Future<void> paginaAnterior() async {
    if (hasPreviousPage) {
      await loadMecanicos(page: _currentPage - 1, limit: _limit);
    }
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
      } else {
        _mecanicos.add(mecanico);
      }
      if (!isFiltering) {
        _mecanicosFiltrados = List.from(_mecanicos);
      }
      _error = null;
    } else {
      _error = result['error'];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Filtra por estado (Disponible/Ocupado/Vacaciones) en todo el equipo del
  // backend, no solo en la página actualmente cargada.
  void filtrarPorEstado(int estado) {
    _currentEstado = estado;
    _debounce?.cancel();
    _requestId++; // invalida cualquier búsqueda/filtro en curso

    if (!isFiltering) {
      _isLoading = false;
      _mecanicosFiltrados = List.from(_mecanicos);
      notifyListeners();
      return;
    }

    _ejecutarFiltro();
  }

  // Busca por nombre, especialidad, correo o teléfono en todo el equipo del
  // backend, no solo en la página actualmente cargada. Usa debounce para no
  // disparar una petición por cada tecla.
  void buscarMecanico(String query) {
    _currentQuery = query;
    _debounce?.cancel();
    _requestId++; // invalida cualquier búsqueda/filtro en curso

    if (!isFiltering) {
      _isLoading = false;
      _mecanicosFiltrados = List.from(_mecanicos);
      notifyListeners();
      return;
    }

    if (query.isEmpty) {
      // El texto se vació pero el filtro de estado sigue activo.
      _ejecutarFiltro();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _ejecutarFiltro();
    });
  }

  Future<void> _ejecutarFiltro() async {
    final int requestId = _requestId;
    _isLoading = true;
    notifyListeners();

    final result = await _apiService.getMecanicos(
      page: 1,
      limit: _total > 0 ? _total : 100000,
    );

    // Si el usuario cambió el filtro/búsqueda mientras esperábamos la
    // respuesta, descartamos este resultado obsoleto.
    if (requestId != _requestId) return;

    if (result['success'] == true) {
      final List<Mecanico> todos = result['mecanicos'];
      _mecanicosFiltrados = _aplicarFiltrosSobre(todos);
    } else {
      _error = result['error'];
    }

    _isLoading = false;
    notifyListeners();
  }

  List<Mecanico> _aplicarFiltrosSobre(List<Mecanico> base) {
    Iterable<Mecanico> resultado = base;

    if (_currentEstado != 0) {
      resultado = resultado.where((m) => m.estado == _currentEstado);
    }

    if (_currentQuery.isNotEmpty) {
      final busqueda = _currentQuery.toLowerCase();
      resultado = resultado.where((m) {
        return m.nombreCompleto.toLowerCase().contains(busqueda) ||
            m.nombreEspecialidad.toLowerCase().contains(busqueda) ||
            m.correo.toLowerCase().contains(busqueda) ||
            m.telefono.toLowerCase().contains(busqueda);
      });
    }

    return resultado.toList();
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
