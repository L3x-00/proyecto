import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'providers/index.dart';
import 'screens/index.dart';
import 'models/index.dart';
import 'screens/cliente_detalle_screen.dart';
import 'screens/vehiculo_detalle_screen.dart';
import 'screens/orden_detalle_screen.dart';
import 'screens/editar_perfil_screen.dart';
import 'package:xtreme_performance/screens/cliente_screen.dart';
import 'constants/app_constants.dart';
import 'constants/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print(" Iniciando la aplicación...");
  
  await SharedPreferences.getInstance();
  
  final apiService = ApiService();
  await apiService.init();
  await NotificationService().init();
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();
  print(" ApiService inicializado. Lanzando UI...");
  runApp(MyApp(apiService: apiService, themeProvider: themeProvider));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;
  final ThemeProvider themeProvider;

  const MyApp({required this.apiService, required this.themeProvider, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => apiService),
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService)),
        ChangeNotifierProvider(create: (_) => ClientesProvider(apiService)),
        ChangeNotifierProvider(create: (_) => MecanicosProvider(apiService)),
        ChangeNotifierProvider(create: (_) => VehiculosProvider(apiService)),
        ChangeNotifierProvider(create: (_) => OrdenesProvider(apiService)),
        ChangeNotifierProvider(create: (_) => SeguimientosProvider(apiService)),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) => MaterialApp(
          title: 'Xtreme Performance',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: theme.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => SplashScreen(apiService: apiService),
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/mecanicoHome': (context) => const MecanicoScreen(),
            '/clienteHome': (context) => const ClienteScreen(),
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
            if (settings.name == '/editar-perfil') {
              final usuario = settings.arguments as Usuario;
              return MaterialPageRoute(
                builder: (context) => EditarPerfilScreen(
                  idUsuario: usuario.id,
                  nombresActuales: usuario.nombres ?? '',
                  apellidosActuales: usuario.apellidos ?? '',
                  telefonoActual: usuario.telefono ?? '',
                  correoActual: usuario.correo ?? '',
                ),
              );
            }
            return null;
          },
        ),
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

      String nextRoute = '/login';
      if (authProvider.isLogged) {
        final int rolUsuario = authProvider.usuario?.tipo ?? 0;

        // Redireccionar según el rol
        if (rolUsuario == UserRole.admin) {
          nextRoute = '/home'; // Admin panel
        } else if (rolUsuario == UserRole.mecanico) {
          nextRoute = '/mecanicoHome'; // Mecánico panel
        } else if (rolUsuario == UserRole.cliente) {
          nextRoute = '/clienteHome'; // Cliente panel
        } else if (rolUsuario == UserRole.operador) {
          nextRoute = '/home'; // Operador (mismo que admin por ahora)
        }
      }

      Navigator.of(context).pushReplacementNamed(nextRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = context.appColors.textPrimary;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car, size: 80, color: kBrandPrimary)
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 400.ms)
                .animate(onPlay: (c) => c.repeat(reverse: true), delay: 700.ms)
                .scaleXY(end: 1.08, duration: 1000.ms, curve: Curves.easeInOut),
            const SizedBox(height: 24),
            Text(
              'Xtreme Performance',
              style: GoogleFonts.rajdhani(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: 1.0,
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(
                  begin: 0.3,
                  end: 0,
                  delay: 300.ms,
                  duration: 500.ms,
                  curve: Curves.easeOut,
                ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(kBrandPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}