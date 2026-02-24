class Orden {
  final int id;
  final String fechaIngreso;
  final String? fechaSalida;
  final int estado;
  final String marca;
  final String modelo;
  final String placas;
  final String cliente;

  Orden({
    required this.id,
    required this.fechaIngreso,
    this.fechaSalida,
    required this.estado,
    required this.marca,
    required this.modelo,
    required this.placas,
    required this.cliente,
  });

  factory Orden.fromJson(Map<String, dynamic> json) {
    return Orden(
      id: json['id'],
      fechaIngreso: json['fechaIngreso'] ?? '',
      fechaSalida: json['fechaSalida'],
      estado: json['estado'],
      marca: json['marca'] ?? '',
      modelo: json['modelo'] ?? '',
      placas: json['placas'] ?? '',
      cliente: json['cliente'] ?? '',
    );
  }

  String get estadoText {
    switch(estado) {
      case 1:
        return 'Abierta';
      case 2:
        return 'Facturada';
      default:
        return 'Desconocido';
    }
  }

  String get vehiculoCompleto => '$marca $modelo';
}
