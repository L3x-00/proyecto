import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/index.dart';
import '../models/index.dart';
import '../constants/app_theme.dart';
import '../widgets/app_header.dart';

class VehiculosScreen extends StatefulWidget {
  const VehiculosScreen({Key? key}) : super(key: key);

  @override
  State<VehiculosScreen> createState() => _VehiculosScreenState();
}

class _VehiculosScreenState extends State<VehiculosScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehiculosProvider>().loadVehiculos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      appBar: AppHeader(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow,
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: colors.textPrimary),
                onChanged: (value) {
                  context.read<VehiculosProvider>().buscarVehiculo(value);
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Buscar por placa o modelo...',
                  hintStyle: TextStyle(color: colors.textPrimary.withOpacity(0.4)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF00C6FF)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close,
                              color: colors.textPrimary.withOpacity(0.5)),
                          onPressed: () {
                            _searchController.clear();
                            context.read<VehiculosProvider>().buscarVehiculo('');
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: colors.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
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
          ),
        ),
      ),
      body: Consumer<VehiculosProvider>(
        builder: (context, vehiculosProvider, _) {
          if (vehiculosProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00C6FF)),
            );
          }

          if (vehiculosProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colors.textMuted),
                  const SizedBox(height: 20),
                  Text(
                    vehiculosProvider.error ?? 'Error desconocido',
                    style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => vehiculosProvider.loadVehiculos(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: colors.border),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: Text('Reintentar', style: TextStyle(color: colors.textPrimary)),
                  ),
                ],
              ),
            );
          }

          if (vehiculosProvider.vehiculos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car_outlined, size: 80, color: colors.textMuted),
                  const SizedBox(height: 24),
                  Text(
                    'No se encontraron vehículos',
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: vehiculosProvider.vehiculos.length,
                  itemBuilder: (context, index) {
                    final vehiculo = vehiculosProvider.vehiculos[index];
                    return _VehiculoCard(vehiculo: vehiculo);
                  },
                ),
              ),
              if (!vehiculosProvider.isSearching)
                _Paginacion(provider: vehiculosProvider),
            ],
          );
        },
      ),
    );
  }
}

class _Paginacion extends StatelessWidget {
  final VehiculosProvider provider;

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
            'Página ${provider.currentPage} de ${provider.totalPages} · ${provider.total} vehículos',
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

class _VehiculoCard extends StatelessWidget {
  final Vehiculo vehiculo;

  const _VehiculoCard({required this.vehiculo});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          highlightColor: colors.textPrimary.withOpacity(0.02),
          splashColor: const Color(0xFF00C6FF).withOpacity(0.1),
          onTap: () {
            Navigator.pushNamed(context, '/vehiculo-detalle', arguments: vehiculo);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                  child: const Icon(Icons.directions_car, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.textPrimary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: colors.border),
                        ),
                        child: Text(
                          vehiculo.placas.toUpperCase(),
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${vehiculo.marca ?? "Marca"} - ${vehiculo.modelo}',
                        style: TextStyle(
                          color: colors.textPrimary.withOpacity(0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.arrow_forward_ios_rounded, color: colors.textMuted, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
