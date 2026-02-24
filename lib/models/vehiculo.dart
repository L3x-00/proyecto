class Vehiculo {
  final int id;
  final String marca;
  final String modelo;
  final String anio;
  final String placas;
  final String color;
  final int idCliente;
  final String? cliente;

  Vehiculo({
    required this.id,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.placas,
    required this.color,
    required this.idCliente,
    this.cliente,
  });

  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    return Vehiculo(
      id: json['id'],
      marca: json['marca'] ?? '',
      modelo: json['modelo'] ?? '',
      anio: json['anio'].toString(),
      placas: json['placas'] ?? '',
      color: json['color'] ?? '',
      idCliente: json['idCliente'],
      cliente: json['cliente'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'marca': marca,
    'modelo': modelo,
    'anio': anio,
    'placas': placas,
    'color': color,
    'idCliente': idCliente,
    'cliente': cliente,
  };

  String get descripcion => '$marca $modelo ($anio)';
}
