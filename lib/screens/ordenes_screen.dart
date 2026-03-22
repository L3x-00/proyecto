import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/index.dart';
import '../models/index.dart';

class OrdenesScreen extends StatefulWidget {
  const OrdenesScreen({Key? key}) : super(key: key);

  @override
  State<OrdenesScreen> createState() => _OrdenesScreenState();
}

class _OrdenesScreenState extends State<OrdenesScreen> {
  // 1. Agregamos el controlador de Scroll
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdenesProvider>().loadOrdenes();
    });

    // 2. Le ponemos un "oído" al controlador para saber cuándo hacemos scroll
    _scrollController.addListener(() {
      // Si el usuario llega al 90% del fondo de la lista...
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.9) {
        // ... llamamos a la función de cargar más páginas de tu Provider
        final provider = context.read<OrdenesProvider>();
        // Verificamos que no esté ya cargando y que haya más páginas disponibles
        if (!provider.isLoadingMore && provider.hasMorePages) {
          provider.loadMoreOrdenes();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Limpiamos la memoria al cerrar la pantalla
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D17),
      appBar: AppBar(
        // ... (Tu código del AppBar se queda EXACTAMENTE IGUAL) ...
        backgroundColor: const Color(0xFF0B0D17),
        title: const Text(
          'Órdenes de Servicio',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            fontSize: 22,
          ),
        ),
        elevation: 0,
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  context.read<OrdenesProvider>().buscarOrden(value);
                },
                decoration: InputDecoration(
                  hintText: 'Buscar por ID, estado o cliente...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF00C6FF)),
                  filled: true,
                  fillColor: const Color(0xFF15192B),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.05)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.05)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        const BorderSide(color: Color(0xFF00C6FF), width: 1.5),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<OrdenesProvider>(
        builder: (context, ordenesProvider, _) {
          if (ordenesProvider.isLoading && ordenesProvider.ordenes.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00C6FF)),
            );
          }

          if (ordenesProvider.error != null &&
              ordenesProvider.ordenes.isEmpty) {
            // ... (Tu código de error se queda EXACTAMENTE IGUAL) ...
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: Colors.white.withOpacity(0.2)),
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
                      backgroundColor: const Color(0xFF15192B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                    ),
                    child: const Text('Reintentar',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          if (ordenesProvider.ordenes.isEmpty) {
            // ... (Tu código de lista vacía se queda EXACTAMENTE IGUAL) ...
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.build_circle_outlined,
                      size: 80, color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 24),
                  const Text(
                    'No se encontraron órdenes',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            );
          }

          // 3. Modificamos el ListView para inyectarle el controlador y el loading final
          return ListView.builder(
            controller: _scrollController, // ¡AQUÍ ESTÁ LA MAGIA!
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            // Le sumamos 1 al conteo si está cargando para mostrar el spinner al final
            itemCount: ordenesProvider.ordenes.length +
                (ordenesProvider.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Si llegamos al último elemento y está cargando, mostramos el spinner
              if (index == ordenesProvider.ordenes.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF00C6FF)),
                  ),
                );
              }

              final orden = ordenesProvider.ordenes[index];
              return _OrdenCard(orden: orden);
            },
          );
        },
      ),
    );
  }
}

class _OrdenCard extends StatelessWidget {
  final Orden orden;

  const _OrdenCard({required this.orden});

  @override
  Widget build(BuildContext context) {
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
        color: const Color(0xFF15192B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          highlightColor: Colors.white.withOpacity(0.02),
          splashColor: gradStart.withOpacity(0.1),
          onTap: () {
            Navigator.pushNamed(context, '/orden-detalle', arguments: orden);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
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
                            style: const TextStyle(
                              color: Colors.white,
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
                              color: Colors.white.withOpacity(0.4), size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              orden.cliente,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
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
                              color: Colors.white.withOpacity(0.4), size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${orden.vehiculoCompleto} (${orden.placas})',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
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
                    color: Colors.white.withOpacity(0.2), size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
