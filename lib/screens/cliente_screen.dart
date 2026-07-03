import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/index.dart';
import '../services/api_service.dart';
import '../constants/app_theme.dart';
import '../widgets/app_header.dart';
import 'chatbot_screen.dart';

class ClienteScreen extends StatefulWidget {
  const ClienteScreen({Key? key}) : super(key: key);

  @override
  State<ClienteScreen> createState() => _ClienteScreenState();
}

String _normalizarPlaca(String placa) => placa.trim().toUpperCase();

class _ClienteScreenState extends State<ClienteScreen> {
  late Future<List<dynamic>> _misVehiculos;
  Set<String>? _misPlacas;
  bool _errorVehiculos = false;

  @override
  void initState() {
    super.initState();
    _misVehiculos = context.read<ApiService>().obtenerMisVehiculos();
    _misVehiculos.then((vehiculos) {
      if (!mounted) return;
      setState(() {
        _misPlacas = vehiculos
            .where((p) => p.isNotEmpty)
            .toSet();
      });
    }).catchError((_) {
      if (!mounted) return;
      setState(() => _errorVehiculos = true);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdenesProvider>().loadOrdenes();
    });
    _cargarOrdenes();
  }

  Future<void> _cargarOrdenes() async {
    setState(() {
    final colors = context.appColors;

    return Scaffold(

      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0072FF).withOpacity(0.5),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatbotScreen()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.smart_toy, color: Colors.white),
          label: const Text(
            'Mecánico Virtual',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5),
          ),
        ),
      ),
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
            _buildVehiculosSeccion(context),
            const SizedBox(height: 20),
            _buildOrdenesSeccion(
                context, ordenesProvider, _misPlacas, _errorVehiculos),
          ],
=======
      ),
    );
  }

  Widget _buildOrdenesSeccion(
      BuildContext context,
      OrdenesProvider ordenesProvider,
      Set<String>? misPlacas,
      bool errorVehiculos) {
    final colors = context.appColors;

    Widget contenido;
    if (errorVehiculos) {
      contenido = Center(
        child: Text(
          'No se pudieron cargar tus vehículos, así que no se pueden '
          'mostrar tus órdenes. Revisa tu conexión e intenta de nuevo.',
          style: const TextStyle(color: Colors.redAccent, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      );
    } else if (ordenesProvider.isLoading || misPlacas == null) {
      contenido = const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: CircularProgressIndicator(color: Color(0xFF00C6FF)),
        ),
      );
    } else if (ordenesProvider.error != null) {
      contenido = Center(
        child: Text(
          ordenesProvider.error!,
          style: const TextStyle(color: Colors.redAccent, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      final misOrdenes = ordenesProvider.ordenes
          .where((o) => misPlacas.contains(_normalizarPlaca(o.placas)))
          .toList();

      if (misOrdenes.isEmpty) {
        contenido = Center(
          child: Text(
            'No tienes órdenes registradas.',
            style: TextStyle(color: colors.textMuted, fontSize: 14),
          ),
        );
      } else {
        contenido = Column(
          children: misOrdenes.map((orden) {
            final isAbierta = orden.estado == 1;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.build_circle,
                      size: 20,
                      color: isAbierta
                          ? const Color(0xFFFF9800)
                          : const Color(0xFF00E676)),
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
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ingreso: ${orden.fechaIngreso}',
                          style:
                              TextStyle(color: colors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    orden.estadoText,
                    style: TextStyle(
                      color: isAbierta
                          ? const Color(0xFFFF9800)
                          : const Color(0xFF00E676),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mis Órdenes',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          contenido,
        ],
      ),
    );
  }
}