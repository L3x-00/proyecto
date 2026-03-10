import 'package:flutter/material.dart';
import '../models/index.dart';

class ClienteDetalleScreen extends StatelessWidget {
  const ClienteDetalleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Recibimos el objeto cliente que pasamos al hacer clic en la tarjeta
    final cliente = ModalRoute.of(context)!.settings.arguments as Cliente;

    return Scaffold(
      backgroundColor: const Color(0xFF12171D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Detalle del Cliente',
            style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cabecera del Perfil
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person,
                    color: Colors.blueAccent, size: 60),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                cliente.nombre,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      cliente.estado == 'Vigente' || cliente.estado == 'Activo'
                          ? Colors.greenAccent.withOpacity(0.1)
                          : Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cliente.estado,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: cliente.estado == 'Vigente' ||
                            cliente.estado == 'Activo'
                        ? Colors.greenAccent
                        : Colors.redAccent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),

            // 2. Información de Contacto
            const Text('INFORMACIÓN DE CONTACTO',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
            const SizedBox(height: 24),
            _buildInfoRow(Icons.badge, 'RUC / DNI', cliente.ruc),
            _buildInfoRow(Icons.phone, 'Teléfono', cliente.telefono),
            _buildInfoRow(Icons.email, 'Correo Electrónico', cliente.correo),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para cada fila de información
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
