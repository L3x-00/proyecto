import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/seguimientos_provider.dart';
import '../models/orden.dart';
import '../services/pusher_config.dart';
import '../constants/app_theme.dart';

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
  final ImagePicker _imagePicker = ImagePicker();
  File? _imagenSeleccionada;

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
                    colors: [kBrandPrimary, kBrandSecondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: kBrandSecondary.withOpacity(0.5),
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
    final Color bgColor = context.appColors.background;
    final Color cardColor = context.appColors.surface;
    const Color accentColor = kBrandPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Timeline - Orden #${widget.orden.id}',
          style: TextStyle(
            color: context.appColors.textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: context.appColors.textPrimary),
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
                      size: 64, color: context.appColors.textMuted),
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
                        side: BorderSide(color: context.appColors.border),
                      ),
                    ),
                    child: Text('Reintentar',
                        style: TextStyle(color: context.appColors.textPrimary)),
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
                                size: 80, color: context.appColors.textMuted),
                            const SizedBox(height: 24),
                            Text(
                              'Aún no hay seguimientos',
                              style: TextStyle(
                                color: context.appColors.textMuted,
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
                                            : context.appColors.border,
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
                                                : context.appColors.textPrimary.withOpacity(0.3),
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
                                              : context.appColors.border,
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
                                              : context.appColors.border,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: context.appColors.shadow,
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
                                                  : context.appColors.textPrimary
                                                      .withOpacity(0.5),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            seguimiento['observacion'] ?? '',
                                            style: TextStyle(
                                              color: context.appColors.textPrimary,
                                              fontSize: 16,
                                              height: 1.5,
                                            ),
                                          ),
                                          if ((seguimiento['imagenes']
                                                      as List?)
                                                  ?.isNotEmpty ==
                                              true) ...[
                                            const SizedBox(height: 14),
                                            SizedBox(
                                              height: 70,
                                              child: ListView.separated(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    (seguimiento['imagenes']
                                                            as List)
                                                        .length,
                                                separatorBuilder: (_, __) =>
                                                    const SizedBox(width: 8),
                                                itemBuilder: (context, i) {
                                                  final url = seguimiento[
                                                          'imagenes'][i]
                                                      .toString();
                                                  return GestureDetector(
                                                    onTap: () =>
                                                        _verImagenCompleta(
                                                            url),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(12),
                                                      child: Image.network(
                                                        url,
                                                        width: 70,
                                                        height: 70,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context,
                                                                error,
                                                                stackTrace) {
                                                          debugPrint(
                                                              'Error cargando imagen de seguimiento: $url -> $error');
                                                          return Container(
                                                            width: 70,
                                                            height: 70,
                                                            color: bgColor,
                                                            child: Icon(
                                                                Icons
                                                                    .broken_image,
                                                                color: context
                                                                    .appColors
                                                                    .textMuted),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
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
                        color: context.appColors.shadow,
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
                        style: TextStyle(color: context.appColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Describe el nuevo avance...',
                          hintStyle:
                              TextStyle(color: context.appColors.textPrimary.withOpacity(0.3)),
                          filled: true,
                          fillColor: bgColor,
                          contentPadding: const EdgeInsets.all(20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: context.appColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: context.appColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                                color: accentColor, width: 1.5),
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (_imagenSeleccionada != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _imagenSeleccionada!,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: -8,
                                    right: -8,
                                    child: GestureDetector(
                                      onTap: () => setState(
                                          () => _imagenSeleccionada = null),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.redAccent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close,
                                            size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          OutlinedButton.icon(
                            onPressed: _seleccionarImagen,
                            icon: const Icon(Icons.attach_file,
                                color: accentColor, size: 18),
                            label: Text(
                              _imagenSeleccionada == null
                                  ? 'Adjuntar foto'
                                  : 'Cambiar foto',
                              style: const TextStyle(color: accentColor),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: accentColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
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
                                    kBrandPrimary,
                                    kBrandSecondary
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: kBrandSecondary
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

  void _verImagenCompleta(String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () => Navigator.of(ctx).pop(),
          child: InteractiveViewer(
            child: Image.network(
              url,
              errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  color: Colors.white,
                  size: 64),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _seleccionarImagen() async {
    final Color cardColor = context.appColors.surface;
    final origen = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_camera,
                    color: context.appColors.textPrimary),
                title: Text('Tomar foto',
                    style: TextStyle(color: context.appColors.textPrimary)),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library,
                    color: context.appColors.textPrimary),
                title: Text('Elegir de la galería',
                    style: TextStyle(color: context.appColors.textPrimary)),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (origen == null) return;

    final XFile? archivo = await _imagePicker.pickImage(
      source: origen,
      maxWidth: 1600,
      imageQuality: 85,
    );

    if (archivo != null) {
      setState(() => _imagenSeleccionada = File(archivo.path));
    }
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
          imagen: _imagenSeleccionada,
        );
    setState(() => _isAdding = false);

    if (success) {
      _observacionController.clear();
      setState(() => _imagenSeleccionada = null);
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
