import 'package:flutter/material.dart';
import '../models/index.dart';

class VehiculoDetalleScreen extends StatelessWidget {
  const VehiculoDetalleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Recibimos los datos del vehículo
    final vehiculo = ModalRoute.of(context)!.settings.arguments as Vehiculo;

    return Scaffold(
      backgroundColor: const Color(0xFF12171D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Detalle del Vehículo',
            style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cabecera (Placa)
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.directions_car,
                    color: Colors.blueAccent, size: 60),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                vehiculo.placas.toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 48),

            // 2. Información Técnica
            const Text('INFORMACIÓN TÉCNICA',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
            const SizedBox(height: 24),
            _buildInfoRow(Icons.branding_watermark, 'Marca',
                vehiculo.marca ?? 'No especificada'),
            _buildInfoRow(Icons.model_training, 'Modelo', vehiculo.modelo),

            // Si en tu modelo de vehículo tienes más datos (año, color, cliente dueño),
            // puedes agregar más llamadas a _buildInfoRow aquí.
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para las filas de datos
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2630),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blueAccent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
