class Cliente {
  final int id;
  final String nombre;
  final String telefono;
  final String correo;
  final String estado;
  final String ruc;

  Cliente({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.correo,
    required this.estado,
    required this.ruc,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      
      nombre: json['nombre'] ?? '',
      telefono: json['telefono'] ?? '',
      correo: json['correo'] ?? '',
      estado: json['estado'] ?? 'Desconocido',
      ruc: json['ruc'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'telefono': telefono,
    'correo': correo,
    'estado': estado,
    'ruc': ruc,
  };
}
