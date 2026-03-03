import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'providers/index.dart';
import 'screens/index.dart';

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
        ProxyProvider<ApiService, ApiService>(
          create: (_) => apiService,
          update: (_, api, __) => api,
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService)),
        ChangeNotifierProvider(create: (_) => ClientesProvider(apiService)),
        ChangeNotifierProvider(create: (_) => VehiculosProvider(apiService)),
        ChangeNotifierProvider(create: (_) => OrdenesProvider(apiService)),
      ],
      child: MaterialApp(
        title: 'Xtreme Performance',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),
        
        initialRoute: '/', 
        
        routes: {
          '/': (context) => SplashScreen(apiService: apiService),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/clientes': (context) => const ClientesScreen(),
          '/vehiculos': (context) => const VehiculosScreen(),
          '/ordenes': (context) => const OrdenesScreen(),
          '/configuracion': (context) => const ConfiguracionScreen(),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.blue.shade700],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_car, size: 80, color: Colors.white),
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
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
