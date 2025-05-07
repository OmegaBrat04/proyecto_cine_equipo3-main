class TipoBoletoSimple {
  final int id;
  final String nombre;
  final double precio2D;
  final double precio3D;
  final String? fechaEspecial;

  TipoBoletoSimple({
    required this.id,
    required this.nombre,
    required this.precio2D,
    required this.precio3D,
    this.fechaEspecial,
  });

  factory TipoBoletoSimple.fromJson(Map<String, dynamic> json) {
    return TipoBoletoSimple(
      id: json['id_boleto'],
      nombre: json['nombre'],
      precio2D: (json['precio_2D'] as num).toDouble(),
      precio3D: (json['precio_3D'] as num).toDouble(),
      fechaEspecial: json['fecha_especial'],
    );
  }
}
