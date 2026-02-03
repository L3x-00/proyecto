import 'package:flutter/material.dart';

class SeguimientoPage extends StatelessWidget {
  const SeguimientoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Image.network(
              'https://via.placeholder.com/100x30?text=XTREME',
              width: 80,
            ), // Logo pequeño
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nissan GT - R',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            _buildInfoField('Fecha de ingreso:', '12/12/2004 08:55 am'),
            const SizedBox(height: 15),
            _buildInfoField(
              'Observacion:',
              'El vehículo presenta múltiples fallas en motor, neumáticos y pintura que se procederá a solucionar',
              maxLines: 3,
            ),

            const SizedBox(height: 25),
            const Text(
              'Avance del progreso',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // Grid de Progreso
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.8,
              children: [
                _progressCard(
                  'Identificado los problemas',
                  '13 Dic. 10:45 am',
                  'https://via.placeholder.com/150',
                ),
                _progressCard(
                  'Reparacion de ruedas delanteras',
                  '15 Dic. 12:10 am',
                  'https://via.placeholder.com/150',
                ),
                _progressCard(
                  'Ensamble de motor',
                  '18 Dic. 12:15 am',
                  'https://via.placeholder.com/150',
                ),
                _progressCard(
                  'Planchado y pintura',
                  '18 Dic. 05:00pm',
                  'https://via.placeholder.com/150',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87),
            maxLines: maxLines,
          ),
        ),
      ],
    );
  }

  Widget _progressCard(String title, String date, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              imageUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 5),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
