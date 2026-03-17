import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/index.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> _kpis = {};
  Map<String, dynamic> _ingresos = {};
  bool _isLoading = true;
  String? _error;

  late ApiService _apiService;
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      try {
        _apiService = Provider.of<ApiService>(context, listen: false);
        _loadDashboardData();
      } catch (err) {
        // En caso de que Provider no exista en el árbol (hot reload / context incorrecto)
        setState(() {
          _isLoading = false;
          _error = 'No se encontró el proveedor de ApiService. Haz un hot-restart o revisa el árbol de widgets.';
        });
      }
      _didInit = true;
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      final kpisResult = await _apiService.getKpis();
      final ingresosResult = await _apiService.getIngresosMensuales();

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (kpisResult['success']) {
            _kpis = kpisResult['kpis'];
          } else {
            _error = kpisResult['error']?.toString();
          }
          if (ingresosResult['success']) {
            _ingresos = ingresosResult['ingresos'];
          } else {
            _error ??= ingresosResult['error']?.toString();
          }
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12171D),
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E2329),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error cargando datos:\n\n${_error ?? 'Desconocido'}',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'KPIs del Mes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildKpiCard(
                          'Órdenes Abiertas',
                          _kpis['ordenes_abiertas']?.toString() ?? '0',
                          Icons.pending_actions,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildKpiCard(
                          'Órdenes Facturadas',
                          _kpis['ordenes_facturadas']?.toString() ?? '0',
                          Icons.check_circle,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildKpiCard(
                          'Órdenes Totales',
                          _kpis['ordenes_totales']?.toString() ?? '0',
                          Icons.list,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildKpiCard(
                          'Ingresos del Mes',
                          'S/ ${_kpis['ingresos_mes']?.toStringAsFixed(2) ?? '0.00'}',
                          Icons.attach_money,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Ingresos Mensuales',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2329),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _buildChart(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2329),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final labels = _ingresos['labels'] as List<dynamic>? ?? [];
    final data = _ingresos['data'] as List<dynamic>? ?? [];

    if (labels.isEmpty || data.isEmpty) {
      return const Center(
        child: Text(
          'No hay datos disponibles',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.isNotEmpty ? (data.map((e) => e as num).reduce((a, b) => a > b ? a : b) * 1.2) : 100,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                'S/ ${rod.toY.toStringAsFixed(2)}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < labels.length) {
                  return Text(
                    labels[index].toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  'S/ ${value.toInt()}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          data.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: (data[index] as num).toDouble(),
                color: Colors.blue,
                width: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}