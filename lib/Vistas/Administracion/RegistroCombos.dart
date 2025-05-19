import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:proyecto_cine_equipo3/Vistas/Services/SeleccionconTarjetas.dart';

void main() {
  runApp(const Registrocombos());
}

class Registrocombos extends StatelessWidget {
  final Map<String, dynamic>? combo;
  const Registrocombos({Key? key, this.combo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: formulario(combo: combo),
    );
  }
}

class formulario extends StatefulWidget {
  final Map<String, dynamic>? combo;
  const formulario({Key? key, this.combo}) : super(key: key);

  @override
  _formularioState createState() => _formularioState();
}

class _formularioState extends State<formulario> {
  final productosController = TextEditingController();
  final nombreController = TextEditingController();
  final stockController = TextEditingController();
  final precioSugController = TextEditingController();
  final cConsumiblesController = TextEditingController();
  File? _imagen;
  String? _imagenUrl;
  String dropdownValue = 'U';
  int cantidad = 0;

  List<Map<String, dynamic>> _productos = [];
  List<Map<String, dynamic>> _productosSeleccionados = [];

  Future<void> _seleccionarImagen() async {
    final imgSeleccionada =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (imgSeleccionada != null) {
        _imagen = File(imgSeleccionada.path);
      } else {
        Exception('No image selected.');
      }
    });
  }

  @override
void initState() {
  super.initState();
  print(widget.combo);
  fetchProductos().then((_) {
    if (widget.combo != null) {
      nombreController.text = widget.combo!['nombre'] ?? '';
      precioSugController.text =
          (widget.combo!['precio'] as num?)?.toStringAsFixed(2) ?? '';
      _productosSeleccionados =
          List<Map<String, dynamic>>.from(widget.combo!['productos'] ?? []);
      _imagenUrl = widget.combo!['imagen']?.toString();
      setState(() {});
    }
  });
}

  Future<void> fetchProductos() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/api/admin/getAllProductos'));
      if (response.statusCode == 200) {
        setState(() {
          _productos =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        print('Error al cargar productos: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al cargar productos: $e');
    }
  }

  Future<String?> subirImagen(File imagen) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:3000/api/admin/uploadImage'),
    );
    request.files.add(await http.MultipartFile.fromPath('poster', imagen.path));
    final response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final respJson = jsonDecode(respStr);
      return respJson['imageUrl'];
    }
    return null;
  }

  Future<void> _seleccionarProductos() async {
    final List<Map<String, dynamic>> seleccionados = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectCardDialog(
          items: _productos,
          initialSelectedItems: _productosSeleccionados,
          titulo: 'Seleccione los productos para el combo',
        );
      },
    );
    if (seleccionados != null) {
      setState(() {
        _productosSeleccionados = seleccionados.map((p) {
          return {
            ...p,
            'cantidad': p['cantidad'] ?? 1,
          };
        }).toList();

        // Sumar precios de los productos seleccionados
        double suma = 0.0;
        for (final p in _productosSeleccionados) {
          final precio = (p['precio'] as num?)?.toDouble() ?? 0.0;
          final cantidad = (p['cantidad'] as int?) ?? 1;
          suma += precio * cantidad;
        }
        precioSugController.text = suma.toStringAsFixed(2);
      });
    }
  }

  void _agregarProducto(Map<String, String> producto) {
    setState(() {
      if (!_productosSeleccionados
          .any((p) => p['nombre'] == producto['nombre'])) {
        _productosSeleccionados.add({
          ...producto,
          'cantidad': 1,
        });
      }
    });
  }

  void actualizarPrecioSugerido() {
    double suma = 0.0;
    for (final p in _productosSeleccionados) {
      final precio = (p['precio'] as num?)?.toDouble() ?? 0.0;
      final cantidad = (p['cantidad'] as int?) ?? 1;
      suma += precio * cantidad;
    }
    precioSugController.text = suma.toStringAsFixed(2);
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
        child: Column(
          children: [
            const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Center(
                  child: Text(
                    'Registro de Combos',
                    style: TextStyle(
                      color: Color(0xffF5F5F5),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            const SizedBox(height: 20),
            Center(
              child: SingleChildScrollView(
                child: Container(
                  width: 750,
                  height: 550,
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
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Row(
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
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        size: 30),
                                  ),
                                  const Text(
                                    'Atras',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255)),
                                  ),
                                ],
                              ),
                              CircleAvatar(
                                radius: 30,
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
                          const SizedBox(height: 50),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  //mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 20),
                                    (_imagenUrl != null &&
                                            _imagenUrl!.isNotEmpty)
                                        ? Image.network(
                                            _imagenUrl!,
                                            width: 170,
                                            height: 220,
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                const Icon(Icons.broken_image,
                                                    size: 100,
                                                    color: Colors.grey),
                                          )
                                        : Container(
                                            width: 170,
                                            height: 220,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.image,
                                                size: 100, color: Colors.grey),
                                          ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      height: 40,
                                      width: 175,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _seleccionarImagen();
                                        },
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            backgroundColor:
                                                const Color(0xff434343)),
                                        child: const Text(
                                          'Cargar Imagen',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xffF5F5F5)),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Nombre del Combo',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      width: 200,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: TextField(
                                        cursorColor: const Color(0xff000000),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff000000)),
                                        controller: nombreController,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                              left: 10, bottom: 10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Precio sugerido',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      width: 200,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: TextField(
                                        //readOnly: true,
                                        cursorColor: const Color(0xff000000),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff000000)),
                                        controller: precioSugController,
                                        decoration: const InputDecoration(
                                          prefixIcon: Icon(Icons.attach_money),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                              left: 10, bottom: 10),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Productos a añadir',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      width: 250,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: TextField(
                                        mouseCursor: SystemMouseCursors.click,
                                        onTap: () {
                                          _seleccionarProductos();
                                        },
                                        readOnly: true,
                                        controller: productosController,
                                        decoration: const InputDecoration(
                                            hintText:
                                                'Selecciona los productos',
                                            hintStyle: TextStyle(
                                                color: Color(0xff000000),
                                                fontSize: 14),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.only(
                                                left: 10, bottom: 10),
                                            prefixIcon: Icon(Icons.search)),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Lista de Productos',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      width: 250,
                                      height: 235,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: _productosSeleccionados
                                              .map((producto) => ListTile(
                                                    title: Text(
                                                      producto["nombre"]?? '',
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    trailing: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        IconButton(
                                                          icon: const Icon(
                                                              Icons.remove,
                                                              color:
                                                                  Colors.black,
                                                              size: 20),
                                                          onPressed: () {
                                                            setState(() {
                                                              if (producto[
                                                                      'cantidad'] >
                                                                  1) {
                                                                producto[
                                                                        'cantidad'] =
                                                                    producto[
                                                                            'cantidad'] -
                                                                        1;
                                                                actualizarPrecioSugerido();
                                                              }
                                                            });
                                                          },
                                                        ),
                                                        const SizedBox(
                                                            width: 5),
                                                        Text(
                                                          producto['cantidad']
                                                              .toString(),
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        const SizedBox(
                                                            width: 5),
                                                        IconButton(
                                                          icon: const Icon(
                                                              Icons.add,
                                                              color:
                                                                  Colors.black,
                                                              size: 20),
                                                          onPressed: () {
                                                            setState(() {
                                                              producto[
                                                                      'cantidad'] =
                                                                  producto[
                                                                          'cantidad'] +
                                                                      1;
                                                              actualizarPrecioSugerido();
                                                            });
                                                          },
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(
                                                              Icons.delete,
                                                              color: Colors.red,
                                                              size: 20),
                                                          onPressed: () {
                                                            setState(() {
                                                              _productosSeleccionados
                                                                  .remove(
                                                                      producto);
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ))
                                              .toList(),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: SizedBox(
                          height: 40,
                          width: 250,
                          child: ElevatedButton(
                            onPressed: () async {
                              String? imageUrl;
                              if (_imagen != null) {
                                final url = await subirImagen(_imagen!);
                                if (url != null) _imagenUrl = url;
                              }
                              final List<Map<String, dynamic>> productosCombo =
                                  _productosSeleccionados
                                      .map((p) => {
                                            'idProducto': p['idProducto'],
                                            'cantidad': p['cantidad'],
                                          })
                                      .toList();

                              final data = {
                                'idCombo': widget.combo?['idCombo'],
                                'nombre': nombreController.text,
                                'precio':
                                    double.tryParse(precioSugController.text) ??
                                        0.0,
                                'imagen':
                                    imageUrl ?? (widget.combo?['imagen'] ?? ''),
                                'productos': productosCombo,
                              };

                              if (widget.combo?['idCombo'] != null) {
                                // EDICIÓN
                                final resp = await http.put(
                                  Uri.parse(
                                      'http://localhost:3000/api/admin/updateCombo/${widget.combo!['idCombo']}'),
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode(data),
                                );
                                if (resp.statusCode == 200) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              '✅ Combo editado exitosamente')),
                                    );
                                    Navigator.pop(context);
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('❌ Error al editar combo')),
                                  );
                                }
                              } else {
                                // CREACIÓN
                                final resp = await http.post(
                                  Uri.parse(
                                      'http://localhost:3000/api/admin/addCombo'),
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode(data),
                                );
                                if (resp.statusCode == 201) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              '✅ Combo guardado exitosamente')),
                                    );
                                    Navigator.pop(context);
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('❌ Error al guardar combo')),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              backgroundColor: const Color(0xff14AE5C),
                            ),
                            child: const Text(
                              'Guardar Combo',
                              style: TextStyle(color: Color(0xffF5F5F5)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
