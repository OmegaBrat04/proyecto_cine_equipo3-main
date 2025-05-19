class Consumible {
  final String nombre;
  final String proveedor;
  final int stock;
  final double precioUnitario;
  final String? imagen;
  final String? unidad;

  Consumible({
    required this.nombre,
    required this.proveedor,
    required this.stock,
    required this.precioUnitario,
    this.imagen,
    this.unidad, 
  });

  factory Consumible.fromJson(Map<String, dynamic> json) {
    return Consumible(
      nombre: json['nombre'],
      proveedor: json['proveedor'],
      stock: json['stock'],
      precioUnitario: (json['precio_unitario'] as num).toDouble(),
      imagen: json['imagen'],
      unidad: json['unidad'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'proveedor': proveedor,
      'stock': stock,
      'precio_unitario': precioUnitario,
      'imagen': imagen,
      'unidad': unidad, 
    };
  }
}
