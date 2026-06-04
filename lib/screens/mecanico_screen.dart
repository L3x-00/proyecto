import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/index.dart';
import '../services/api_service.dart';
import '../models/index.dart';

class MecanicoScreen extends StatefulWidget {
  const MecanicoScreen({Key? key}) : super(key: key);

  @override
  State<MecanicoScreen> createState() => _MecanicoScreenState();
}

class _MecanicoScreenState extends State<MecanicoScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12171D),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _MecanicoDashboardTab(),
          _MecanicoPerfilTab(),
          _MecanicoConfigTab(),
        ],
      ),
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
          onTap: (index) => setState(() => _currentIndex = index),
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
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.assignment_outlined)),
              activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.assignment)),
              label: 'Mis Órdenes',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.person_outline)),
              activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.person)),
              label: 'Mi Perfil',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.settings_outlined)),
              activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.settings)),
              label: 'Configuración',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TAB 1: Mis Órdenes
// ─────────────────────────────────────────────────────────────
class _MecanicoDashboardTab extends StatefulWidget {
  const _MecanicoDashboardTab({Key? key}) : super(key: key);

  @override
  State<_MecanicoDashboardTab> createState() => _MecanicoDashboardTabState();
}

class _MecanicoDashboardTabState extends State<_MecanicoDashboardTab> {
  List<Orden> _ordenes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarOrdenes();
  }

  Future<void> _cargarOrdenes() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final apiService = ApiService();
    await apiService.init();
    final usuario = context.read<AuthProvider>().usuario;
    final result = await apiService.getOrdenesMecanico(usuario!.id);
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() {
        _ordenes = List<Orden>.from(result['ordenes'] as List);
        _loading = false;
      });
    } else {
      setState(() {
        _error = result['error']?.toString();
        _loading = false;
      });
    }
  }

  int get _abiertas => _ordenes.where((o) => o.estado == 1).length;
  int get _facturadas => _ordenes.where((o) => o.estado == 2).length;
  int get _asignadas => _ordenes.length;
  int get _esteMes {
    final now = DateTime.now();
    return _ordenes.where((o) {
      try {
        final f = DateTime.parse(o.fechaIngreso);
        return f.year == now.year && f.month == now.month;
      } catch (_) {
        return false;
      }
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;
    return Scaffold(
      backgroundColor: const Color(0xFF12171D),
      appBar: AppBar(
        title: const Text('Mis Órdenes'),
        backgroundColor: const Color(0xFF1A222C),
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _cargarOrdenes,
        color: Colors.blueAccent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenido, ${usuario?.nombres ?? 'Mecánico'}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('Resumen de tus órdenes asignadas',
                  style: TextStyle(color: Colors.white54, fontSize: 13)),
              const SizedBox(height: 20),

              // KPI grid 2×2
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.45,
                children: [
                  _kpiCard('Órdenes\nAbiertas', '$_abiertas',
                      Colors.blueAccent, Icons.folder_open),
                  _kpiCard('Órdenes\nFacturadas', '$_facturadas',
                      Colors.greenAccent, Icons.receipt_long),
                  _kpiCard('Órdenes\nAsignadas', '$_asignadas',
                      Colors.orangeAccent, Icons.assignment_ind),
                  _kpiCard('Órdenes\nEste Mes', '$_esteMes',
                      Colors.purpleAccent, Icons.calendar_month),
                ],
              ),

              const SizedBox(height: 24),
              const Text('Órdenes de Reparación',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              if (_loading)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(
                            color: Colors.blueAccent)))
              else if (_error != null)
                Center(
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.redAccent)))
              else if (_ordenes.isEmpty)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No tienes órdenes asignadas',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 15))))
              else
                ..._ordenes.map(_ordenCard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kpiCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A222C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  height: 1)),
          Text(title,
              style:
                  const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _ordenCard(Orden orden) {
    final isAbierta = orden.estado == 1;
    final statusColor =
        isAbierta ? Colors.blueAccent : Colors.greenAccent;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: const Color(0xFF1A222C),
          borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
              color: statusColor.withOpacity(0.13),
              borderRadius: BorderRadius.circular(8)),
          child: Center(
              child: Text('#${orden.id}',
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold))),
        ),
        title: Text('${orden.marca} ${orden.modelo}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(orden.placas,
                style:
                    const TextStyle(color: Colors.white60, fontSize: 12)),
            Text(orden.fechaIngreso,
                style:
                    const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
        trailing: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: statusColor.withOpacity(0.13),
              borderRadius: BorderRadius.circular(6)),
          child: Text(orden.estadoText,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ),
        onTap: () =>
            Navigator.of(context).pushNamed('/orden-detalle', arguments: orden),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TAB 2: Mi Perfil
// ─────────────────────────────────────────────────────────────
class _MecanicoPerfilTab extends StatefulWidget {
  const _MecanicoPerfilTab({Key? key}) : super(key: key);

  @override
  State<_MecanicoPerfilTab> createState() => _MecanicoPerfilTabState();
}

class _MecanicoPerfilTabState extends State<_MecanicoPerfilTab> {
  final _formKey = GlobalKey<FormState>();
  final _nombresCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _claveCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();
  bool _cambiarClave = false;
  bool _obscureClave = true;
  bool _obscureConfirmar = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final u = context.read<AuthProvider>().usuario;
    _nombresCtrl.text = u?.nombres ?? '';
    _apellidosCtrl.text = u?.apellidos ?? '';
  }

  @override
  void dispose() {
    _nombresCtrl.dispose();
    _apellidosCtrl.dispose();
    _claveCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final apiService = ApiService();
    await apiService.init();
    final usuario = context.read<AuthProvider>().usuario;

    final result = await apiService.actualizarPerfilUsuario(
      usuario!.id,
      _nombresCtrl.text.trim(),
      _apellidosCtrl.text.trim(),
    );

    if (!mounted) return;

    if (result['success'] == true && _cambiarClave && _claveCtrl.text.isNotEmpty) {
      final claveResult = await apiService.cambiarClave(usuario.id, _claveCtrl.text.trim());
      if (!mounted) return;
      if (claveResult['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Perfil actualizado, pero error al cambiar contraseña: ${claveResult['error']}'),
          backgroundColor: Colors.orange,
        ));
        setState(() => _loading = false);
        return;
      }
    }

    setState(() => _loading = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result['success'] == true
          ? 'Perfil actualizado correctamente'
          : (result['error'] ?? 'Error al actualizar')),
      backgroundColor:
          result['success'] == true ? Colors.green : Colors.redAccent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;
    final inicial = (usuario?.nombres.isNotEmpty == true)
        ? usuario!.nombres[0].toUpperCase()
        : 'M';

    return Scaffold(
      backgroundColor: const Color(0xFF12171D),
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color(0xFF1A222C),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.blueAccent.withOpacity(0.18),
                  child: Text(inicial,
                      style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 38,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                  child: Text(usuario?.correo ?? '',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 13))),
              const SizedBox(height: 28),

              _campo('Nombres', _nombresCtrl,
                  validator: (v) =>
                      v!.trim().isEmpty ? 'Campo requerido' : null),
              const SizedBox(height: 14),
              _campo('Apellidos', _apellidosCtrl,
                  validator: (v) =>
                      v!.trim().isEmpty ? 'Campo requerido' : null),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Cambiar contraseña',
                      style:
                          TextStyle(color: Colors.white, fontSize: 14)),
                  Switch(
                    value: _cambiarClave,
                    activeColor: Colors.blueAccent,
                    onChanged: (v) => setState(() {
                      _cambiarClave = v;
                      _claveCtrl.clear();
                      _confirmarCtrl.clear();
                    }),
                  ),
                ],
              ),

              if (_cambiarClave) ...[
                const SizedBox(height: 14),
                _campo(
                  'Nueva contraseña',
                  _claveCtrl,
                  obscure: _obscureClave,
                  suffix: IconButton(
                    icon: Icon(
                        _obscureClave
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white54),
                    onPressed: () =>
                        setState(() => _obscureClave = !_obscureClave),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingrese la nueva contraseña';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _campo(
                  'Confirmar contraseña',
                  _confirmarCtrl,
                  obscure: _obscureConfirmar,
                  suffix: IconButton(
                    icon: Icon(
                        _obscureConfirmar
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white54),
                    onPressed: () => setState(
                        () => _obscureConfirmar = !_obscureConfirmar),
                  ),
                  validator: (v) => v != _claveCtrl.text
                      ? 'Las contraseñas no coinciden'
                      : null,
                ),
              ],

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Guardar cambios',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campo(
    String label,
    TextEditingController ctrl, {
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFF1A222C),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Colors.blueAccent, width: 1.5)),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TAB 3: Configuración / Cerrar Sesión
// ─────────────────────────────────────────────────────────────
class _MecanicoConfigTab extends StatelessWidget {
  const _MecanicoConfigTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12171D),
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: const Color(0xFF1A222C),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
