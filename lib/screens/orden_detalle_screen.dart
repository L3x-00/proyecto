import 'package:flutter/material.dart';
import '../models/index.dart';
import '../constants/app_theme.dart';

class OrdenDetalleScreen extends StatelessWidget {
  const OrdenDetalleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orden = ModalRoute.of(context)!.settings.arguments as Orden;
    final bool isPendiente = orden.estado == 1;
    final Color statusColor = isPendiente ? const Color(0xFFFF9800) : const Color(0xFF00E676);
    final Color gradStart = isPendiente ? const Color(0xFFFFB75E) : const Color(0xFF00E676);
    final Color gradEnd = isPendiente ? const Color(0xFFED8F03) : const Color(0xFF1DB954);
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        title: Text(
          'Detalle de la Orden',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 100, bottom: 40, left: 24, right: 24),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Hero(
                    tag: 'orden-${orden.id}',
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [gradStart, gradEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: gradEnd.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.build_rounded, color: gradStart, size: 64),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'ORDEN #${orden.id}',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withOpacity(0.15),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          orden.estadoText.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FECHAS DEL SERVICIO',
                    style: TextStyle(
                      color: colors.textPrimary.withOpacity(0.5),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow(
                    context,
                    Icons.calendar_today_rounded,
                    'Fecha de Ingreso',
                    orden.fechaIngreso,
                    kBrandPrimary,
                  ),
                  _buildInfoRow(
                    context,
                    Icons.event_available_rounded,
                    'Fecha de Salida',
                    (orden.fechaSalida == null || orden.fechaSalida!.isEmpty) ? 'Pendiente' : orden.fechaSalida!,
                    const Color(0xFF8E2DE2),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'DATOS DEL VEHÍCULO',
                    style: TextStyle(
                      color: colors.textPrimary.withOpacity(0.5),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow(context, Icons.person_outline, 'Cliente', orden.cliente, const Color(0xFFFF3366)),
                  _buildInfoRow(context, Icons.directions_car_outlined, 'Vehículo', orden.vehiculoCompleto, kBrandPrimary),
                  _buildInfoRow(context, Icons.pin_outlined, 'Placas', orden.placas.toUpperCase(), const Color(0xFF1DB954)),

                  const SizedBox(height: 40),

                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [kBrandPrimary, kBrandSecondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kBrandSecondary.withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/seguimiento', arguments: orden);
                      },
                      icon: const Icon(Icons.timeline_rounded, color: Colors.white, size: 28),
                      label: const Text(
                        'VER SEGUIMIENTOS EN VIVO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, Color accentColor) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.textPrimary.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
