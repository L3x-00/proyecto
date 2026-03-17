import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/seguimientos_provider.dart';
import '../models/orden.dart';
import '../services/pusher_config.dart';
import 'dart:convert';

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
    print('Iniciando Pusher para orden-${widget.orden.id}');
    await _pusherConfig.initPusher(
      channelName: 'orden-${widget.orden.id}',
      eventName: 'nuevo-seguimiento',
      onEventTriggered: (event) {
        // 1. SEGURIDAD: Evita errores si la pantalla ya se cerró
        if (!mounted) return;

        // 2. CELEBRACIÓN EN CONSOLA
        print('🎉 ¡MAGIA! EVENTO RECIBIDO DESDE PHP');

        // 3. ACTUALIZAR LA LISTA EN TIEMPO REAL
        context.read<SeguimientosProvider>().loadSeguimientos(widget.orden.id);

        // 4. MOSTRAR ALERTA VISUAL ELEGANTE
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.directions_car, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '¡Nuevo avance registrado en el vehículo!',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.blueAccent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 4),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seguimientos - Orden ${widget.orden.id}'),
        backgroundColor: Colors.blue,
      ),
      body: Consumer<SeguimientosProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                      provider.loadSeguimientos(widget.orden.id);
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: provider.seguimientos.isEmpty
                    ? const Center(
                        child: Text('No hay seguimientos para esta orden'))
                    : ListView.builder(
                        itemCount: provider.seguimientos.length,
                        itemBuilder: (context, index) {
                          final seguimiento = provider.seguimientos[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(seguimiento['observacion'] ?? ''),
                              subtitle: Text(
                                'Fecha: ${seguimiento['fecha'] ?? ''}\nVehículo: ${seguimiento['vehiculo'] ?? ''}',
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _observacionController,
                      decoration: const InputDecoration(
                        labelText: 'Nueva observación',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _isAdding
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _addSeguimiento,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text('Agregar Seguimiento'),
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
        const SnackBar(content: Text('Por favor ingrese una observación')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seguimiento agregado exitosamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al agregar seguimiento')),
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
