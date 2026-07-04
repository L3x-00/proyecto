import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/index.dart';
import '../models/index.dart';
import '../services/api_service.dart';
import '../services/pusher_config.dart';
import '../services/notification_service.dart';
import '../constants/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/chatbot_fab.dart';

const int _porPagina = 10;

String _normalizarPlaca(String placa) => placa.trim().toUpperCase();

class ClienteScreen extends StatefulWidget {
  const ClienteScreen({Key? key}) : super(key: key);

  @override
  State<ClienteScreen> createState() => _ClienteScreenState();
}

class _ClienteScreenState extends State<ClienteScreen> {
  int _currentIndex = 0;
  late Future<List<dynamic>> _misVehiculos;
  Set<String>? _misPlacas;
  bool _errorVehiculos = false;
  final PusherConfig _pusherConfig = PusherConfig();

  @override
  void initState() {
    super.initState();
    _misVehiculos = context.read<ApiService>().obtenerMisVehiculos();
    _misVehiculos.then((vehiculos) {
      if (!mounted) return;
      setState(() {
        _misPlacas = vehiculos
            .map((v) => _normalizarPlaca((v['placas'] ?? '').toString()))
            .where((p) => p.isNotEmpty)
            .toSet();
      });
    }).catchError((_) {
      if (!mounted) return;
      setState(() => _errorVehiculos = true);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdenesProvider>().loadMisOrdenes();
    });

    final usuario = context.read<AuthProvider>().usuario;
    if (usuario != null) {
      _pusherConfig.initPusher(
        channelName: 'cliente-${usuario.id}',
        eventName: 'nueva-orden',
        onEventTriggered: (event) {
          NotificationService().showNuevaOrden(event.data,
              title: 'Tu vehículo ingresó al taller');
        },
      );
    }
  }

  @override
  void dispose() {
    _pusherConfig.disconnect();
    super.dispose();
  }

  List<Orden>? _misOrdenes(OrdenesProvider ordenesProvider) {
    final misPlacas = _misPlacas;
    if (misPlacas == null ||
        _errorVehiculos ||
        ordenesProvider.isLoading ||
        ordenesProvider.error != null) {
      return null;
    }
    return ordenesProvider.ordenes
        .where((o) => misPlacas.contains(_normalizarPlaca(o.placas)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final ordenesProvider = context.watch<OrdenesProvider>();
    final misOrdenes = _misOrdenes(ordenesProvider);

    final screens = [
      _ClienteDashboardTab(misOrdenes: misOrdenes),
      _MisVehiculosTab(
        misVehiculosFuture: _misVehiculos,
        errorVehiculos: _errorVehiculos,
      ),
      _MisOrdenesTab(
        misOrdenes: misOrdenes,
        ordenesProvider: ordenesProvider,
        errorVehiculos: _errorVehiculos,
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      floatingActionButton: const Padding(
        padding: EdgeInsets.only(bottom: 70),
        child: ChatbotFab(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: context.appColors.shadow,
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: context.appColors.surface,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey.shade500,
          showUnselectedLabels: true,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.normal, fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.dashboard_outlined)),
              activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.dashboard)),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.directions_car_outlined)),
              activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.directions_car)),
              label: 'Mis Vehículos',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.build_circle_outlined)),
              activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.build_circle)),
              label: 'Mis Órdenes',
            ),
          ],
        ),
      ),
    );
  }
}

/// Pestaña "Dashboard": saludo y tarjetas de resumen del cliente.
class _ClienteDashboardTab extends StatelessWidget {
  final List<Orden>? misOrdenes;

  const _ClienteDashboardTab({required this.misOrdenes});

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;
    final colors = context.appColors;

    return Scaffold(
      appBar: const AppHeader(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, ${usuario?.nombres ?? 'Cliente'}',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Resumen',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildDashboardStats(context, misOrdenes),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardStats(BuildContext context, List<Orden>? misOrdenes) {
    if (misOrdenes == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: CircularProgressIndicator(color: Color(0xFF00C6FF)),
        ),
      );
    }

    final ordenesActivas = misOrdenes.where((o) => o.estado == 1).length;
    final ordenesTotales = misOrdenes.length;

    final ahora = DateTime.now();
    double gastoTotal = 0;
    double gastoMes = 0;
    for (final orden in misOrdenes) {
      final monto = orden.monto ?? 0;
      gastoTotal += monto;
      final fecha = DateTime.tryParse(orden.fechaIngreso);
      if (fecha != null &&
          fecha.year == ahora.year &&
          fecha.month == ahora.month) {
        gastoMes += monto;
      }
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.35,
      children: [
        _buildStatCard(
          context,
          'Órdenes Activas',
          '$ordenesActivas',
          Icons.build_circle,
          const Color(0xFFFF3366),
          const Color(0xFFFF7733),
        ),
        _buildStatCard(
          context,
          'Órdenes Totales',
          '$ordenesTotales',
          Icons.auto_graph,
          const Color(0xFF8E2DE2),
          const Color(0xFF4A00E0),
        ),
        _buildStatCard(
          context,
          'Gasto Total',
          'S/ ${gastoTotal.toStringAsFixed(2)}',
          Icons.account_balance_wallet,
          const Color(0xFF11998E),
          const Color(0xFF38EF7D),
        ),
        _buildStatCard(
          context,
          'Gasto Este Mes',
          'S/ ${gastoMes.toStringAsFixed(2)}',
          Icons.calendar_month,
          const Color(0xFF00C6FF),
          const Color(0xFF0072FF),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color gradStart, Color gradEnd) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gradStart.withOpacity(0.2), gradEnd.withOpacity(0.2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: gradStart, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: colors.textPrimary.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Pestaña "Mis Vehículos": buscador + lista paginada localmente.
class _MisVehiculosTab extends StatefulWidget {
  final Future<List<dynamic>> misVehiculosFuture;
  final bool errorVehiculos;

  const _MisVehiculosTab({
    required this.misVehiculosFuture,
    required this.errorVehiculos,
  });

  @override
  State<_MisVehiculosTab> createState() => _MisVehiculosTabState();
}

class _MisVehiculosTabState extends State<_MisVehiculosTab> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  int _currentPage = 1;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value.trim().toLowerCase();
      _currentPage = 1;
    });
  }

  List<dynamic> _filtrar(List<dynamic> vehiculos) {
    if (_query.isEmpty) return vehiculos;
    return vehiculos.where((v) {
      final placa = (v['placas'] ?? '').toString().toLowerCase();
      final marca = (v['marca'] ?? '').toString().toLowerCase();
      final modelo = (v['modelo'] ?? '').toString().toLowerCase();
      return placa.contains(_query) ||
          marca.contains(_query) ||
          modelo.contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      appBar: AppHeader(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: _buscador(
              context,
              controller: _searchController,
              hintText: 'Buscar por placa o modelo...',
              onChanged: _onSearchChanged,
            ),
          ),
        ),
      ),
      body: widget.errorVehiculos
          ? _mensajeError(context,
              'No se pudieron cargar tus vehículos. Revisa tu conexión e '
              'intenta de nuevo.')
          : FutureBuilder<List<dynamic>>(
              future: widget.misVehiculosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(color: Color(0xFF00C6FF)),
                  );
                }

                if (snapshot.hasError) {
                  return _mensajeError(
                      context, 'Error: ${snapshot.error}');
                }

                final vehiculos = snapshot.data ?? [];
                if (vehiculos.isEmpty) {
                  return Center(
                    child: Text(
                      'Aún no tienes vehículos en el taller.',
                      style: TextStyle(color: colors.textMuted, fontSize: 14),
                    ),
                  );
                }

                final filtrados = _filtrar(vehiculos);
                if (filtrados.isEmpty) {
                  return Center(
                    child: Text(
                      'No se encontraron vehículos.',
                      style: TextStyle(color: colors.textMuted, fontSize: 14),
                    ),
                  );
                }

                final totalPages = (filtrados.length / _porPagina).ceil();
                final page = _currentPage.clamp(1, totalPages);
                final start = (page - 1) * _porPagina;
                final paginaActual =
                    filtrados.skip(start).take(_porPagina).toList();

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        itemCount: paginaActual.length,
                        itemBuilder: (context, index) =>
                            _VehiculoCard(vehiculo: paginaActual[index]),
                      ),
                    ),
                    if (totalPages > 1)
                      _LocalPaginacion(
                        currentPage: page,
                        totalPages: totalPages,
                        total: filtrados.length,
                        itemLabel: 'vehículos',
                        onPrevious: page > 1
                            ? () => setState(() => _currentPage = page - 1)
                            : null,
                        onNext: page < totalPages
                            ? () => setState(() => _currentPage = page + 1)
                            : null,
                      ),
                  ],
                );
              },
            ),
    );
  }
}

/// Pestaña "Mis Órdenes": buscador + lista paginada localmente.
class _MisOrdenesTab extends StatefulWidget {
  final List<Orden>? misOrdenes;
  final OrdenesProvider ordenesProvider;
  final bool errorVehiculos;

  const _MisOrdenesTab({
    required this.misOrdenes,
    required this.ordenesProvider,
    required this.errorVehiculos,
  });

  @override
  State<_MisOrdenesTab> createState() => _MisOrdenesTabState();
}

class _MisOrdenesTabState extends State<_MisOrdenesTab> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  int _currentPage = 1;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value.trim().toLowerCase();
      _currentPage = 1;
    });
  }

  List<Orden> _filtrar(List<Orden> ordenes) {
    if (_query.isEmpty) return ordenes;
    return ordenes.where((o) {
      final id = o.id.toString();
      final estado = o.estadoText.toLowerCase();
      final vehiculo = o.vehiculoCompleto.toLowerCase();
      return id.contains(_query) ||
          estado.contains(_query) ||
          vehiculo.contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: _buscador(
              context,
              controller: _searchController,
              hintText: 'Buscar por número, estado o vehículo...',
              onChanged: _onSearchChanged,
            ),
          ),
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final colors = context.appColors;

    if (widget.errorVehiculos) {
      return _mensajeError(context,
          'No se pudieron cargar tus vehículos, así que no se pueden '
          'mostrar tus órdenes. Revisa tu conexión e intenta de nuevo.');
    }

    if (widget.ordenesProvider.error != null) {
      return _mensajeError(context, widget.ordenesProvider.error!);
    }

    final misOrdenes = widget.misOrdenes;
    if (misOrdenes == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00C6FF)),
      );
    }

    if (misOrdenes.isEmpty) {
      return Center(
        child: Text(
          'No tienes órdenes registradas.',
          style: TextStyle(color: colors.textMuted, fontSize: 14),
        ),
      );
    }

    final filtradas = _filtrar(misOrdenes);
    if (filtradas.isEmpty) {
      return Center(
        child: Text(
          'No se encontraron órdenes.',
          style: TextStyle(color: colors.textMuted, fontSize: 14),
        ),
      );
    }

    final totalPages = (filtradas.length / _porPagina).ceil();
    final page = _currentPage.clamp(1, totalPages);
    final start = (page - 1) * _porPagina;
    final paginaActual = filtradas.skip(start).take(_porPagina).toList();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: paginaActual.length,
            itemBuilder: (context, index) =>
                _OrdenCard(orden: paginaActual[index]),
          ),
        ),
        if (totalPages > 1)
          _LocalPaginacion(
            currentPage: page,
            totalPages: totalPages,
            total: filtradas.length,
            itemLabel: 'órdenes',
            onPrevious: page > 1
                ? () => setState(() => _currentPage = page - 1)
                : null,
            onNext: page < totalPages
                ? () => setState(() => _currentPage = page + 1)
                : null,
          ),
      ],
    );
  }
}

Widget _buscador(
  BuildContext context, {
  required TextEditingController controller,
  required String hintText,
  required ValueChanged<String> onChanged,
}) {
  final colors = context.appColors;
  return Container(
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: colors.shadow,
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: TextField(
      controller: controller,
      style: TextStyle(color: colors.textPrimary),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: colors.textPrimary.withOpacity(0.4)),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF00C6FF)),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.close,
                    color: colors.textPrimary.withOpacity(0.5)),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFF00C6FF), width: 1.5),
        ),
      ),
    ),
  );
}

Widget _mensajeError(BuildContext context, String mensaje) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Text(
        mensaje,
        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

class _LocalPaginacion extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int total;
  final String itemLabel;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _LocalPaginacion({
    required this.currentPage,
    required this.totalPages,
    required this.total,
    required this.itemLabel,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: Icon(
              Icons.chevron_left,
              color: onPrevious != null ? colors.textPrimary : colors.textMuted,
            ),
          ),
          Text(
            'Página $currentPage de $totalPages · $total $itemLabel',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: Icon(
              Icons.chevron_right,
              color: onNext != null ? colors.textPrimary : colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _VehiculoCard extends StatelessWidget {
  final dynamic vehiculo;

  const _VehiculoCard({required this.vehiculo});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${vehiculo['marca']} ${vehiculo['modelo']}',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${vehiculo['anio']}',
                  style: const TextStyle(
                      color: Colors.blueAccent, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Placas: ${vehiculo['placas']} · Color: ${vehiculo['color']}',
            style: TextStyle(color: colors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _OrdenCard extends StatelessWidget {
  final Orden orden;

  const _OrdenCard({required this.orden});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isAbierta = orden.estado == 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.build_circle,
              size: 20,
              color:
                  isAbierta ? const Color(0xFFFF9800) : const Color(0xFF00E676)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Orden #${orden.id} · ${orden.vehiculoCompleto}',
                  style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Ingreso: ${orden.fechaIngreso}',
                  style: TextStyle(color: colors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            orden.estadoText,
            style: TextStyle(
              color:
                  isAbierta ? const Color(0xFFFF9800) : const Color(0xFF00E676),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
