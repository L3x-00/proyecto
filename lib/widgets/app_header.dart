import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/index.dart';

/// Encabezado persistente reutilizado en las pantallas principales:
/// nombre de la empresa, acceso a editar perfil, cambio de tema y cierre de sesión.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final PreferredSizeWidget? bottom;
  final bool showProfileAction;
  final bool showLogoutAction;
  final Widget? flexibleSpace;
  final bool automaticallyImplyLeading;

  const AppHeader({
    Key? key,
    this.title,
    this.bottom,
    this.showProfileAction = true,
    this.showLogoutAction = true,
    this.flexibleSpace,
    this.automaticallyImplyLeading = false,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final usuario = context.watch<AuthProvider>().usuario;
    final themeProvider = context.watch<ThemeProvider>();

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: title == null
          ? Image.asset('assets/logo.png', height: 32, fit: BoxFit.contain)
          : Text(
              title!,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                fontSize: 20,
              ),
            ),
      iconTheme: IconThemeData(color: colors.textPrimary),
      actions: [
        if (showProfileAction)
          IconButton(
            icon: const Icon(Icons.account_circle, color: Color(0xFF00C6FF)),
            tooltip: 'Editar perfil',
            onPressed: () => _irAEditarPerfil(context, usuario),
          ),
        IconButton(
          icon: Icon(
            themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: colors.textSecondary,
          ),
          tooltip: 'Cambiar tema',
          onPressed: () => themeProvider.toggleTheme(),
        ),
        if (showLogoutAction)
          IconButton(
            icon: const Icon(Icons.power_settings_new_rounded, color: Colors.redAccent),
            tooltip: 'Cerrar sesión',
            onPressed: () => _confirmarCerrarSesion(context),
          ),
        const SizedBox(width: 4),
      ],
      bottom: bottom,
      flexibleSpace: flexibleSpace,
    );
  }

  void _irAEditarPerfil(BuildContext context, dynamic usuario) {
    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se encontró la sesión activa.')),
      );
      return;
    }
    Navigator.pushNamed(context, '/editar-perfil', arguments: usuario);
  }

  void _confirmarCerrarSesion(BuildContext context) {
    final colors = context.appColors;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: colors.border),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
              const SizedBox(width: 10),
              Text('Cerrar Sesión', style: TextStyle(color: colors.textPrimary)),
            ],
          ),
          content: Text(
            '¿Estás seguro de que deseas salir de tu cuenta?',
            style: TextStyle(color: colors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
              child: const Text('Salir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
