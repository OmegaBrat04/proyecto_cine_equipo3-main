import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:proyecto_cine_equipo3/Modelo/ModeloConsumible.dart';

class ConsumibleController {
  final String baseUrl = 'http://localhost:3000';

  Future<List<Consumible>> fetchConsumibles(String proveedor) async {
    try {
      final url = Uri.parse('$baseUrl/api/admin/getAllConsumibles');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Consumible> consumibles =
            data.map((c) => Consumible.fromJson(c)).toList();

        if (proveedor == 'Todos') return consumibles;

        return consumibles.where((c) => c.proveedor == proveedor).toList();
      }
      return [];
    } catch (e) {
      print("❌ Error: $e");
      return [];
    }
  }

  List<Consumible> filtrar(List<Consumible> lista, String query) {
    if (query.isEmpty) return lista;
    return lista
        .where((c) => c.nombre.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<bool> guardarConsumible(BuildContext context, Consumible consumible,
      {bool esEdicion = false}) async {
    final url = Uri.parse(esEdicion
        ? 'http://localhost:3000/api/admin/updateConsumible/${consumible.nombre}'
        : 'http://localhost:3000/api/admin/addConsumible');

    final metodo = esEdicion ? http.put : http.post;

    final respuesta = await metodo(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': consumible.nombre,
        'proveedor': consumible.proveedor,
        'stock': consumible.stock,
        'precio_unitario': consumible.precioUnitario,
        'imagen': esEdicion ? consumible.imagen : (consumible.imagen ?? ''),
        'unidad': consumible.unidad
      }),
    );

    return respuesta.statusCode == 200 || respuesta.statusCode == 201;
  }
}
