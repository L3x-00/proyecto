import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart'; // <--- Importamos el servicio

// 1. Convertimos a StatefulWidget para manejar el texto y la carga
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores para leer el texto de los inputs
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  // Servicio de autenticación
  final AuthService _authService = AuthService();

  // Estado de carga (para mostrar ruedita mientras espera)
  bool _isLoading = false;

  // Función para procesar el Login
  void _handleLogin() async {
    setState(() {
      _isLoading = true; // Activar carga
    });

    final email = _userController.text.trim();
    final password = _passController.text.trim();

    // Llamamos al servicio
    final success = await _authService.login(email, password);

    setState(() {
      _isLoading = false; // Desactivar carga
    });

    if (success && mounted) {
      // Si fue exitoso, vamos al seguimiento
      context.go('/seguimiento');
    } else if (mounted) {
      // Si falló, mostramos mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario o contraseña incorrectos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121517),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // LOGO
              const Text(
                'XTREME',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const Text(
                'PERFORMANCE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 60),

              const Text(
                'INICIAR SESION',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Ingrese su usuario y\ncontraseña',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 50),

              // INPUTS CONECTADOS A LOS CONTROLADORES
              _buildInput('Usuario', controller: _userController),
              const SizedBox(height: 20),
              _buildInput(
                'Contraseña',
                isPassword: true,
                controller: _passController,
              ),

              const SizedBox(height: 40),

              // BOTÓN INICIAR SESIÓN CON LÓGICA
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _handleLogin, // Si carga, deshabilita botón
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              // ... El resto de tus botones (Social, Registro) sigue igual ...
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () => context.push('/registro'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Registrarse',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    String label, {
    bool isPassword = false,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white38),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
