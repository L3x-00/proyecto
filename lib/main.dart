import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nueva_app2/screens/my_home_page.dart';
import 'package:nueva_app2/screens/registro_page.dart';
import 'package:nueva_app2/screens/inicio_page.dart';
import 'package:nueva_app2/screens/seguimiento_page.dart';
import 'package:nueva_app2/screens/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/', 
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) =>
          const MyHomePage(title: "XTREME PERFORMANCE"),
    ), GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/registro',
      builder: (context, state) => const RegistroPage(),
    ),
    GoRoute(path: '/inicio', builder: (context, state) => const InicioPage()),
    GoRoute(
      path: '/seguimiento',
      builder: (context, state) => const SeguimientoPage(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Xtreme Performance App',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121517),
        primaryColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
