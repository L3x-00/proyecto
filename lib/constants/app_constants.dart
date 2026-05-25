// Constantes para roles de usuario (deben coincidir con el backend)
class UserRole {
  static const int admin = 1;      // Administrador
  static const int operador = 2;   // Operador
  static const int mecanico = 3;   // Mecánico
  static const int cliente = 4;    // Cliente

  // Mapa para convertir números a strings
  static const Map<int, String> roleNames = {
    1: 'ADMIN',
    2: 'OPERADOR',
    3: 'MECANICO',
    4: 'CLIENTE',
  };

  // Obtener nombre del rol basado en número
  static String getRoleName(int roleId) {
    return roleNames[roleId] ?? 'DESCONOCIDO';
  }

  // Verificar si es administrador
  static bool isAdmin(int roleId) => roleId == admin;

  // Verificar si es mecánico
  static bool isMecanico(int roleId) => roleId == mecanico;

  // Verificar si es cliente
  static bool isCliente(int roleId) => roleId == cliente;

  // Verificar si es operador
  static bool isOperador(int roleId) => roleId == operador;
}
