import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proyecto_cine_equipo3/Modelo/ModeloTipoBoletoSimple.dart';


class ControladorBoletos {
  static const String baseUrl = 'http://localhost:3000/api/admin';

  static Future<List<TipoBoletoSimple>> obtenerBoletos() async {
    final response = await http.get(Uri.parse('$baseUrl/getBoletos'));
    if (response.statusCode == 200) {
      final List lista = json.decode(response.body);
      return lista.map((e) => TipoBoletoSimple.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener boletos');
    }
  }

  static Future<bool> agregarBoleto(Map<String, dynamic> datos) async {
    final response = await http.post(
      Uri.parse('$baseUrl/addBoleto'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(datos),
    );
    return response.statusCode == 201;
  }

  static Future<bool> eliminarBoleto(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/deleteBoleto/$id'));
    return response.statusCode == 200;
  }

  static Future<bool> editarBoleto(int id, Map<String, dynamic> datos) async {
  final response = await http.put(
    Uri.parse('$baseUrl/updateBoleto/$id'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(datos),
  );
  return response.statusCode == 200;
}

}
