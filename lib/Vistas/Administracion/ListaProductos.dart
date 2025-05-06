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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Lista(),
      ),
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

  Producto({
    required this.id,
    required this.nombre,
    required this.stock,
    required this.precio,
    required this.imagen,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['idProducto'] as int,
      nombre: json['nombre'] as String,
      stock: json['stock'] as int,
      precio: (json['precio'] as num).toDouble(),
      imagen: json['imagen'] as String,
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
    final url = Uri.parse('http://localhost:3000/getAllProductos');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> listaJson = jsonDecode(response.body);
        setState(() {
          productos = listaJson.map((json) => Producto.fromJson(json)).toList();
          productosFiltrados = productos;
        });
      } else {
        print('Error al cargar productos: \${response.statusCode}');
      }
    } catch (e) {
      print('Error al conectar con la API: \$e');
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
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: TextField(
                    controller: buscadorController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar Producto...',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
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
                            .where((p) => p.nombre.toLowerCase().contains(
                                  value.toLowerCase(),
                                ))
                            .toList();
                      });
                    },
                  ),
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
          producto.imagen,
          producto.nombre,
          producto.stock,
          producto.precio,
        );
      },
    );
  }

  Widget _buildTarjetaProducto(
      String imagen, String nombre, int stock, double precio) {
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
                'Stock: $stock',
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                'Precio: \$${precio.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
