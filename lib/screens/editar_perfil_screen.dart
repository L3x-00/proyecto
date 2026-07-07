import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/app_header.dart';

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
    final apiService = context.read<ApiService>();
    final mensajero = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);

    setState(() => _isLoading = true);

    // 2. Enviamos al servidor
    final resultado = await apiService.actualizarPerfil(
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
      await authProvider.actualizarUsuarioActual(
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
    final colors = context.appColors;
    const Color accentColor = kBrandPrimary;

    return Scaffold(
      appBar: const AppHeader(
        title: 'Editar Perfil',
        showProfileAction: false,
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: colors.surface,
              child: const Icon(Icons.person, size: 50, color: accentColor),
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
                        colors: [kBrandPrimary, kBrandSecondary],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kBrandSecondary.withOpacity(0.4),
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
    final colors = context.appColors;
    return TextField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      style: TextStyle(color: colors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors.textPrimary.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: colors.textPrimary.withOpacity(0.5)),
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kBrandPrimary, width: 1.5),
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