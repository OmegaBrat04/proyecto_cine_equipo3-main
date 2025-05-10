import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_cine_equipo3/Controlador/Administracion/consumible_controller.dart';
import 'package:proyecto_cine_equipo3/Modelo/ModeloConsumible.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/Consumibles.dart';
import 'dart:io';

import 'package:proyecto_cine_equipo3/Vistas/Services/Seleccion.dart';

void main() {
  runApp(const Registroconsumibles());
}

class Registroconsumibles extends StatelessWidget {
  const Registroconsumibles({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RegistroConsumiblesView(),
    );
  }
}

class RegistroConsumiblesView extends StatefulWidget {
  final Consumible? consumibleExistente;

  const RegistroConsumiblesView({super.key, this.consumibleExistente});

  @override
  State<RegistroConsumiblesView> createState() =>
      _RegistroConsumiblesViewState();
}

class _RegistroConsumiblesViewState extends State<RegistroConsumiblesView> {
  late TextEditingController nombreController;
  late TextEditingController proveedorController;
  late TextEditingController stockController;
  late TextEditingController precioUnitarioController;
  late bool esEdicion;

  @override
  void initState() {
    super.initState();
    final c = widget.consumibleExistente;
    if (c != null) {
      dropdownValue =
          c.unidad ?? 'U'; // ← Usa la unidad del consumible si existe
    }

    nombreController = TextEditingController(text: c?.nombre ?? '');
    proveedorController = TextEditingController(text: c?.proveedor ?? '');
    stockController = TextEditingController(text: c?.stock.toString() ?? '');
    precioUnitarioController =
        TextEditingController(text: c?.precioUnitario.toString() ?? '');

    esEdicion = c != null;
  }

  File? _imagen;
  String dropdownValue = 'U';

  //List<String> _items = ["FEMSA", "SABRITAS", "VERDEVALLE"];
  String proveedor = '';

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

  Future<void> _seleccionarProveedores() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/api/admin/getProveedores'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<String> proveedores =
            data.map((e) => e['nombre'].toString()).toList();

        final String seleccionado = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return Seleccion(
              items: proveedores,
              titulo: 'Selecciona un proveedor',
            );
          },
        );

        if (seleccionado != null) {
          setState(() {
            proveedor = seleccionado;
            proveedorController.text = proveedor;
          });
        }
      } else {
        throw Exception('Error al obtener proveedores');
      }
    } catch (e) {
      print('❌ Error al cargar proveedores: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al cargar proveedores: $e'),
          backgroundColor: Colors.red,
        ),
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
        child: Column(
          children: [
            const Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: Text(
                    'Registro de Consumibles',
                    style: TextStyle(
                      color: const Color(0xffF5F5F5),
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
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Consumibles()),
                                      );
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
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    //mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _imagen != null
                                          ? Image.file(
                                              _imagen!,
                                              width: 130,
                                              height: 180,
                                              fit: BoxFit.contain,
                                            )
                                          : (widget.consumibleExistente
                                                          ?.imagen !=
                                                      null &&
                                                  widget.consumibleExistente!
                                                      .imagen!
                                                      .startsWith('http'))
                                              ? Image.network(
                                                  widget.consumibleExistente!
                                                      .imagen!,
                                                  width: 130,
                                                  height: 180,
                                                  fit: BoxFit.contain,
                                                )
                                              : Container(
                                                  width: 130,
                                                  height: 180,
                                                  color: Colors.grey[300],
                                                  child: const Icon(Icons.image,
                                                      size: 100,
                                                      color: Colors.grey),
                                                ),
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        height: 40,
                                        width: 130,
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
                                  const SizedBox(width: 30),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Nombre',
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
                                          borderRadius:
                                              BorderRadius.circular(5),
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
                                      const SizedBox(height: 50),
                                      const Text(
                                        'Proveedor',
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
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: TextField(
                                          mouseCursor: SystemMouseCursors.click,
                                          onTap: () {
                                            _seleccionarProveedores();
                                          },
                                          readOnly: true,
                                          controller: proveedorController,
                                          decoration: const InputDecoration(
                                              hintText:
                                                  'Selecciona un proveedor',
                                              hintStyle: TextStyle(
                                                  color: Color(0xff000000),
                                                  fontSize: 14),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.only(
                                                  left: 10, bottom: 10),
                                              prefixIcon:
                                                  Icon(Icons.people_alt)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 40),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Stock Inicial',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Container(
                                            width: 150,
                                            height: 35,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: TextField(
                                              cursorColor:
                                                  const Color(0xff000000),
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xff000000)),
                                              controller: stockController,
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.only(
                                                    left: 10, bottom: 10),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Container(
                                            padding: EdgeInsets.only(left: 10),
                                            width: 50,
                                            height: 35,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: DropdownButton<String>(
                                              items: <String>[
                                                'U',
                                                'Kg',
                                                'L',
                                              ].map((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                              onChanged: (String? value) {
                                                setState(() {
                                                  dropdownValue = value!;
                                                });
                                              },
                                              value: dropdownValue,
                                              icon: const Icon(
                                                  Icons.arrow_drop_down,
                                                  color: Colors.black),
                                              iconSize: 20,
                                              elevation: 16,
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              underline: Container(
                                                height: 0,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 50),
                                      const Text(
                                        'Precio Unitario',
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
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: TextField(
                                          cursorColor: const Color(0xff000000),
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xff000000)),
                                          controller: precioUnitarioController,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.only(
                                                left: 10, bottom: 10),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: SizedBox(
                          height: 40,
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () async {
                              String? imagePath;

                              if (_imagen != null) {
                                // Subir imagen si es nueva
                                final request = http.MultipartRequest(
                                  'POST',
                                  Uri.parse(
                                      'http://localhost:3000/api/admin/uploadImage'),
                                );
                                request.files.add(
                                    await http.MultipartFile.fromPath(
                                        'poster', _imagen!.path));

                                final response = await request.send();
                                final responseData =
                                    await response.stream.bytesToString();
                                final decoded = jsonDecode(responseData);

                                imagePath = decoded['imageUrl'];
                              } else if (widget.consumibleExistente?.imagen !=
                                  null) {
                                // Usar la imagen existente si no se selecciona una nueva
                                imagePath = widget.consumibleExistente!.imagen;
                              }

                              final nuevo = Consumible(
                                nombre: nombreController.text.trim(),
                                proveedor: proveedorController.text.trim(),
                                stock:
                                    int.tryParse(stockController.text.trim()) ??
                                        0,
                                precioUnitario: double.tryParse(
                                        precioUnitarioController.text.trim()) ??
                                    0,
                                imagen: imagePath,
                              );

                              final exito = await ConsumibleController()
                                  .guardarConsumible(
                                context,
                                nuevo,
                                esEdicion: esEdicion,
                              );

                              if (exito && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(esEdicion
                                          ? '✅ Consumible actualizado'
                                          : '✅ Consumible agregado')),
                                );
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              backgroundColor: const Color(0xff14AE5C),
                            ),
                            child: const Text(
                              'Guardar Consumible',
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
