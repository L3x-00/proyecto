import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/index.dart';
import '../services/api_service.dart';
import '../models/index.dart';

class ClienteScreen extends StatefulWidget {
  const ClienteScreen({Key? key}) : super(key: key);

  @override
  State<ClienteScreen> createState() => _ClienteScreenState();
}

class _ClienteScreenState extends State<ClienteScreen> {
  List<Orden> _ordenes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarOrdenes();
  }

  Future<void> _cargarOrdenes() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final apiService = ApiService();
    await apiService.init();
    final result = await apiService.getOrdenesCliente();
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() {
        _ordenes = List<Orden>.from(result['ordenes'] as List);
        _loading = false;
      });
    } else {
      setState(() {
        _error = result['error']?.toString();
        _loading = false;
      });
    }
  }

  int get _ordenesActivas => _ordenes.where((o) => o.estado == 1).length;
  int get _ordenesTotales => _ordenes.length;

  double get _gastoTotal =>
      _ordenes.fold(0.0, (sum, o) => sum + (o.monto ?? 0.0));

  double get _gastoMes {
    final now = DateTime.now();
    return _ordenes
        .where((o) {
          try {
            final f = DateTime.parse(o.fechaIngreso);
            return f.year == now.year && f.month == now.month;
          } catch (_) {
            return false;
          }
        })
        .fold(0.0, (sum, o) => sum + (o.monto ?? 0.0));
  }

  String _fmt(String? fecha) {
    if (fecha == null || fecha.isEmpty) return '—';
    try {
      final dt = DateTime.parse(fecha);
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
    } catch (_) {
      return fecha;
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;

    return Scaffold(
      backgroundColor: const Color(0xFF12171D),
      appBar: AppBar(
        title: const Text('Mi Taller'),
        backgroundColor: const Color(0xFF1A222C),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarOrdenes,
        color: Colors.blueAccent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, ${usuario?.nombres ?? 'Cliente'}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('Estado de tus vehículos en taller',
                  style: TextStyle(color: Colors.white54, fontSize: 13)),
              const SizedBox(height: 20),

              // ── KPI cards 2×2 ──────────────────────────────
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  _kpiCard(
                      'Órdenes\nActivas',
                      '$_ordenesActivas',
                      Colors.blueAccent,
                      Icons.folder_open,
                      isMoney: false),
                  _kpiCard(
                      'Órdenes\nTotales',
                      '$_ordenesTotales',
                      Colors.greenAccent,
                      Icons.receipt_long,
                      isMoney: false),
                  _kpiCard(
                      'Gasto\nTotal',
                      'S/ ${_gastoTotal.toStringAsFixed(2)}',
                      Colors.orangeAccent,
                      Icons.monetization_on,
                      isMoney: true),
                  _kpiCard(
                      'Gasto\nEste Mes',
                      'S/ ${_gastoMes.toStringAsFixed(2)}',
                      Colors.purpleAccent,
                      Icons.calendar_month,
                      isMoney: true),
                ],
              ),

              const SizedBox(height: 24),
              const Text('Mis Órdenes de Reparación',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              if (_loading)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(
                            color: Colors.blueAccent)))
              else if (_error != null)
                Center(
                    child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(_error!,
                            style: const TextStyle(color: Colors.redAccent))))
              else if (_ordenes.isEmpty)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No tienes órdenes de reparación',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 15))))
              else
                _tablaOrdenes(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── KPI card ─────────────────────────────────────────────
  Widget _kpiCard(
      String title, String value, Color color, IconData icon,
      {required bool isMoney}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A222C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Text(
            value,
            style: TextStyle(
                color: color,
                fontSize: isMoney ? 16 : 30,
                fontWeight: FontWeight.bold,
                height: 1),
            overflow: TextOverflow.ellipsis,
          ),
          Text(title,
              style:
                  const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }

  // ── Tabla de órdenes con scroll horizontal ───────────────
  Widget _tablaOrdenes() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A222C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor:
              MaterialStateProperty.all(const Color(0xFF222C38)),
          dataRowColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.blueAccent.withOpacity(0.1);
            }
            return Colors.transparent;
          }),
          headingTextStyle: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.bold),
          dataTextStyle:
              const TextStyle(color: Colors.white70, fontSize: 11),
          columnSpacing: 16,
          horizontalMargin: 12,
          dividerThickness: 0.4,
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('VEHÍCULO')),
            DataColumn(label: Text('F. INGRESO')),
            DataColumn(label: Text('F. SALIDA')),
            DataColumn(label: Text('ESTADO')),
            DataColumn(label: Text('DETALLES')),
          ],
          rows: _ordenes.map((orden) {
            final isAbierta = orden.estado == 1;
            final statusColor =
                isAbierta ? Colors.blueAccent : Colors.greenAccent;
            return DataRow(cells: [
              DataCell(Text(
                '#${orden.id}',
                style: TextStyle(
                    color: statusColor, fontWeight: FontWeight.bold),
              )),
              DataCell(
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Text(
                    orden.vehiculoCompleto,
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(Text(_fmt(orden.fechaIngreso))),
              DataCell(Text(_fmt(orden.fechaSalida))),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(5)),
                  child: Text(
                    orden.estadoText,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              DataCell(
                TextButton(
                  onPressed: () => Navigator.of(context)
                      .pushNamed('/orden-detalle', arguments: orden),
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: const Text('Ver',
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
