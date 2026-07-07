import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/index.dart';
import '../models/index.dart';
import '../constants/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/skeletons.dart';
import '../widgets/animated_entrance.dart';

class OrdenesScreen extends StatefulWidget {
  const OrdenesScreen({Key? key}) : super(key: key);

  @override
  State<OrdenesScreen> createState() => _OrdenesScreenState();
}

class _OrdenesScreenState extends State<OrdenesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdenesProvider>().loadOrdenes();
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
                  context.read<OrdenesProvider>().buscarOrden(value);
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Buscar por ID, estado o cliente...',
                  hintStyle: TextStyle(color: colors.textPrimary.withOpacity(0.4)),
                  prefixIcon:
                      const Icon(Icons.search, color: kBrandPrimary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close,
                              color: colors.textPrimary.withOpacity(0.5)),
                          onPressed: () {
                            _searchController.clear();
                            context.read<OrdenesProvider>().buscarOrden('');
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
                    borderSide:
                        const BorderSide(color: kBrandPrimary, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<OrdenesProvider>(
        builder: (context, ordenesProvider, _) {
          if (ordenesProvider.isLoading) {
            return const SkeletonList();
          }

          if (ordenesProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: colors.textMuted),
                  const SizedBox(height: 20),
                  Text(
                    ordenesProvider.error ?? 'Error desconocido',
                    style:
                        const TextStyle(color: Colors.redAccent, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => ordenesProvider.loadOrdenes(),
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

          if (ordenesProvider.ordenes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.build_circle_outlined,
                      size: 80, color: colors.textMuted),
                  const SizedBox(height: 24),
                  Text(
                    'No se encontraron órdenes',
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
                  itemCount: ordenesProvider.ordenes.length,
                  itemBuilder: (context, index) {
                    final orden = ordenesProvider.ordenes[index];
                    return staggeredItem(_OrdenCard(orden: orden), index);
                  },
                ),
              ),
              if (!ordenesProvider.isSearching)
                _Paginacion(provider: ordenesProvider),
            ],
          );
        },
      ),
    );
  }
}

class _Paginacion extends StatelessWidget {
  final OrdenesProvider provider;

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
            'Página ${provider.currentPage} de ${provider.totalPages} · ${provider.total} órdenes',
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

class _OrdenCard extends StatelessWidget {
  final Orden orden;

  const _OrdenCard({required this.orden});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bool isPendiente = orden.estado == 1;
    final Color statusColor =
        isPendiente ? const Color(0xFFFF9800) : const Color(0xFF00E676);
    final Color gradStart =
        isPendiente ? const Color(0xFFFFB75E) : const Color(0xFF00E676);
    final Color gradEnd =
        isPendiente ? const Color(0xFFED8F03) : const Color(0xFF1DB954);

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
          splashColor: gradStart.withOpacity(0.1),
          onTap: () {
            Navigator.pushNamed(context, '/orden-detalle', arguments: orden);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Hero(
                  tag: 'orden-${orden.id}',
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [gradStart, gradEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: gradEnd.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.build_rounded,
                        color: Colors.white, size: 24),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ORDEN #${orden.id}',
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: statusColor.withOpacity(0.3),
                                  width: 1.5),
                            ),
                            child: Text(
                              orden.estadoText.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.person_outline,
                              color: colors.textPrimary.withOpacity(0.4), size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              orden.cliente,
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.directions_car_outlined,
                              color: colors.textPrimary.withOpacity(0.4), size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${orden.vehiculoCompleto} (${orden.placas})',
                              style: TextStyle(
                                color: colors.textPrimary.withOpacity(0.5),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: colors.textMuted, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
