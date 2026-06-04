class Orden {
  final int id;
  final String fechaIngreso;
  final String? fechaSalida;
  final int estado;
  final String marca;
  final String modelo;
  final String placas;
  final String cliente;
  final double? monto;

  Orden({
    required this.id,
    required this.fechaIngreso,
    this.fechaSalida,
    required this.estado,
    required this.marca,
    required this.modelo,
    required this.placas,
    required this.cliente,
    this.monto,
  });

  factory Orden.fromJson(Map<String, dynamic> json) {
    double? parseMonto() {
      final v = json['monto'] ?? json['total'];
      if (v == null) return null;
      return double.tryParse(v.toString());
    }

    return Orden(
      id: int.tryParse(json['id'].toString()) ?? 0,
      fechaIngreso: json['fechaIngreso'] ?? '',
      fechaSalida: json['fechaSalida'],
      estado: int.tryParse(json['estado'].toString()) ?? 0,
      marca: json['marca'] ?? '',
      modelo: json['modelo'] ?? '',
      placas: json['placas'] ?? '',
      cliente: json['cliente'] ?? '',
      monto: parseMonto(),
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
