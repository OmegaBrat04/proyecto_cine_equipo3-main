import 'dart:convert';

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
    final dynamic rawPoster = json['poster'];
    String posterString;

    if (rawPoster is String) {
      posterString = rawPoster;
    } else if (rawPoster is Map<String, dynamic> &&
        rawPoster.containsKey('data')) {
      final List<int> bytes = List<int>.from(rawPoster['data']);
      posterString = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    } else {
      posterString = '';
    }

    return Funcion(
      titulo: json['titulo'],
      genero: json['genero'],
      clasificacion: json['clasificacion'],
      duracion: json['duracion'],
      poster: posterString,
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

class FuncionLista {
  final int id;
  final String titulo;
  final String horario;
  final String fecha;
  final int sala;
  final String tipoSala;
  final String idioma;

  FuncionLista({
    required this.id,
    required this.titulo,
    required this.horario,
    required this.fecha,
    required this.sala,
    required this.tipoSala,
    required this.idioma,
  });

  factory FuncionLista.fromJson(Map<String, dynamic> json) {
    return FuncionLista(
      id: json['id'],
      titulo: json['titulo'],
      horario: json['horario'],
      fecha: json['fecha'],
      sala: json['sala'],
      tipoSala: json['tipo_sala'],
      idioma: json['idioma'],
    );
  }
}
