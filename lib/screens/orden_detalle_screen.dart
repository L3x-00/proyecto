import 'package:flutter/material.dart';
import '../models/index.dart';

class OrdenDetalleScreen extends StatelessWidget {
  const OrdenDetalleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Recibimos la orden completa
    final orden = ModalRoute.of(context)!.settings.arguments as Orden;

    return Scaffold(
      backgroundColor: const Color(0xFF12171D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Detalle de la Orden',
            style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cabecera (ID y Estado)
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.build,
                    color: Colors.orangeAccent, size: 60),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Orden #${orden.id}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: orden.estado == 1
                      ? Colors.orangeAccent.withOpacity(0.1)
                      : Colors.greenAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  orden.estadoText.toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: orden.estado == 1
                        ? Colors.orangeAccent
                        : Colors.greenAccent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 2. Tiempos y Fechas
            const Text('FECHAS',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
            const SizedBox(height: 16),
            _buildInfoRow(
                Icons.calendar_today, 'Fecha de Ingreso', orden.fechaIngreso),
            _buildInfoRow(
                Icons.event_available,
                'Fecha de Salida',
                orden.fechaSalida == null || orden.fechaSalida!.isEmpty
                    ? 'Pendiente'
                    : orden.fechaSalida!),

            const Divider(color: Colors.white12, height: 40),

            // 3. Cliente y Vehículo
            const Text('DATOS DEL SERVICIO',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.person, 'Cliente', orden.cliente),
            _buildInfoRow(
                Icons.directions_car, 'Vehículo', orden.vehiculoCompleto),
            _buildInfoRow(Icons.pin, 'Placas', orden.placas.toUpperCase()),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2630),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blueAccent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(color: Colors.white, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
