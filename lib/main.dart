import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'providers/index.dart';
import 'screens/index.dart';
import 'models/index.dart';
import 'screens/cliente_detalle_screen.dart';
import 'screens/vehiculo_detalle_screen.dart';
import 'screens/orden_detalle_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print(" Iniciando la aplicación...");
  final apiService = ApiService();
  await apiService.init();
  print(" ApiService inicializado. Lanzando UI...");
  runApp(MyApp(apiService: apiService));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;

  const MyApp({required this.apiService, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => apiService),
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService)),
        ChangeNotifierProvider(create: (_) => ClientesProvider(apiService)),
        ChangeNotifierProvider(create: (_) => VehiculosProvider(apiService)),
        ChangeNotifierProvider(create: (_) => OrdenesProvider(apiService)),
        ChangeNotifierProvider(create: (_) => SeguimientosProvider(apiService)),
      ],
      child: MaterialApp(
        title: 'Xtreme Performance',
        debugShowCheckedModeBanner: false,
        // TEMA DARK PREMIUM APLICADO A TODA LA APP
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor:
              const Color(0xFF12171D), // Fondo oscuro profundo
          primaryColor: Colors.blueAccent,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
          ),
        ),

        initialRoute: '/',

        routes: {
          '/': (context) => SplashScreen(apiService: apiService),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/cliente-detalle': (context) => const ClienteDetalleScreen(),
          '/vehiculo-detalle': (context) => const VehiculoDetalleScreen(),
          '/orden-detalle': (context) => const OrdenDetalleScreen(),
        },

        onGenerateRoute: (settings) {
          if (settings.name == '/seguimiento') {
            final orden = settings.arguments as Orden;
            return MaterialPageRoute(
              builder: (context) => SeguimientoScreen(orden: orden),
            );
          }
          return null;
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  final ApiService apiService;

  const SplashScreen({required this.apiService, Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeSesion();
  }

  Future<void> _initializeSesion() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      final authProvider = context.read<AuthProvider>();
      authProvider.restoreSession();
      final nextRoute = authProvider.isLogged ? '/home' : '/login';
      Navigator.of(context).pushReplacementNamed(nextRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Adaptamos también el Splash al estilo oscuro
      backgroundColor: const Color(0xFF12171D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.directions_car, size: 80, color: Colors.blueAccent),
            SizedBox(height: 24),
            Text(
              'Xtreme Performance',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
