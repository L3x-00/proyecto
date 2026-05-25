import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/index.dart';
import '../constants/app_constants.dart';

class MecanicoScreen extends StatefulWidget {
  const MecanicoScreen({Key? key}) : super(key: key);

  @override
  State<MecanicoScreen> createState() => _MecanicoScreenState();
}

class _MecanicoScreenState extends State<MecanicoScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MecanicoDashboardScreen(),
    const MecanicosListScreen(),
    const ConfiguracionMecanicoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12171D),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: const Color(0xFF1A222C),
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
                  child: Icon(Icons.people_outline)),
              activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.people)),
              label: 'Equipo',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.settings_outlined)),
              activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.settings)),
              label: 'Configuración',
            ),
          ],
        ),
      ),
    );
  }
}

class MecanicoDashboardScreen extends StatefulWidget {
  const MecanicoDashboardScreen({Key? key}) : super(key: key);

  @override
  State<MecanicoDashboardScreen> createState() =>
      _MecanicoDashboardScreenState();
}

class _MecanicoDashboardScreenState extends State<MecanicoDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;

    return Scaffold(
      backgroundColor: const Color(0xFF12171D),
      appBar: AppBar(
        title: const Text('Dashboard Mecánico'),
        backgroundColor: const Color(0xFF1A222C),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo
            Text(
              'Bienvenido, ${usuario?.nombres ?? 'Mecánico'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu especialidad: ${_getEspecialidad(usuario)}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // Estado del Mecánico
            _buildEstadoCard(usuario),
            const SizedBox(height: 20),

            // Información Personal
            _buildInfoPersonalCard(usuario),
            const SizedBox(height: 20),

            // Acciones rápidas
            const Text(
              'Acciones Rápidas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildAccionesRapidas(),
            const SizedBox(height: 20),

            // Órdenes Pendientes
            _buildOrdenesSeccion(usuario),
          ],
        ),
      ),
    );
  }

  String _getEspecialidad(usuario) {
    // Aquí podrías agregar información de especialidad del mecánico
    return 'Especialista en Motores';
  }

  Widget _buildEstadoCard(usuario) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A222C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Estado Actual',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Disponible',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.greenAccent,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPersonalCard(usuario) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A222C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información Personal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Correo:', usuario?.correo ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow('Teléfono:', usuario?.telefono ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow('Nombre Completo:', usuario?.nombreCompleto ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAccionesRapidas() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.assignment),
            label: const Text('Ver Órdenes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.timer),
            label: const Text('Registrar Tiempo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purpleAccent,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrdenesSeccion(usuario) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A222C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Órdenes Asignadas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'No hay órdenes pendientes',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MecanicosListScreen extends StatelessWidget {
  const MecanicosListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12171D),
      appBar: AppBar(
        title: const Text('Equipo de Mecánicos'),
        backgroundColor: const Color(0xFF1A222C),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Equipo de Mecánicos',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class ConfiguracionMecanicoScreen extends StatelessWidget {
  const ConfiguracionMecanicoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF12171D),
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: const Color(0xFF1A222C),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
