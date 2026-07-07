import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_theme.dart';

/// Skeletons de carga (efecto shimmer) usados en lugar de un
/// `CircularProgressIndicator` plano mientras se espera la respuesta del
/// backend. Todos respetan el tema activo: la base es `colors.surface` y el
/// brillo se deriva mezclando `colors.textPrimary` a baja opacidad, por lo
/// que se ve bien tanto en modo claro como oscuro sin colores hardcodeados.

/// Rectángulo/píldora sólido usado como "hueso" base de un skeleton.
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Envuelve [child] con el efecto de brillo desplazándose, coherente con el tema.
Widget _shimmer(BuildContext context, Widget child) {
  final colors = context.appColors;
  final highlight = Color.alphaBlend(
    colors.textPrimary.withOpacity(0.08),
    colors.surface,
  );
  return Shimmer.fromColors(
    baseColor: colors.surface,
    highlightColor: highlight,
    period: const Duration(milliseconds: 1400),
    child: child,
  );
}

/// Imita la forma de una card de listado (ícono/avatar circular + 2 líneas de texto).
class SkeletonListCard extends StatelessWidget {
  const SkeletonListCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: _shimmer(
        context,
        Row(
          children: [
            const SkeletonBox(width: 48, height: 48, radius: 24),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 160, height: 14),
                  SizedBox(height: 10),
                  SkeletonBox(width: 100, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lista de [SkeletonListCard] para reemplazar el spinner de carga de las
/// pantallas de listado (clientes, vehículos, órdenes, etc.).
class SkeletonList extends StatelessWidget {
  final int count;

  const SkeletonList({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (context, index) => const SkeletonListCard(),
    );
  }
}

/// Imita el grid 2x2 de KPI cards + el bloque del gráfico del dashboard.
class SkeletonKpiGrid extends StatelessWidget {
  const SkeletonKpiGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    Widget kpiCard() => Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.border),
            ),
            child: _shimmer(
              context,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 48, height: 48, radius: 24),
                  SizedBox(height: 20),
                  SkeletonBox(width: 70, height: 22),
                  SizedBox(height: 8),
                  SkeletonBox(width: 90, height: 12),
                ],
              ),
            ),
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 180, height: 16),
          const SizedBox(height: 20),
          Row(children: [kpiCard(), const SizedBox(width: 16), kpiCard()]),
          const SizedBox(height: 16),
          Row(children: [kpiCard(), const SizedBox(width: 16), kpiCard()]),
          const SizedBox(height: 40),
          const SkeletonBox(width: 150, height: 16),
          const SizedBox(height: 20),
          Container(
            height: 320,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.border),
            ),
            child: _shimmer(context, const SizedBox.expand()),
          ),
        ],
      ),
    );
  }
}
