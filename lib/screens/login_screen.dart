import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xtreme_performance/services/pusher_config.dart';
import '../providers/index.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final PusherConfig _pusherConfig = PusherConfig();
  final _correoController = TextEditingController();
  final _claveController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    void _mostrarAlerta(String contenido) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("¡Nuevo Evento Recibido!"),
            content: Text("Datos recibidos: $contenido"),
            actions: [
              TextButton(
                child: const Text("Cerrar"),
                onPressed: () {
                  Navigator.of(context).pop(); 
                },
              ),
            ],
          );
        },
      );
    }

    _pusherConfig.initPusher(
      channelName: "mi-canal",
      eventName: "mi-evento",
      onEventTriggered: (event) {
        print("hola ");
        if (!mounted) return;
        dynamic data;
        if (event.data is String) {
          data = jsonDecode(event.data.toString());
        } else {
          data = event.data;
        }
      },
    );
  }

  @override
  void dispose() {
    _pusherConfig.disconnect();
    _correoController.dispose();
    _claveController.dispose();
    super.dispose();
  }

  // --- FUNCIÓN CON ROLES INTEGRADA CORRECTAMENTE ---
  void _handleLogin() async {
    if (_correoController.text.isEmpty || _claveController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos.')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _correoController.text,
      _claveController.text,
    );

    if (success) {
      if (mounted) {
        final int rolUsuario = authProvider.usuario?.tipo ?? 0;
        print('Login successful. rolUsuario=$rolUsuario (${UserRole.getRoleName(rolUsuario)})');

        // Ruteo según el rol del usuario
        if (rolUsuario == UserRole.admin) {
          // 1 = Admin - Acceso total
          Navigator.of(context).pushReplacementNamed('/home');
        } else if (rolUsuario == UserRole.mecanico) {
          // 3 = Mecánico - Panel de mecánico
          Navigator.of(context).pushReplacementNamed('/mecanicoHome');
        } else if (rolUsuario == UserRole.cliente) {
          // 4 = Cliente - Panel de cliente
          Navigator.of(context).pushReplacementNamed('/clienteHome');
        } else if (rolUsuario == UserRole.operador) {
          // 2 = Operador - Panel de operador (mismo que admin por ahora)
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          // Rol desconocido
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Rol de usuario no reconocido')),
            );
          }
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error ?? 'Error en login')),
        );
      }
    }
  }
  // --------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: colors.textSecondary,
              ),
              tooltip: 'Cambiar tema',
              onPressed: () => themeProvider.toggleTheme(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 60,
                ),
                const SizedBox(height: 40),

                Text(
                  'INICIAR SESIÓN',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: colors.textPrimary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ingrese su usuario y\ncontraseña',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 60),

                TextField(
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Usuario',
                    labelStyle: TextStyle(color: colors.textMuted, fontSize: 14),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: colors.textMuted),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: colors.textPrimary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                TextField(
                  controller: _claveController,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: colors.textMuted, fontSize: 14),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: colors.textMuted),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: colors.textPrimary, width: 2),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: colors.textMuted,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 60),

                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBrandAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Iniciar sesión',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}