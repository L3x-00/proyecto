import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/index.dart';
import '../models/index.dart';

class VehiculosScreen extends StatefulWidget {
  const VehiculosScreen({Key? key}) : super(key: key);

  @override
  State<VehiculosScreen> createState() => _VehiculosScreenState();
}

class _VehiculosScreenState extends State<VehiculosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehiculosProvider>().loadVehiculos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehículos'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (value) {
                // Filtramos mientras el usuario escribe
                context.read<VehiculosProvider>().buscarVehiculo(value);
              },
              decoration: InputDecoration(
                hintText: 'Buscar por placa o modelo...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<VehiculosProvider>(
        builder: (context, vehiculosProvider, _) {
          if (vehiculosProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vehiculosProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(vehiculosProvider.error ?? 'Error desconocido', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => vehiculosProvider.loadVehiculos(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (vehiculosProvider.vehiculos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No se encontraron vehículos'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: vehiculosProvider.vehiculos.length,
            itemBuilder: (context, index) {
              final vehiculo = vehiculosProvider.vehiculos[index];
              return _VehiculoCard(vehiculo: vehiculo);
            },
          );
        },
      ),
    );
  }
}

class _VehiculoCard extends StatelessWidget {
  final Vehiculo vehiculo;

  const _VehiculoCard({required this.vehiculo});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Futura navegación al detalle del vehículo
          // Navigator.pushNamed(context, '/vehiculo-detalle', arguments: vehiculo.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    vehiculo.placas.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Ver Detalle',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1),
              ),
              Row(
                children: [
                  const Icon(Icons.directions_car, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text('${vehiculo.marca ?? "Marca"} - ${vehiculo.modelo}', style: const TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}