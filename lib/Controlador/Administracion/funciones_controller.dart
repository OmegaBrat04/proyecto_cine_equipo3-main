import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proyecto_cine_equipo3/Modelo/ModeloFunciones.dart';

class ControladorFun {
  static const String baseUrl = 'http://localhost:3000/api/admin';

  static Future<bool> agregarFuncion(Map<String, dynamic> data) async {
    final url = Uri.parse("http://localhost:3000/api/admin/addFunction");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      print("✅ Función agregada con éxito");
      return true;
    } else {
      print("❌ Error al agregar función: ${response.body}");
      return false;
    }
  }

  static Future<bool> funcionExiste(Map<String, dynamic> data) async {
    final url =
        Uri.parse('http://localhost:3000/api/admin/verificarFuncionExistente');

    try {
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (resp.statusCode == 200) {
        final jsonResp = jsonDecode(resp.body);
        return jsonResp['existe'] == true;
      }
    } catch (e) {
      print("Error al verificar función existente: $e");
    }

    return false;
  }

  static Future<List<FuncionLista>> obtenerFuncionesVigentes() async {
    final url = Uri.parse('$baseUrl/getFuncionesVigentes');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> lista = jsonDecode(response.body);
        return lista.map((f) => FuncionLista.fromJson(f)).toList();
      }
    } catch (e) {
      print("❌ Error al obtener funciones vigentes: $e");
    }

    return [];
  }

  static Future<bool> eliminarFuncion(int id) async {
    final url = Uri.parse('$baseUrl/deleteFunction/$id');

    try {
      final response = await http.delete(url);
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error al eliminar función: $e');
      return false;
    }
  }

  static Future<bool> actualizarFuncion(
      int id, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/updateFunction/$id');

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error al actualizar función: $e');
      return false;
    }
  }
}
