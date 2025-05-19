import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import 'package:proyecto_cine_equipo3/Vistas/Administracion/ListaProductos.dart';

void main() {
  runApp(const Registroproductos());
}

class Registroproductos extends StatelessWidget {
  const Registroproductos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: formulario(),
    );
  }
}

class BusquedaDesplegable extends StatefulWidget {
  final String label;
  final List<dynamic> items;
  final Function(Map<String, dynamic>) onItemSelected;
  final TextEditingController controller;

  const BusquedaDesplegable({
    super.key,
    required this.label,
    required this.items,
    required this.onItemSelected,
    required this.controller,
  });

  @override
  State<BusquedaDesplegable> createState() => _BusquedaDesplegableState();
}

class _BusquedaDesplegableState extends State<BusquedaDesplegable> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _showOverlay = false;
  List<dynamic> _filteredItems = [];
  //final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    /* _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _removeOverlay();
      }
    });*/
  }

  void _updateOverlay() {
    _overlayEntry?.markNeedsBuild();
  }

  void _toggleOverlay() {
    if (_showOverlay) {
      _removeOverlay();
    } else {
      _filteredItems = _filterItems(widget.controller.text);
      _insertOverlay();
    }
  }

  List<dynamic> _filterItems(String value) {
    return widget.items
        .where((item) => item['nombre']
            .toString()
            .toLowerCase()
            .contains(value.toLowerCase()))
        .take(5)
        .toList();
  }

  void _insertOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 5),
            child: Material(
              elevation: 5,
              child: Container(
                color: Colors.white,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    return ListTile(
                      title: Text(item['nombre']),
                      onTap: () {
                        _removeOverlay();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          widget.onItemSelected(item);
                          widget.controller.clear();
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    _showOverlay = true;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _showOverlay = false;
  }

  @override
  void dispose() {
    // _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        //focusNode: _focusNode,
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: widget.label,
          prefixIcon: Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: (value) {
          setState(() {
            _filteredItems = _filterItems(value);
            if (!_showOverlay) {
              _insertOverlay();
            } else {
              _updateOverlay();
            }
          });
        },
        onTap: () {
          if (!_showOverlay) {
            setState(() {
              _filteredItems = _filterItems(widget.controller.text);
              _insertOverlay();
            });
          }
        },
      ),
    );
  }
}

class Consumible {
  final String nombre;

  Consumible({required this.nombre});

  factory Consumible.fromJson(Map<String, dynamic> json) {
    return Consumible(
      nombre: json['nombre'],
    );
  }
}

class formulario extends StatefulWidget {
  const formulario({super.key});

  @override
  _formularioState createState() => _formularioState();
}

class _formularioState extends State<formulario> {
  final consumiblesController = TextEditingController();
  final intermediosController = TextEditingController();
  final nombreController = TextEditingController();
  final stockController = TextEditingController();
  final precioUController = TextEditingController();
  final cPorcioncontroller = TextEditingController();
  File? _imagen;
  String dropdownValue = 'U';
  String dropdownValue2 = 'gr';
  String? dropdownValue3;
  final Map<String, TextEditingController> _cantidadControllersConsumibles = {};
  final Map<String, String> _unidadSeleccionadaConsumibles = {};

  final Map<String, TextEditingController> _cantidadControllersIntermedios = {};
  final Map<String, String> _unidadSeleccionadaIntermedios = {};

  Future<void> _guardarProducto() async {
    final List<Map<String, dynamic>> insumos = [];
    for (final consumible in _consumiblesSeleccionados) {
      final cantidad = double.tryParse(
              _cantidadControllersConsumibles[consumible['nombre']]?.text ??
                  '0') ??
          0;
      if (cantidad <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Ingresa una cantidad válida para "${consumible['nombre']}"')),
        );
        return;
      }
    }
    for (final intermedio in _intermediosSeleccionados) {
      final cantidad = double.tryParse(
              _cantidadControllersIntermedios[intermedio['nombre']]?.text ??
                  '0') ??
          0;
      if (cantidad <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Ingresa una cantidad válida para "${intermedio['nombre']}"')),
        );
        return;
      }
    }
    final int stockProducto = int.tryParse(stockController.text) ?? 0;
    for (final consumible in _consumiblesSeleccionados) {
      final cantidadPorProducto = double.tryParse(
              _cantidadControllersConsumibles[consumible['nombre']]?.text ??
                  '0') ??
          0;
      final cantidadTotal = cantidadPorProducto * stockProducto;
      insumos.add({
        'nombre': consumible['nombre'],
        'cantidad': cantidadTotal,
        'unidad': _unidadSeleccionadaConsumibles[consumible['nombre']] ??
            consumible['unidad'],
        'tipo': 'consumible',
      });
    }
    for (final intermedio in _intermediosSeleccionados) {
      final cantidadPorProducto = double.tryParse(
              _cantidadControllersIntermedios[intermedio['nombre']]?.text ??
                  '0') ??
          0;
      final cantidadTotal = cantidadPorProducto * stockProducto;
      insumos.add({
        'nombre': intermedio['nombre'],
        'cantidad': cantidadTotal,
        'unidad': _unidadSeleccionadaIntermedios[intermedio['nombre']] ??
            intermedio['unidad'],
        'tipo': 'intermedio',
      });
    }
    String? imageUrl;
    if (_imagen != null) {
      imageUrl = await subirImagen(_imagen!);
    }
    final Map<String, dynamic> data = {
      'nombre': nombreController.text,
      'tamano': dropdownValue3,
      'porcionCantidad': double.tryParse(cPorcioncontroller.text) ?? 0.0,
      'porcionUnidad': dropdownValue2,
      'stock': int.tryParse(stockController.text) ?? 0,
      'precio': double.tryParse(precioUController.text) ?? 0.0,
      'imagen': imageUrl ?? '',
      'insumos': insumos,
    };

    final uri = Uri.parse('http://localhost:3000/api/admin/addProducto');
    try {
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (resp.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Producto guardado')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ListaProductos()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${resp.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exception: $e')),
      );
    }
  }

  bool _esUnidadCompatible(String seleccionada, String real) {
    seleccionada = seleccionada.toLowerCase();
    real = real.toLowerCase();
    if (seleccionada == real) return true;
    if ((seleccionada == 'kg' && real == 'gr') ||
        (seleccionada == 'gr' && real == 'kg')) return true;
    if ((seleccionada == 'l' && real == 'ml') ||
        (seleccionada == 'ml' && real == 'l')) return true;
    if (seleccionada == 'u' && real == 'u') return true;
    return false;
  }

  List<Map<String, dynamic>> _consumiblesSeleccionados = [];
  List<Map<String, dynamic>> _intermediosSeleccionados = [];
  List<dynamic> intermedios = [];
  final TextEditingController buscadorIntermediosController =
      TextEditingController();

  List<dynamic> consumibles = [];
  final TextEditingController buscadorConsumiblesController =
      TextEditingController();

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      fetchConsumibles();
      fetchIntermedios();
      _initialized = true;
    }
  }
//_insertOverlay

  Widget _buildDropdownTamanio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seleccionar Tamaño',
          style: TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Container(
          width: 250,
          height: 35,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5)),
          child: DropdownButton<String>(
            isExpanded: true,
            value: dropdownValue3,
            hint: const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text('Selecciona un tamaño',
                  style: TextStyle(color: Colors.black, fontSize: 14)),
            ),
            items:
                ['PEQUEÑO', 'MEDIANAS', 'GRANDES', 'JUMBO'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(value)),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() => dropdownValue3 = value);
            },
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
            iconSize: 20,
            elevation: 16,
            underline: Container(height: 0),
          ),
        ),
      ],
    );
  }

  Widget _buildPorcion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tamaño de la Porción',
          style: TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Container(
              width: 190,
              height: 35,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(5)),
              child: TextField(
                controller: cPorcioncontroller,
                cursorColor: Colors.black,
                style: const TextStyle(fontSize: 14, color: Colors.black),
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 10, bottom: 10)),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 50,
              height: 35,
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(5)),
              child: DropdownButton<String>(
                value: dropdownValue2,
                isExpanded: true,
                items: ['gr', 'kg', 'ml', 'L'].map((String value) {
                  return DropdownMenuItem<String>(
                      value: value, child: Text(value));
                }).toList(),
                onChanged: (String? value) {
                  setState(() => dropdownValue2 = value!);
                },
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                iconSize: 20,
                underline: Container(height: 0),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildCampo(String label, TextEditingController controller,
      {IconData? prefixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          width: 250,
          height: 35,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5)),
          child: TextField(
            controller: controller,
            cursorColor: Colors.black,
            style: const TextStyle(fontSize: 14, color: Colors.black),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(left: 10, bottom: 10),
              prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeleccionados(
      List<Map<String, dynamic>> lista, bool esConsumible) {
    final cantidadControllers = esConsumible
        ? _cantidadControllersConsumibles
        : _cantidadControllersIntermedios;
    final unidadSeleccionada = esConsumible
        ? _unidadSeleccionadaConsumibles
        : _unidadSeleccionadaIntermedios;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          esConsumible
              ? 'Consumibles Seleccionados'
              : 'Intermedios Seleccionados',
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Container(
          width: 250,
          height: 100,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5)),
          child: SingleChildScrollView(
            child: Column(
              children: lista.map((item) {
                cantidadControllers.putIfAbsent(
                    item['nombre'], () => TextEditingController());
                unidadSeleccionada.putIfAbsent(
                    item['nombre'], () => item['unidad'] ?? 'U');
                return ListTile(
                  title: Text(item['nombre'],
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  subtitle: Text('Unidad base: ${item['unidad'] ?? ''}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 35,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: TextField(
                          controller: cantidadControllers[item['nombre']],
                          cursorColor: Colors.black,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.only(left: 10, bottom: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      DropdownButton<String>(
                        value: unidadSeleccionada[item['nombre']],
                        items: ['U', 'Kg', 'gr', 'L', 'ml']
                            .map((u) => DropdownMenuItem(
                                  value: u,
                                  child: Text(u),
                                ))
                            .toList(),
                        onChanged: (val) {
                          final unidadReal = item['unidad'] ?? 'U';
                          final compatible =
                              _esUnidadCompatible(val!, unidadReal);
                          if (!compatible) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Unidad incompatible con el insumo/intermedio')),
                            );
                          } else {
                            setState(() {
                              unidadSeleccionada[item['nombre']] = val!;
                            });
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red, size: 24),
                        onPressed: () {
                          setState(() {
                            lista.remove(item);
                            cantidadControllers.remove(item['nombre']);
                            unidadSeleccionada.remove(item['nombre']);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> fetchIntermedios() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/api/admin/getIntermedios'));
      if (response.statusCode == 200) {
        setState(() {
          intermedios = json.decode(response.body);
          //intermediosFiltrados = List.from(intermedios);
        });
      }
    } catch (e) {
      print('❌ Error al cargar intermedios: $e');
    }
  }

  Future<void> fetchConsumibles() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/api/admin/getConsumibles'));
      if (response.statusCode == 200) {
        setState(() {
          consumibles = json.decode(response.body);
          //consumiblesFiltrados = List.from(consumibles);
        });
      }
    } catch (e) {
      print('❌ Error al cargar consumibles: $e');
    }
  }

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
                    'Registro de Productos',
                    style: TextStyle(
                      color: const Color(0xffF5F5F5),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            //_insertOverlay
            const SizedBox(height: 20),
            Center(
              child: SingleChildScrollView(
                child: Container(
                  width: 750,
                  height: 600,
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
                  child: ListView(
                    padding: EdgeInsets.zero,
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
                                    color: Colors.white, size: 30),
                              ),
                              const Text(
                                'Atras',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
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
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ⬅️ Imagen + cargador
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 80),
                                _imagen == null
                                    ? Container(
                                        width: 130,
                                        height: 180,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.image,
                                            size: 100, color: Colors.grey),
                                      )
                                    : Image.file(
                                        _imagen!,
                                        width: 130,
                                        height: 180,
                                        fit: BoxFit.contain,
                                      ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  height: 40,
                                  width: 130,
                                  child: ElevatedButton(
                                    onPressed: _seleccionarImagen,
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildCampo(
                                      'Nombre del Producto', nombreController),
                                  const SizedBox(height: 15),
                                  _buildDropdownTamanio(),
                                  const SizedBox(height: 15),
                                  _buildPorcion(),
                                  const SizedBox(height: 15),
                                  const Text(
                                    'Consumibles a usar',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  Builder(
                                    builder: (context) {
                                      return BusquedaDesplegable(
                                        label: 'Buscar consumible...',
                                        items: List.from(consumibles),
                                        controller:
                                            buscadorConsumiblesController,
                                        // Consumibles
                                        onItemSelected: (item) {
                                          setState(() {
                                            if (!_consumiblesSeleccionados.any(
                                                (c) =>
                                                    c['nombre'] ==
                                                    item['nombre'])) {
                                              _consumiblesSeleccionados.add(
                                                  item); // item es el objeto completo
                                            }
                                          });
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  _buildSeleccionados(
                                      _consumiblesSeleccionados, true),
                                ],
                              ),
                            ),

                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildCampo('Stock Inicial', stockController),
                                  const SizedBox(height: 15),
                                  _buildCampo(
                                      'Precio Unitario', precioUController,
                                      prefixIcon: Icons.attach_money),
                                  const SizedBox(height: 15),
                                  const Text(
                                    'Intermedios a usar',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  Builder(
                                    builder: (context) {
                                      return BusquedaDesplegable(
                                        label: 'Buscar intermedio...',
                                        items: List.from(intermedios),
                                        controller:
                                            buscadorIntermediosController,
                                        onItemSelected: (item) {
                                          setState(() {
                                            if (!_intermediosSeleccionados.any(
                                                (i) =>
                                                    i['nombre'] ==
                                                    item['nombre'])) {
                                              _intermediosSeleccionados
                                                  .add(item);
                                            }
                                          });
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  _buildSeleccionados(
                                      _intermediosSeleccionados, false),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: _guardarProducto,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff14AE5C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            fixedSize: const Size(200, 40),
                          ),
                          child: const Text(
                            'Guardar Producto',
                            style: TextStyle(color: Color(0xffF5F5F5)),
                          ),
                        ),
                      )
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
