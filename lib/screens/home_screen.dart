import 'package:flutter/material.dart';
import 'package:xtreme_performance/services/pusher_config.dart';
import '../services/notification_service.dart';
import 'dashboard_screen.dart';
import 'clientes_screen.dart';
import 'vehiculos_screen.dart';
import 'ordenes_screen.dart';
import 'configuracion_screen.dart';
import '../constants/app_theme.dart';
import '../widgets/chatbot_fab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PusherConfig _pusherConfig = PusherConfig();

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ClientesScreen(),
    const VehiculosScreen(),
    const OrdenesScreen(),
    const ConfiguracionScreen(),
  ];
  //profe

  @override
  void initState() {
    super.initState();
    _pusherConfig.initPusher(
      channelName: 'admin-notificaciones',
      eventName: 'nueva-orden',
      onEventTriggered: (event) {
        NotificationService()
            .showNuevaOrden(event.data, title: 'Nueva orden de reparación');
      },
    );
  }

  @override
  void dispose() {
    _pusherConfig.disconnect();
    super.dispose();
  }

  /// Ícono activo del BottomNav con un pequeño "pop" de escala cada vez que
  /// se selecciona la pestaña (usa `_currentIndex` en la key para forzar el
  /// reinicio de la animación al cambiar de tab).
  Widget _activeIcon(IconData icon) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('$icon-$_currentIndex'),
      tween: Tween(begin: 0.7, end: 1.0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: Padding(padding: const EdgeInsets.only(bottom: 4.0), child: Icon(icon)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: const Padding(
        padding: EdgeInsets.only(bottom: 70),
        child: ChatbotFab(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: context.appColors.shadow,
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
          backgroundColor: context.appColors.surface,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: kBrandPrimary,
          unselectedItemColor: Colors.grey.shade500,
          showUnselectedLabels: true,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.normal, fontSize: 11),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.dashboard_outlined)),
              activeIcon: _activeIcon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: const Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.people_outline)),
              activeIcon: _activeIcon(Icons.people),
              label: 'Clientes',
            ),
            BottomNavigationBarItem(
              icon: const Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.directions_car_outlined)),
              activeIcon: _activeIcon(Icons.directions_car),
              label: 'Vehículos',
            ),
            BottomNavigationBarItem(
              icon: const Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.build_circle_outlined)),
              activeIcon: _activeIcon(Icons.build),
              label: 'Órdenes',
            ),
          ],
        ),
      ),
    );
  }
}
