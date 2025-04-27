class Funcion {
  final String titulo;
  final String genero;
  final String clasificacion;
  final String duracion;
  final String poster;
  final Map<String, List<Map<String, String>>> funciones;

  Funcion({
    required this.titulo,
    required this.genero,
    required this.clasificacion,
    required this.duracion,
    required this.poster,
    required this.funciones,
  });

  factory Funcion.fromJson(Map<String, dynamic> json) {
    return Funcion(
      titulo: json['titulo'],
      genero: json['genero'],
      clasificacion: json['clasificacion'],
      duracion: json['duracion'],
      poster: json['poster'],
      funciones: Map<String, List<Map<String, String>>>.from(
        json['funciones'].map(
          (key, value) => MapEntry(
            key,
            List<Map<String, String>>.from(
              value.map<Map<String, String>>(
                  (item) => Map<String, String>.from(item)),
            ),
          ),
        ),
      ),
    );
  }
}
