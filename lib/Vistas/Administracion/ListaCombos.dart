import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/RegistroCombos.dart';

void main() {
  runApp(const ListaCombos());
}

class ListaCombos extends StatelessWidget {
  const ListaCombos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Lista(),
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
  // Lista de combos simulada
  List<Map<String, dynamic>> combos = [];

  @override
  void initState() {
    super.initState();
    fetchCombos();
  }

  Future<void> fetchCombos() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/api/admin/getAllCombos'));
      if (response.statusCode == 200) {
        setState(() {
          combos = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        print('Error al cargar combos: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al cargar combos: $e');
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back,
                              color: Color.fromARGB(255, 255, 255, 255),
                              size: 30),
                        ),
                        const Text(
                          'Atras',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                      ],
                    ),
                    const Text(
                      'Combos',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 255, 255)),
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
              const SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: TextField(
                    controller: buscadorController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar Combos...',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (String value) {},
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Container(
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
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 65.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Registrocombos()),
                        );
                        fetchCombos();
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
                          Icon(EvaIcons.plusCircleOutline,
                              color: Color(0xffF5F5F5), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Nuevo Combo',
                            style: TextStyle(
                                color: Color(0xffF5F5F5), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
      itemCount: combos.length,
      itemBuilder: (context, index) {
        final combo = combos[index];
        return _buildTarjetaProducto(combo);
      },
    );
  }

  Widget _buildTarjetaProducto(Map<String, dynamic> combo) {
    final imagen = combo['imagen']?.toString() ?? '';
    final nombre = combo['nombre'] ?? '';
    final precio = (combo['precio'] as num?)?.toDouble() ?? 0.0;
    final productosIncluidos = combo['productos'] ?? [];
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Registrocombos(combo: combo),
          ),
        );
        fetchCombos();
      },
      child: Card(
        elevation: 5,
        color: const Color.fromARGB(255, 255, 255, 255),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color.fromARGB(255, 0, 0, 0),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Imagen del producto
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imagen,
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        size: 60,
                        color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 8),
                // Nombre del producto
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
                // Precio del producto
                Text(
                  'Precio: \$${precio.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Incluye:',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ...productosIncluidos.map((prod) => Text(
                      '- ${prod['nombre']} x${prod['cantidad']}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
