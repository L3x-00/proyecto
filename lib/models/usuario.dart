class Usuario {
  final int id;
  final String nombres;
  final String apellidos;
  final String correo;
  final String tipo;
  final String? token;

  Usuario({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.tipo,
    this.token,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombres: json['nombres'],
      apellidos: json['apellidos'],
      correo: json['correo'],
      tipo: json['tipo'].toString(),
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombres': nombres,
    'apellidos': apellidos,
    'correo': correo,
    'tipo': tipo,
    'token': token,
  };

  String get nombreCompleto => '$apellidos, $nombres';
}
