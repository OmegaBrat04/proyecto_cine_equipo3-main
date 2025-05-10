// Aqui pon la logica de negocio para la administracion de peliculas
import 'dart:convert';
import 'package:http/http.dart' as http;

class PeliculasController {
  static const String baseUrl = 'http://localhost:3000/api/admin';

  static Future<List<Map<String, dynamic>>> obtenerPeliculas() async {
    final response = await http.get(Uri.parse('$baseUrl/getMovies'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al obtener películas');
    }
  }

  static Future<bool> eliminarPelicula(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/deleteMovie/$id'));
    return response.statusCode == 200;
  }

  static Future<bool> guardarPelicula(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/addMovie'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );
    return response.statusCode == 201;
  }

  static Future<bool> actualizarPelicula(int id, Map<String, dynamic> body) async {
  final response = await http.put(
    Uri.parse('$baseUrl/updateMovie/$id'),
    headers: {"Content-Type": "application/json"},
    body: json.encode(body),
  );
  return response.statusCode == 200;
}

}
