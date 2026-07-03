// Definición de permisos y funcionalidades por rol
class RolePermissions {
  // ADMINISTRADOR - Acceso total
  static const adminPermissions = {
    'ver_dashboard': true,
    'ver_clientes': true,
    'crear_cliente': true,
    'editar_cliente': true,
    'eliminar_cliente': true,
    'ver_vehiculos': true,
    'crear_vehiculo': true,
    'editar_vehiculo': true,
    'eliminar_vehiculo': true,
    'ver_ordenes': true,
    'crear_orden': true,
    'editar_orden': true,
    'eliminar_orden': true,
    'ver_mecanicos': true,
    'crear_mecanico': true,
    'editar_mecanico': true,
    'eliminar_mecanico': true,
    'ver_seguimientos': true,
    'crear_seguimiento': true,
    'ver_reportes': true,
    'ver_configuracion': true,
    'editar_configuracion': true,
  };

  // OPERADOR - Permisos limitados de gestión
  static const operadorPermissions = {
    'ver_dashboard': true,
    'ver_clientes': true,
    'crear_cliente': true,
    'editar_cliente': true,
    'eliminar_cliente': false,
    'ver_vehiculos': true,
    'crear_vehiculo': true,
    'editar_vehiculo': true,
    'eliminar_vehiculo': false,
    'ver_ordenes': true,
    'crear_orden': true,
    'editar_orden': true,
    'eliminar_orden': false,
    'ver_mecanicos': true,
    'crear_mecanico': false,
    'editar_mecanico': false,
    'eliminar_mecanico': false,
    'ver_seguimientos': true,
    'crear_seguimiento': true,
    'ver_reportes': true,
    'ver_configuracion': false,
    'editar_configuracion': false,
  };

  // MECÁNICO - Solo órdenes y seguimientos asignados
  static const mecanicoPermissions = {
    'ver_dashboard': true,
    'ver_clientes': false,
    'crear_cliente': false,
    'editar_cliente': false,
    'eliminar_cliente': false,
    'ver_vehiculos': false,
    'crear_vehiculo': false,
    'editar_vehiculo': false,
    'eliminar_vehiculo': false,
    'ver_ordenes': true,
    'crear_orden': false,
    'editar_orden': false,
    'eliminar_orden': false,
    'ver_mecanicos': false,
    'crear_mecanico': false,
    'editar_mecanico': false,
    'eliminar_mecanico': false,
    'ver_seguimientos': true,
    'crear_seguimiento': true,
    'ver_reportes': false,
    'ver_configuracion': true,
    'editar_configuracion': false,
    'editar_perfil': true,
    'cambiar_clave': true,
  };

  // CLIENTE - Solo sus datos y vehículos
  static const clientePermissions = {
    'ver_dashboard': true,
    'ver_clientes': false,
    'crear_cliente': false,
    'editar_cliente': true,
    'eliminar_cliente': false,
    'ver_vehiculos': true,
    'crear_vehiculo': true,
    'editar_vehiculo': true,
    'eliminar_vehiculo': false,
    'ver_ordenes': true,
    'crear_orden': false,
    'editar_orden': false,
    'eliminar_orden': false,
    'ver_mecanicos': false,
    'crear_mecanico': false,
    'editar_mecanico': false,
    'eliminar_mecanico': false,
    'ver_seguimientos': true,
    'crear_seguimiento': false,
    'ver_reportes': false,
    'ver_configuracion': true,
    'editar_configuracion': false,
    'editar_perfil': true,
    'cambiar_clave': false,
  };

  // Obtener permisos según rol
  static Map<String, bool> getPermissionsByRole(int roleId) {
    switch (roleId) {
      case 1: // Admin
        return adminPermissions;
      case 2: // Operador
        return operadorPermissions;
      case 3: // Mecánico
        return mecanicoPermissions;
      case 4: // Cliente
        return clientePermissions;
      default:
        return {}; // Sin permisos si no se reconoce el rol
    }
  }

  // Verificar un permiso específico
  static bool hasPermission(int roleId, String permission) {
    final permissions = getPermissionsByRole(roleId);
    return permissions[permission] ?? false;
  }

  // Obtener lista de rutas accesibles según rol
  static List<String> getAccessibleRoutes(int roleId) {
    switch (roleId) {
      case 1: // Admin - Acceso total
        return [
          '/home',
          '/dashboard',
          '/clientes',
          '/vehiculos',
          '/ordenes',
          '/mecanicos',
          '/configuracion',
        ];
      case 2: // Operador
        return [
          '/home',
          '/dashboard',
          '/clientes',
          '/vehiculos',
          '/ordenes',
          '/configuracion',
        ];
      case 3: // Mecánico
        return [
          '/mecanicoHome',
          '/dashboard',
          '/ordenes',
        ];
      case 4: // Cliente
        return [
          '/clienteHome',
          '/dashboard',
          '/vehiculos',
          '/ordenes',
        ];
      default:
        return ['/login'];
    }
  }
}
