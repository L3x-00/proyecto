import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/index.dart';
import '../models/index.dart';
import '../constants/app_theme.dart';
import '../widgets/app_header.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({Key? key}) : super(key: key);

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientesProvider>().loadClientes();
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
                  context.read<ClientesProvider>().buscarCliente(value);
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o RUC...',
                  hintStyle: TextStyle(color: colors.textPrimary.withOpacity(0.4)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF00C6FF)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close,
                              color: colors.textPrimary.withOpacity(0.5)),
                          onPressed: () {
                            _searchController.clear();
                            context.read<ClientesProvider>().buscarCliente('');
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
      body: Consumer<ClientesProvider>(
        builder: (context, clientesProvider, _) {
          if (clientesProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00C6FF)),
            );
          }

          if (clientesProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colors.textMuted),
                  const SizedBox(height: 20),
                  Text(
                    clientesProvider.error ?? 'Error desconocido',
                    style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => clientesProvider.loadClientes(),
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

          if (clientesProvider.clientes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 80, color: colors.textMuted),
                  const SizedBox(height: 24),
                  Text(
                    'No se encontraron clientes',
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
                  itemCount: clientesProvider.clientes.length,
                  itemBuilder: (context, index) {
                    final cliente = clientesProvider.clientes[index];
                    return _ClienteCard(cliente: cliente);
                  },
                ),
              ),
              if (!clientesProvider.isSearching)
                _Paginacion(provider: clientesProvider),
            ],
          );
        },
      ),
    );
  }
}

class _Paginacion extends StatelessWidget {
  final ClientesProvider provider;

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
            'Página ${provider.currentPage} de ${provider.totalPages} · ${provider.total} clientes',
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

class _ClienteCard extends StatelessWidget {
  final Cliente cliente;

  const _ClienteCard({required this.cliente});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bool isActivo = cliente.estado == 'Vigente' || cliente.estado == 'Activo';
    final Color statusColor = isActivo ? const Color(0xFF00E676) : const Color(0xFFFF3D00);

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
            Navigator.pushNamed(context, '/cliente-detalle', arguments: cliente);
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
                  child: const Icon(Icons.person, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cliente.nombre,
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
                        'RUC/DNI: ${cliente.ruc}',
                        style: TextStyle(
                          color: colors.textPrimary.withOpacity(0.5),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
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
                  ],
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
