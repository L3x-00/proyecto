import 'package:flutter/material.dart';

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF121517),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'XTREME',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
          ),
          const Text(
            'PERFORMANCE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 20),
          Image.network(
            'https://pngimg.com/uploads/porsche/porsche_PNG10620.png',
            height: 200,
          ),
          const SizedBox(height: 40),
          const Text(
            'COMPROMETIDOS CON LA CALIDAD',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ofrecemos servicios automotrices con altos estándares de calidad, precisión y puntualidad.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 150),
        ],
      ),
    );
  }
}
