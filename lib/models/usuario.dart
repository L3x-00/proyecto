class Usuario {
  final int id;
  final String nombres;
  final String apellidos;
  final String correo;
  final String tipo;
  final String? token;
  final String telefono; // <-- 1. Agregamos la variable

  Usuario({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.tipo,
    this.token,
    this.telefono = '', // <-- 2. Valor por defecto vacío para evitar errores
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      correo: json['correo'] ?? '',
      tipo: json['tipo'].toString(),
      token: json['token'],
      telefono: json['telefono']?.toString() ?? '', // <-- 3. Lo extraemos del PHP
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombres': nombres,
    'apellidos': apellidos,
    'correo': correo,
    'tipo': tipo,
    'token': token,
    'telefono': telefono, // <-- 4. Lo empaquetamos
  };

  String get nombreCompleto => '$apellidos, $nombres';
}