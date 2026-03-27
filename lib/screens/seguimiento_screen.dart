import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/seguimientos_provider.dart';
import '../models/orden.dart';
import '../services/pusher_config.dart';

class SeguimientoScreen extends StatefulWidget {
  final Orden orden;

  const SeguimientoScreen({Key? key, required this.orden}) : super(key: key);

  @override
  _SeguimientoScreenState createState() => _SeguimientoScreenState();
}

class _SeguimientoScreenState extends State<SeguimientoScreen> {
  final TextEditingController _observacionController = TextEditingController();
  bool _isAdding = false;
  final PusherConfig _pusherConfig = PusherConfig();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SeguimientosProvider>().loadSeguimientos(widget.orden.id);
      _initPusher();
    });
  }

  Future<void> _initPusher() async {
    await _pusherConfig.initPusher(
      channelName: 'orden-${widget.orden.id}',
      eventName: 'nuevo-seguimiento',
      onEventTriggered: (event) {
        if (!mounted) return;

        context.read<SeguimientosProvider>().loadSeguimientos(widget.orden.id);

        showDialog(
          context: context,
          barrierColor: Colors.black87.withOpacity(0.6),
          barrierDismissible: true,
          builder: (BuildContext dialogContext) {
            Future.delayed(const Duration(seconds: 3), () {
              if (Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }
            });

            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0072FF).withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.build_circle,
                          color: Colors.white, size: 56),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'ACTUALIZACIÓN EN VIVO',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '¡Nuevo avance registrado!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF0B0D17);
    const Color cardColor = Color(0xFF15192B);
    const Color accentColor = Color(0xFF00C6FF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Timeline - Orden #${widget.orden.id}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Consumer<SeguimientosProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: accentColor));
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: Colors.white.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    style:
                        const TextStyle(color: Colors.redAccent, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                      provider.loadSeguimientos(widget.orden.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                    child: const Text('Reintentar',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              SizedBox(
                  height:
                      MediaQuery.of(context).padding.top + kToolbarHeight + 20),
              Expanded(
                child: provider.seguimientos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_toggle_off,
                                size: 80, color: Colors.white.withOpacity(0.1)),
                            const SizedBox(height: 24),
                            const Text(
                              'Aún no hay seguimientos',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding:
                            const EdgeInsets.only(top: 10, left: 24, right: 24),
                        itemCount: provider.seguimientos.length,
                        itemBuilder: (context, index) {
                          final seguimiento = provider.seguimientos[index];
                          final bool isFirst = index == 0;
                          final bool isLast =
                              index == provider.seguimientos.length - 1;

                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  width: 40,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 2,
                                        height: 30,
                                        color: isFirst
                                            ? Colors.transparent
                                            : Colors.white.withOpacity(0.1),
                                      ),
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color:
                                              isFirst ? accentColor : bgColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isFirst
                                                ? accentColor
                                                : Colors.white.withOpacity(0.3),
                                            width: 3,
                                          ),
                                          boxShadow: isFirst
                                              ? [
                                                  BoxShadow(
                                                    color: accentColor
                                                        .withOpacity(0.6),
                                                    blurRadius: 10,
                                                    spreadRadius: 2,
                                                  ),
                                                ]
                                              : [],
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          width: 2,
                                          color: isLast
                                              ? Colors.transparent
                                              : Colors.white.withOpacity(0.1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 30.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: cardColor,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isFirst
                                              ? accentColor.withOpacity(0.3)
                                              : Colors.white.withOpacity(0.05),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            seguimiento['fecha'] ?? '',
                                            style: TextStyle(
                                              color: isFirst
                                                  ? accentColor
                                                  : Colors.white
                                                      .withOpacity(0.5),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            seguimiento['observacion'] ?? '',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              height: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              // LÓGICA DE OCULTAMIENTO: Solo se dibuja si no está Facturada
              if (widget.orden.estado != 2)
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.only(
                      top: 24.0, left: 24.0, right: 24.0, bottom: 40.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _observacionController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Describe el nuevo avance...',
                          hintStyle:
                              TextStyle(color: Colors.white.withOpacity(0.3)),
                          filled: true,
                          fillColor: bgColor,
                          contentPadding: const EdgeInsets.all(20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.05)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.05)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                                color: accentColor, width: 1.5),
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      _isAdding
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child:
                                  CircularProgressIndicator(color: accentColor),
                            )
                          : Container(
                              width: double.infinity,
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF00C6FF),
                                    Color(0xFF0072FF)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0072FF)
                                        .withOpacity(0.4),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _addSeguimiento,
                                icon: const Icon(Icons.add_task_rounded,
                                    color: Colors.white),
                                label: const Text(
                                  'REGISTRAR AVANCE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addSeguimiento() async {
    final observacion = _observacionController.text.trim();
    if (observacion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor ingrese una observación',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isAdding = true);
    final success = await context.read<SeguimientosProvider>().addSeguimiento(
          widget.orden.id,
          observacion,
        );
    setState(() => _isAdding = false);

    if (success) {
      _observacionController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error al agregar seguimiento',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pusherConfig.disconnect();
    _observacionController.dispose();
    super.dispose();
  }
}
