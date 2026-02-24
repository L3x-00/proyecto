import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/index.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController();
  final _claveController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _correoController.dispose();
    _claveController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_correoController.text.isEmpty || _claveController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
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
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error ?? 'Error en login')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151A22), 
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 2. Logo
                Image.asset(
                  'assets/logo.png', // Asegúrate de tener tu logo aquí
                  height: 60,
                ),
                const SizedBox(height: 40),

                // 3. Títulos principales
                const Text(
                  'INICIAR SESION',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ingrese su usuario y\ncontraseña',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 60),

                // 4. Campo de Usuario (Estilo línea inferior)
                TextField(
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white), // Texto al escribir en blanco
                  decoration: const InputDecoration(
                    labelText: 'Usuario',
                    labelStyle: TextStyle(color: Colors.white60, fontSize: 14),
                    // Línea inferior cuando no está seleccionado
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white60),
                    ),
                    // Línea inferior cuando está escribiendo
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 5. Campo de Contraseña
                TextField(
                  controller: _claveController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: const TextStyle(color: Colors.white60, fontSize: 14),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white60),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2),
                    ),
                    // Dejé el ojito para ver la contraseña pero con estilo sutil
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white60,
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
                          backgroundColor: Colors.white, // Fondo blanco
                          foregroundColor: Colors.black, // Efecto click en negro
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30), // Bordes redondeados
                          ),
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  // Cambiado a negro para que se vea sobre el botón blanco
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                ),
                              )
                            : const Text(
                                'Iniciar sesión',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
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