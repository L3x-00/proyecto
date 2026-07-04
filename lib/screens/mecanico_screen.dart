import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/index.dart';
import '../models/index.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../services/pusher_config.dart';
import '../services/notification_service.dart';
import '../widgets/app_header.dart';
import 'ordenes_screen.dart';
import '../widgets/chatbot_fab.dart';

class MecanicoScreen extends StatefulWidget {
  const MecanicoScreen({Key? key}) : super(key: key);

  @override
  State<MecanicoScreen> createState() => _MecanicoScreenState();
}

class _MecanicoScreenState extends State<MecanicoScreen> {
  int _currentIndex = 0;
  final PusherConfig _pusherConfig = PusherConfig();

  @override
  void initState() {
    super.initState();
    final usuario = context.read<AuthProvider>().usuario;
    if (usuario != null) {
      _pusherConfig.initPusher(
        channelName: 'mecanico-${usuario.id}',
        eventName: 'nueva-orden',
        onEventTriggered: (event) {
          NotificationService()
              .showNuevaOrden(event.data, title: 'Nueva orden asignada');
        },
      );
    }
  }

  @override
  void dispose() {
    _pusherConfig.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const MecanicoDashboardScreen(),
      const OrdenesScreen(),
      const MecanicosListScreen(),
      const ConfiguracionMecanicoScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      floatingActionButton: const ChatbotFab(),
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
                  child: Icon(Icons.build_circle_outlined)),
              activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.build_circle)),
              label: 'Órdenes',
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdenesProvider>().loadOrdenes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;
    final ordenesProvider = context.watch<OrdenesProvider>();
    final colors = context.appColors;

    return Scaffold(
      appBar: const AppHeader(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo
            Text(
              'Bienvenido, ${usuario?.nombres ?? 'Mecánico'}',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu especialidad: ${_getEspecialidad(usuario)}',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // Estado del Mecánico
            _buildEstadoCard(context, usuario),
            const SizedBox(height: 20),

            // Información Personal
            _buildInfoPersonalCard(context, usuario),
            const SizedBox(height: 20),

            // Órdenes Pendientes
            _buildOrdenesSeccion(context, ordenesProvider),
          ],
        ),
      ),
    );
  }

  String _getEspecialidad(usuario) {
    // Aquí podrías agregar información de especialidad del mecánico
    return 'Especialista en Motores';
  }

  Widget _buildEstadoCard(BuildContext context, usuario) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estado Actual',
                style: TextStyle(
                  color: colors.textSecondary,
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

  Widget _buildInfoPersonalCard(BuildContext context, usuario) {
    final colors = context.appColors;
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
            'Información Personal',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(context, 'Correo:', usuario?.correo ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow(context, 'Teléfono:', usuario?.telefono ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow(
              context, 'Nombre Completo:', usuario?.nombreCompleto ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final colors = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildOrdenesSeccion(
      BuildContext context, OrdenesProvider ordenesProvider) {
    final colors = context.appColors;

    Widget contenido;
    if (ordenesProvider.isLoading) {
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
    } else if (ordenesProvider.ordenes.isEmpty) {
      contenido = Center(
        child: Text(
          'No hay órdenes asignadas',
          style: TextStyle(color: colors.textMuted, fontSize: 14),
        ),
      );
    } else {
      contenido = Column(
        children: ordenesProvider.ordenes.take(5).map((orden) {
          final isAbierta = orden.estado == 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, '/orden-detalle',
                  arguments: orden),
              child: Row(
                children: [
                  Icon(Icons.build_circle,
                      size: 18,
                      color: isAbierta
                          ? const Color(0xFFFF9800)
                          : const Color(0xFF00E676)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Orden #${orden.id} · ${orden.vehiculoCompleto}',
                      style: TextStyle(color: colors.textPrimary, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
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
            ),
          );
        }).toList(),
      );
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Órdenes Asignadas',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!ordenesProvider.isLoading && ordenesProvider.error == null)
                Text(
                  '${ordenesProvider.total} total',
                  style: TextStyle(color: colors.textMuted, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 16),
          contenido,
        ],
      ),
    );
  }
}

class MecanicosListScreen extends StatefulWidget {
  const MecanicosListScreen({Key? key}) : super(key: key);

  @override
  State<MecanicosListScreen> createState() => _MecanicosListScreenState();
}

class _MecanicosListScreenState extends State<MecanicosListScreen> {
  int _estadoSeleccionado =
      0; // 0: Todos, 1: Disponible, 2: Ocupado, 3: Vacaciones
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MecanicosProvider>().loadMecanicos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _seleccionarEstado(int estado) {
    setState(() => _estadoSeleccionado = estado);
    context.read<MecanicosProvider>().filtrarPorEstado(estado);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      appBar: const AppHeader(title: 'Equipo de Mecánicos'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: colors.textPrimary),
              onChanged: (value) {
                context.read<MecanicosProvider>().buscarMecanico(value);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, especialidad o teléfono...',
                hintStyle: TextStyle(color: colors.textPrimary.withOpacity(0.4)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00C6FF)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close,
                            color: colors.textPrimary.withOpacity(0.5)),
                        onPressed: () {
                          _searchController.clear();
                          context.read<MecanicosProvider>().buscarMecanico('');
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: colors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: colors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFF00C6FF), width: 1.5),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _EstadoChip(
                    label: 'Todos',
                    color: colors.textSecondary,
                    selected: _estadoSeleccionado == 0,
                    onTap: () => _seleccionarEstado(0),
                  ),
                  const SizedBox(width: 10),
                  _EstadoChip(
                    label: 'Disponible',
                    color: const Color(0xFF00E676),
                    selected: _estadoSeleccionado == 1,
                    onTap: () => _seleccionarEstado(1),
                  ),
                  const SizedBox(width: 10),
                  _EstadoChip(
                    label: 'Ocupado',
                    color: const Color(0xFFFF9800),
                    selected: _estadoSeleccionado == 2,
                    onTap: () => _seleccionarEstado(2),
                  ),
                  const SizedBox(width: 10),
                  _EstadoChip(
                    label: 'Vacaciones',
                    color: const Color(0xFF00C6FF),
                    selected: _estadoSeleccionado == 3,
                    onTap: () => _seleccionarEstado(3),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer<MecanicosProvider>(
              builder: (context, mecanicosProvider, _) {
                if (mecanicosProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00C6FF)),
                  );
                }

                if (mecanicosProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64, color: colors.textMuted),
                        const SizedBox(height: 20),
                        Text(
                          mecanicosProvider.error ?? 'Error desconocido',
                          style: const TextStyle(
                              color: Colors.redAccent, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => mecanicosProvider.loadMecanicos(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: colors.border),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                          ),
                          child: Text('Reintentar',
                              style: TextStyle(color: colors.textPrimary)),
                        ),
                      ],
                    ),
                  );
                }

                if (mecanicosProvider.mecanicos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline,
                            size: 80, color: colors.textMuted),
                        const SizedBox(height: 24),
                        Text(
                          'No se encontraron mecánicos',
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                        itemCount: mecanicosProvider.mecanicos.length,
                        itemBuilder: (context, index) {
                          final mecanico = mecanicosProvider.mecanicos[index];
                          return _MecanicoCard(mecanico: mecanico);
                        },
                      ),
                    ),
                    if (!mecanicosProvider.isFiltering)
                      _Paginacion(provider: mecanicosProvider),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Paginacion extends StatelessWidget {
  final MecanicosProvider provider;

  const _Paginacion({required this.provider});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: provider.hasPreviousPage && !provider.isLoading
                ? () => provider.paginaAnterior()
                : null,
            icon: Icon(
              Icons.chevron_left,
              color: provider.hasPreviousPage
                  ? colors.textPrimary
                  : colors.textMuted,
            ),
          ),
          Text(
            'Página ${provider.currentPage} de ${provider.totalPages} · ${provider.total} mecánicos',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: provider.hasNextPage && !provider.isLoading
                ? () => provider.paginaSiguiente()
                : null,
            icon: Icon(
              Icons.chevron_right,
              color: provider.hasNextPage
                  ? colors.textPrimary
                  : colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _EstadoChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _EstadoChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? colors.textPrimary : colors.textSecondary,
                fontSize: 13,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MecanicoCard extends StatelessWidget {
  final Mecanico mecanico;

  const _MecanicoCard({required this.mecanico});

  Color _colorEstado() {
    if (mecanico.estaDisponible) return const Color(0xFF00E676);
    if (mecanico.estaOcupado) return const Color(0xFFFF9800);
    return const Color(0xFF00C6FF);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final statusColor = _colorEstado();

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
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0072FF).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child:
                const Icon(Icons.build_circle, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mecanico.nombreCompleto,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  mecanico.nombreEspecialidad,
                  style: TextStyle(
                    color: colors.textPrimary.withOpacity(0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                  ),
                ),
                if (mecanico.telefono.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 13, color: colors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        mecanico.telefono,
                        style: TextStyle(color: colors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                mecanico.nombreEstado,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ConfiguracionMecanicoScreen extends StatelessWidget {
  const ConfiguracionMecanicoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final colors = context.appColors;

    return Scaffold(
      appBar: const AppHeader(title: 'Configuración'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: colors.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: SwitchListTile(
                secondary: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: colors.textPrimary,
                ),
                title: Text('Tema oscuro',
                    style: TextStyle(color: colors.textPrimary)),
                subtitle: Text(
                  themeProvider.isDarkMode ? 'Activado' : 'Desactivado',
                  style: TextStyle(color: colors.textSecondary),
                ),
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
            ),
            const SizedBox(height: 16),
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
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
