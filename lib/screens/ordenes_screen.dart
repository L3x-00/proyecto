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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdenesProvider>().loadOrdenes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12171D), // Fondo Dark Premium
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Órdenes de Servicio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                context.read<OrdenesProvider>().buscarOrden(value);
              },
              decoration: InputDecoration(
                hintText: 'Buscar por ID, estado o cliente...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: const Color(0xFF1E2630),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: Colors.blueAccent, width: 1),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<OrdenesProvider>(
        builder: (context, ordenesProvider, _) {
          if (ordenesProvider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent));
          }

          if (ordenesProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(ordenesProvider.error ?? 'Error desconocido',
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ordenesProvider.loadOrdenes(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent),
                    child: const Text('Reintentar',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          if (ordenesProvider.ordenes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.build_circle_outlined,
                      size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No se encontraron órdenes',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: ordenesProvider.ordenes.length,
            itemBuilder: (context, index) {
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2630),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navegamos al detalle enviando el objeto orden completo
            Navigator.pushNamed(context, '/orden-detalle', arguments: orden);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ícono de la orden
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.build,
                      color: Colors.orangeAccent, size: 24),
                ),
                const SizedBox(width: 16),

                // Información principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Orden #${orden.id}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Etiqueta de estado
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: orden.estado == 1
                                  ? Colors.orangeAccent.withOpacity(0.1)
                                  : Colors.greenAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              orden.estadoText,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: orden.estado == 1
                                    ? Colors.orangeAccent
                                    : Colors.greenAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        orden.cliente,
                        style: TextStyle(
                            color: Colors.grey.shade300, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${orden.vehiculoCompleto} (${orden.placas})',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
