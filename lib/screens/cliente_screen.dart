import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/index.dart'; // Ajusta la ruta a tu AuthProvider
import '../services/api_service.dart'; // Ajusta la ruta a tu ApiService

class ClienteScreen extends StatefulWidget {
  const ClienteScreen({Key? key}) : super(key: key);

  @override
  State<ClienteScreen> createState() => _ClienteScreenState();
}

class _ClienteScreenState extends State<ClienteScreen> {
  late Future<List<dynamic>> _misVehiculos;

  @override
  void initState() {
    super.initState();
    final token = context.read<AuthProvider>().usuario?.token ?? '';
    
    final apiService = ApiService(); 
    _misVehiculos = apiService.obtenerMisVehiculos();
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos los datos del usuario para saludarlo
    final usuario = context.watch<AuthProvider>().usuario;

    return Scaffold(
      backgroundColor: const Color(0xFF151A22), // El color oscuro de tu marca
      appBar: AppBar(
        title: const Text('Mi Taller'),
        backgroundColor: const Color(0xFF151A22),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, ${usuario?.nombres ?? 'Cliente'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aquí están tus vehículos registrados:',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            
            // Aquí dibujamos la lista de vehículos
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _misVehiculos,
                builder: (context, snapshot) {
                  // Si está cargando...
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }
                  
                  // Si hubo un error...
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                    );
                  }
                  
                  // Si no tiene vehículos...
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aún no tienes vehículos en el taller.',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    );
                  }

                  // Si todo salió bien, dibujamos las tarjetas
                  final vehiculos = snapshot.data!;
                  
                  return ListView.builder(
                    itemCount: vehiculos.length,
                    itemBuilder: (context, index) {
                      final v = vehiculos[index];
                      return Card(
                        color: const Color(0xFF222831), // Un tono gris oscuro para contrastar
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${v['marca']} ${v['modelo']}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${v['anio']}',
                                      style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.white24, height: 24),
                              Row(
                                children: [
                                  const Icon(Icons.directions_car, color: Colors.white54, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Placas: ${v['placas']}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.color_lens, color: Colors.white54, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Color: ${v['color']}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}