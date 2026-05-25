class Mecanico {
  final int id;
  final String nombres;
  final String apellidos;
  final String correo;
  final String telefono;
  final int idTipoMecanico; // 1: Motores, 2: Transmisiones, 3: Frenos, 4: Eléctrico, 5: Hojalatería
  final int estado; // 1: Disponible, 2: Ocupado, 3: Vacaciones
  final String? especialidad;

  Mecanico({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.telefono,
    required this.idTipoMecanico,
    required this.estado,
    this.especialidad,
  });

  factory Mecanico.fromJson(Map<String, dynamic> json) {
    return Mecanico(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      correo: json['correo'] ?? '',
      telefono: json['telefono'] ?? '',
      idTipoMecanico: json['idTipoMecanico'] != null ? int.tryParse(json['idTipoMecanico'].toString()) ?? 0 : 0,
      estado: json['estado'] != null ? int.tryParse(json['estado'].toString()) ?? 0 : 0,
      especialidad: json['especialidad'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombres': nombres,
    'apellidos': apellidos,
    'correo': correo,
    'telefono': telefono,
    'idTipoMecanico': idTipoMecanico,
    'estado': estado,
    'especialidad': especialidad,
  };

  String get nombreCompleto => '$apellidos, $nombres';

  String get nombreEspecialidad {
    const especialidades = {
      1: 'Motores',
      2: 'Transmisiones',
      3: 'Frenos',
      4: 'Eléctrico',
      5: 'Hojalatería',
    };
    return especialidades[idTipoMecanico] ?? 'Desconocida';
  }

  String get nombreEstado {
    const estados = {
      1: 'Disponible',
      2: 'Ocupado',
      3: 'Vacaciones',
    };
    return estados[estado] ?? 'Desconocido';
  }

  bool get estaDisponible => estado == 1;
  bool get estaOcupado => estado == 2;
  bool get estaEnVacaciones => estado == 3;
}
