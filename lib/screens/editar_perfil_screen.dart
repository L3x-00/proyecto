import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class EditarPerfilScreen extends StatefulWidget {
  final int idUsuario;
  final String nombresActuales;
  final String apellidosActuales;
  final String telefonoActual;
  final String correoActual;

  const EditarPerfilScreen({
    Key? key,
    required this.idUsuario,
    required this.nombresActuales,
    required this.apellidosActuales,
    required this.telefonoActual,
    required this.correoActual,
  }) : super(key: key);

  @override
  _EditarPerfilScreenState createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  late TextEditingController _nombresController;
  late TextEditingController _apellidosController;
  late TextEditingController _telefonoController;
  late TextEditingController _correoController;
  
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _nombresController = TextEditingController(text: widget.nombresActuales);
    _apellidosController = TextEditingController(text: widget.apellidosActuales);
    _telefonoController = TextEditingController(text: widget.telefonoActual);
    _correoController = TextEditingController(text: widget.correoActual);
  }

  Future<void> _guardarCambios() async {
    // 1. Capturamos el contexto de forma segura
    final authProvider = context.read<AuthProvider>();
    final mensajero = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);

    setState(() => _isLoading = true);

    // 2. Enviamos al servidor
    final resultado = await _apiService.actualizarPerfil(
      widget.idUsuario,
      _nombresController.text.trim(),
      _apellidosController.text.trim(),
      _telefonoController.text.trim(),
      _correoController.text.trim(),
    );

    // Si la pantalla se cerró mientras cargaba, nos detenemos aquí
    if (!mounted) return;

    setState(() => _isLoading = false);

    // 3. Procesamos la respuesta
    if (resultado['success']) {
      authProvider.actualizarUsuarioActual(
        _nombresController.text.trim(),
        _apellidosController.text.trim(),
        _telefonoController.text.trim(),
        _correoController.text.trim(),
      );

      mensajero.showSnackBar(
        const SnackBar(content: Text('¡Perfil actualizado con éxito!'), backgroundColor: Colors.green),
      );
      
      navegador.pop(true); 
    } else {
      mensajero.showSnackBar(
        SnackBar(content: Text(resultado['error'] ?? 'Error desconocido'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF0B0D17);
    const Color cardColor = Color(0xFF15192B);
    const Color accentColor = Color(0xFF00C6FF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Editar Perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: cardColor,
              child: Icon(Icons.person, size: 50, color: accentColor),
            ),
            const SizedBox(height: 30),
            _buildTextField('Nombres', Icons.badge, _nombresController),
            const SizedBox(height: 20),
            _buildTextField('Apellidos', Icons.badge_outlined, _apellidosController),
            const SizedBox(height: 20),
            _buildTextField('Teléfono', Icons.phone, _telefonoController, isPhone: true),
            const SizedBox(height: 20),
            _buildTextField('Correo Electrónico', Icons.email, _correoController),
            const SizedBox(height: 40),
            
            _isLoading
                ? const CircularProgressIndicator(color: accentColor)
                : Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0072FF).withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _guardarCambios,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'GUARDAR CAMBIOS',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool isPhone = false}) {
    return TextField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.5)),
        filled: true,
        fillColor: const Color(0xFF15192B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF00C6FF), width: 1.5),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    super.dispose();
  }
}