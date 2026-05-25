class Usuario {
  final int id;
  final String nombres;
  final String apellidos;
  final String correo;
  final int tipo; // Cambiar a int para mantener consistencia con backend
  final String? token;
  final String telefono;

  Usuario({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.tipo,
    this.token,
    this.telefono = '',
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      correo: json['correo'] ?? '',
      tipo: json['tipo'] is int ? json['tipo'] : int.tryParse(json['tipo'].toString()) ?? 0,
      token: json['token'],
      telefono: json['telefono']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombres': nombres,
    'apellidos': apellidos,
    'correo': correo,
    'tipo': tipo,
    'token': token,
    'telefono': telefono,
  };

  String get nombreCompleto => '$apellidos, $nombres';

  // Helper methods para verificar rol
  bool get esAdmin => tipo == 1;
  bool get esOperador => tipo == 2;
  bool get esMecanico => tipo == 3;
  bool get esCliente => tipo == 4;
}