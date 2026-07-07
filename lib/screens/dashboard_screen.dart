import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../constants/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/skeletons.dart';
import '../widgets/animated_entrance.dart';

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
        setState(() {
          _isLoading = false;
          _error = 'Error de inicialización de API.';
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
    final colors = context.appColors;

    return Scaffold(
      appBar: AppHeader(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.background, colors.background.withOpacity(0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: _isLoading
          ? const SafeArea(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: SkeletonKpiGrid(),
              ),
            )
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resumen de Operaciones',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: staggeredItem(
                                _buildKpiCard(
                                  'Abiertas',
                                  (_kpis['ordenes_abiertas'] as num?) ?? 0,
                                  Icons.build_circle,
                                  const Color(0xFFFF3366),
                                  const Color(0xFFFF7733),
                                ),
                                0,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: staggeredItem(
                                _buildKpiCard(
                                  'Facturadas',
                                  (_kpis['ordenes_facturadas'] as num?) ?? 0,
                                  Icons.check_circle,
                                  kBrandPrimary,
                                  kBrandSecondary,
                                ),
                                1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: staggeredItem(
                                _buildKpiCard(
                                  'Totales',
                                  (_kpis['ordenes_totales'] as num?) ?? 0,
                                  Icons.auto_graph,
                                  const Color(0xFF8E2DE2),
                                  const Color(0xFF4A00E0),
                                ),
                                2,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: staggeredItem(
                                _buildKpiCard(
                                  'Ingresos por mes',
                                  (_kpis['ingresos_mes'] as num?) ?? 0,
                                  Icons.account_balance_wallet,
                                  const Color(0xFF11998E),
                                  const Color(0xFF38EF7D),
                                  isCurrency: true,
                                ),
                                3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Text(
                          'Flujo de Ingresos',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 320,
                          padding: const EdgeInsets.only(
                              top: 30, bottom: 20, left: 15, right: 25),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: colors.border),
                            boxShadow: [
                              BoxShadow(
                                color: colors.shadow,
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: _buildChart(),
                        ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(
                              begin: 0.1,
                              end: 0,
                              delay: 400.ms,
                              duration: 500.ms,
                              curve: Curves.easeOut,
                            ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildKpiCard(String title, num value, IconData icon,
      Color gradStart, Color gradEnd,
      {bool isCurrency = false}) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(20),
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
            child: Icon(icon, color: gradStart, size: 28),
          ),
          const SizedBox(height: 20),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, _) {
              final text = isCurrency
                  ? 'S/ ${animatedValue.toStringAsFixed(2)}'
                  : animatedValue.round().toString();
              return Text(
                text,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: colors.textPrimary.withOpacity(0.5),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final labels = _ingresos['labels'] as List<dynamic>? ?? [];
    final data = _ingresos['data'] as List<dynamic>? ?? [];

    if (labels.isEmpty || data.isEmpty) {
      return Center(
        child: Text(
          'No hay datos disponibles',
          style: TextStyle(color: context.appColors.textMuted),
        ),
      );
    }

    final axisTextColor = context.appColors.textPrimary.withOpacity(0.5);

    return BarChart(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.isNotEmpty
            ? (data.map((e) => e as num).reduce((a, b) => a > b ? a : b) * 1.2)
            : 100,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            // 🛠️ CORRECCIÓN: Ahora pide una función en lugar de un color fijo
            getTooltipColor: (group) => context.appColors.surface,
            // Eliminamos tooltipRoundedRadius porque la nueva versión ya lo redondea sola
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                'S/ ${rod.toY.toStringAsFixed(2)}',
                TextStyle(
                    color: context.appColors.textPrimary, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      labels[index].toString(),
                      style: TextStyle(
                          color: axisTextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (value, meta) {
                return Text(
                  'S/ ${value.toInt()}',
                  style: TextStyle(
                      color: axisTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: data.isNotEmpty
              ? (data.map((e) => e as num).reduce((a, b) => a > b ? a : b) / 4)
              : 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: context.appColors.border,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          data.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: (data[index] as num).toDouble(),
                width: 18,
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(
                  colors: [kBrandPrimary, kBrandSecondary],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: data.isNotEmpty
                      ? (data
                              .map((e) => e as num)
                              .reduce((a, b) => a > b ? a : b) *
                          1.2)
                      : 100,
                  color: context.appColors.textPrimary.withOpacity(0.02),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
