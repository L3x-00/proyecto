import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Envuelve [child] con una animación de entrada (fade + slide desde abajo)
/// cuyo retraso depende de [index], para lograr un efecto de "cascada" al
/// pintar listas (`ListView.builder`) o grids (KPIs del dashboard).
///
/// Un único lugar define la curva/tiempos para que todas las listas de la
/// app se sientan consistentes entre sí.
Widget staggeredItem(
  Widget child,
  int index, {
  Duration baseDelay = const Duration(milliseconds: 60),
  Duration duration = const Duration(milliseconds: 400),
}) {
  return child
      .animate()
      .fadeIn(duration: duration, delay: baseDelay * index, curve: Curves.easeOut)
      .slideY(begin: 0.15, end: 0, duration: duration, delay: baseDelay * index, curve: Curves.easeOut);
}
