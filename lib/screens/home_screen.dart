import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/index.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xtreme Performance'),
        elevation: 0,
        // Eliminé el botón de cerrar sesión de aquí arriba 
        // porque ya lo tenemos formalmente en la pantalla de Configuración.
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bienvenida
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Bienvenido!',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          authProvider.usuario?.nombreCompleto ?? 'Usuario',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Menú principal
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1,
              children: [
                _MenuCard(
                  icon: Icons.people,
                  title: 'Clientes',
                  color: Colors.blue,
                  onTap: () => Navigator.pushNamed(context, '/clientes'),
                ),
                _MenuCard(
                  icon: Icons.directions_car,
                  title: 'Vehículos',
                  color: Colors.green,
                  onTap: () => Navigator.pushNamed(context, '/vehiculos'),
                ),
                _MenuCard(
                  icon: Icons.build,
                  title: 'Órdenes',
                  color: Colors.orange,
                  onTap: () => Navigator.pushNamed(context, '/ordenes'),
                ),
                _MenuCard(
                  icon: Icons.settings,
                  title: 'Configuración',
                  color: Colors.purple,
                  // AQUÍ CONECTAMOS TU NUEVA PANTALLA
                  onTap: () => Navigator.pushNamed(context, '/configuracion'), 
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}