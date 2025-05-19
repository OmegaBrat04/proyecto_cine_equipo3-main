import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/Menu.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/RegistroProductos.dart';

void main() {
  runApp(const ListaProductos());
}

class ListaProductos extends StatelessWidget {
  const ListaProductos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Lista(),
    );
  }
}

// Modelo de datos para Producto
class Producto {
  final int id;
  final String nombre;
  final int stock;
  final double precio;
  final String imagen;
  final String tamano;
  final double porcionCantidad;
  final String porcionUnidad;

  Producto({
    required this.id,
    required this.nombre,
    required this.stock,
    required this.precio,
    required this.imagen,
    required this.tamano,
    required this.porcionCantidad,
    required this.porcionUnidad,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['idProducto'] as int,
      nombre: json['nombre'] as String,
      stock: json['stock'] as int,
      precio: (json['precio'] as num).toDouble(),
      imagen: json['imagen'] as String,
      tamano: json['tamano'] ?? json['Tamano'] ?? '',
      porcionCantidad:
          (json['porcionCantidad'] ?? json['PorcionCantidad'] as num?)
                  ?.toDouble() ??
              0.0,
      porcionUnidad: json['porcionUnidad'] ?? json['PorcionUnidad'] ?? '',
    );
  }
}

class Lista extends StatefulWidget {
  const Lista({Key? key}) : super(key: key);

  @override
  _ListaState createState() => _ListaState();
}

class _ListaState extends State<Lista> {
  final TextEditingController buscadorController = TextEditingController();
  List<Producto> productos = [];
  List<Producto> productosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _fetchProductos();
  }

  Future<void> _fetchProductos() async {
    final url = Uri.parse('http://localhost:3000/api/admin/getAllProductos');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> listaJson = jsonDecode(response.body);
        setState(() {
          productos = listaJson.map((json) => Producto.fromJson(json)).toList();
          productosFiltrados = productos;
        });
        print(listaJson);
      } else {
        print('Error al cargar productos: \${response.statusCode}');
      }
    } catch (e) {
      print('Error al conectar con la API: \$e');
    }
  }

  void _mostrarDialogoAumentarStock(String nombre, int stock,
      {required int productoId}) async {
    final TextEditingController cantidadController = TextEditingController();
    final cantidadNueva = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Aumentar stock de $nombre'),
        content: TextField(
          controller: cantidadController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Cantidad a añadir'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(cantidadController.text);
              if (val != null && val > 0) {
                Navigator.pop(context, val);
              }
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
    if (cantidadNueva != null && cantidadNueva > 0) {
      await _actualizarStockYDescontar(productoId, cantidadNueva);
    }
  }

  Future<void> _actualizarStockYDescontar(
      int productoId, int cantidadNueva) async {
    final uri =
        Uri.parse('http://localhost:3000/api/admin/aumentarStockProducto');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'idProducto': productoId,
        'cantidadAumentar': cantidadNueva,
      }),
    );
    if (resp.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Stock actualizado y descontado correctamente')),
      );
      await _fetchProductos(); // Recarga la lista automáticamente
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${resp.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF022044), Color(0xFF01021E)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.only(top: 14)),
              // Encabezado y buscador...
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Menu()),
                          ),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const Text(
                          'Atrás',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Lista de Productos',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFF0665A4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.asset(
                          'images/PICNITO LOGO.jpeg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Buscador
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: buscadorController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Buscar Producto...',
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.white),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            productosFiltrados = productos
                                .where((p) => p.nombre
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Botón Añadir Producto
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Registroproductos()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff14AE5C),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        minimumSize: const Size(150, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Color(0xffF5F5F5), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Añadir Producto',
                            style: TextStyle(
                                color: Color(0xffF5F5F5), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 1125,
                  height: 450,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xff081C42),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 5,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: _buildListaProductos(),
                ),
              ),
              const SizedBox(height: 15),
              // Botones de acción...
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListaProductos() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 50,
        mainAxisSpacing: 20,
        childAspectRatio: 0.6,
      ),
      itemCount: productosFiltrados.length,
      itemBuilder: (context, index) {
        final producto = productosFiltrados[index];
        return _buildTarjetaProducto(
          producto.id,
          producto.imagen,
          producto.nombre,
          producto.stock,
          producto.precio,
          producto.tamano,
          producto.porcionCantidad,
          producto.porcionUnidad,
        );
      },
    );
  }

  Widget _buildTarjetaProducto(
    int id,
    String imagen,
    String nombre,
    int stock,
    double precio,
    String tamano,
    double porcionCantidad,
    String porcionUnidad,
  ) {
    return Card(
      elevation: 5,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imagen.isNotEmpty
                    ? (imagen.startsWith('http')
                        ? Image.network(
                            imagen,
                            width: 140,
                            height: 140,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              EvaIcons.imageOutline,
                              size: 60,
                              color: Colors.grey,
                            ),
                          )
                        : Image.file(
                            File(imagen),
                            width: 140,
                            height: 140,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              EvaIcons.imageOutline,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ))
                    : const Icon(
                        EvaIcons.imageOutline,
                        size: 60,
                        color: Colors.grey,
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                nombre,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tamaño: ${tamano.isNotEmpty ? tamano : "Sin tamaño"}',
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
              Text(
                'Porción: ${porcionCantidad > 0 ? porcionCantidad.toStringAsFixed(2) : "-"} ${porcionUnidad.isNotEmpty ? porcionUnidad : ""}',
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
              Text('Stock: $stock',
                  style: const TextStyle(color: Colors.black, fontSize: 12)),
              Text('Precio: \$${precio.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.black, fontSize: 12)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    _mostrarDialogoAumentarStock(nombre, stock, productoId: id),
                child: const Text('Aumentar Stock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
