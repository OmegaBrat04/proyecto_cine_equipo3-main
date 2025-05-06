class PeliculaModel {
  final String titulo;
  final String director;
  final String duracion;
  final String idioma;
  final String genero;
  final String clasificacion;

  PeliculaModel({
    required this.titulo,
    required this.director,
    required this.duracion,
    required this.idioma,
    required this.genero,
    required this.clasificacion,
  });

  factory PeliculaModel.fromJson(Map<String, dynamic> json) {
    return PeliculaModel(
      titulo: json['titulo'] ?? '',
      director: json['director'] ?? '',
      duracion: json['duracion'] ?? '',
      idioma: json['idioma'] ?? '',
      genero: json['genero'] ?? '',
      clasificacion: json['clasificacion'] ?? '',
    );
  }

  Map<String, dynamic> toJson(
      String sinopsis, String subtitulos, String? poster) {
    return {
      'titulo': titulo,
      'director': director,
      'duracion': duracion,
      'idioma': idioma,
      'genero': genero,
      'clasificacion': clasificacion,
      'sinopsis': sinopsis,
      'subtitulos': subtitulos,
      'poster': poster ?? "",
    };
  }
}
