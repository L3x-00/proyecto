class AvanceModel {
  final int id;
  final String titulo;
  final String fecha;
  final String imageUrl;

  AvanceModel({
    required this.id,
    required this.titulo,
    required this.fecha,
    required this.imageUrl,
  });

  // Factory para crear una instancia desde un JSON (Map)
  factory AvanceModel.fromJson(Map<String, dynamic> json) {
    return AvanceModel(
      id: json['id'] ?? 0,
      titulo: json['title'] ?? 'Sin título',
      fecha: json['date'] ?? '',
      imageUrl: json['image'] ?? 'https://via.placeholder.com/150',
    );
  }
}