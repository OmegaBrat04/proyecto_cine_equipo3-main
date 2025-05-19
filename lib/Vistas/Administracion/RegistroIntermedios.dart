import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/ListaIntermedio.dart';
import 'dart:io';

import 'package:proyecto_cine_equipo3/Vistas/Services/Multiseleccion.dart';

void main() {
  runApp(const Registrointermedios());
}

class Registrointermedios extends StatelessWidget {
  const Registrointermedios({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: formulario(),
      ),
    );
  }
}

class Consumible {
  final int id;
  final String nombre;
  final String unidad;
  final double precioUnitario;
  final int stock;

  Consumible({
    required this.id,
    required this.nombre,
    required this.unidad,
    required this.precioUnitario,
    required this.stock,
  });

  factory Consumible.fromJson(Map<String, dynamic> json) {
    return Consumible(
      id: json['id'],
      nombre: json['nombre'],
      unidad: json['unidad'],
      precioUnitario: (json['precio_unitario'] as num).toDouble(),
      stock: json['stock'],
    );
  }
}

class ConsumibleUsado {
  final String nombre;
  final double cantidadUsada;

  ConsumibleUsado({required this.nombre, required this.cantidadUsada});

  factory ConsumibleUsado.fromJson(Map<String, dynamic> json) {
    return ConsumibleUsado(
      nombre: json['nombre'],
      cantidadUsada: (json['cantidad'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Intermedio {
  final int id;
  final String nombre;
  final String? imagen;
  final double cantidadProducida;
  final String unidad;
  final double costoTotalEstimado;
  final List<ConsumibleUsado> consumibles;

  Intermedio({
    required this.id,
    required this.nombre,
    required this.imagen,
    required this.cantidadProducida,
    required this.unidad,
    required this.costoTotalEstimado,
    required this.consumibles,
  });

  factory Intermedio.fromJson(Map<String, dynamic> json) {
    var listaConsumibles = (json['consumibles'] as List)
        .map((item) => ConsumibleUsado.fromJson(item))
        .toList();

    return Intermedio(
      id: json['id'],
      nombre: json['nombre'],
      imagen: json['imagen'],
      cantidadProducida:
          (json['cantidad_producida'] as num?)?.toDouble() ?? 0.0,
      unidad: json['unidad'],
      costoTotalEstimado:
          (json['costo_total_estimado'] as num?)?.toDouble() ?? 0.0,
      consumibles: listaConsumibles,
    );
  }
}

class formulario extends StatefulWidget {
  const formulario({super.key});

  @override
  _formularioState createState() => _formularioState();
}

class _formularioState extends State<formulario> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController costoController = TextEditingController();
  final TextEditingController recetasController = TextEditingController();
  String porcionBaseUnidad = 'U';

  File? _imagen;
  String dropdownValue = 'U';
  String? _imagenUrl;

  List<Map<String, dynamic>> recetas = [];
  int? recetaSeleccionadaId;
  List<Map<String, dynamic>> consumiblesDeReceta = [];
  double porcionBase = 1.0;

  Future<void> fetchRecetas() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/api/admin/getRecetas'));
    if (response.statusCode == 200) {
      recetas = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      setState(() {});
    }
  }

  void onRecetaSeleccionada(int recetaId) async {
    final receta = recetas.firstWhere((r) => r['id'] == recetaId);
    consumiblesDeReceta =
        List<Map<String, dynamic>>.from(receta['ingredientes']);
    setState(() {
      recetaSeleccionadaId = recetaId;
      porcionBaseUnidad = receta['unidadPorcion'] ?? 'U';
    });
  }

//controller
  @override
  void initState() {
    super.initState();
    fetchRecetas();
  }

  final List<String> _unidades = ['U', 'Kg', 'L'];

  final Map<String, TextEditingController> _consumiblesSeleccionados = {};

  Future<void> _seleccionarImagen() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagenSeleccionada =
        await picker.pickImage(source: ImageSource.gallery);
    if (imagenSeleccionada == null) return;

    setState(() {
      _imagen = File(imagenSeleccionada.path);
    });

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:3000/api/admin/uploadImage'),
    );

    request.files
        .add(await http.MultipartFile.fromPath('poster', _imagen!.path));
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final imageUrl = jsonDecode(responseBody)['imageUrl'];

      setState(() {
        _imagenUrl = imageUrl;
      });

      print("✅ Imagen subida: $_imagenUrl");
    } else {
      print("❌ Error al subir imagen: ${response.statusCode}");
    }
  }

  void _calcularCostoTotal() {
    double total = 0.0;
    for (final c in consumiblesDeReceta) {
      final cantidad = (c['cantidad'] as num?)?.toDouble() ?? 0.0;
      final precio = (c['precio_unitario'] as num?)?.toDouble() ?? 0.0;
      total += cantidad * precio;
    }

    final double cantidadProducida =
        double.tryParse(stockController.text) ?? porcionBase;
    // CONVIERTE LA CANTIDAD PRODUCIDA A LA UNIDAD BASE DE LA RECETA
    final double cantidadProducidaNormalizada = convertirUnidad(
        cantidadProducida,
        mapDropdownToUnidad(dropdownValue, porcionBaseUnidad), // <-- aquí
        porcionBaseUnidad);
    if (cantidadProducidaNormalizada == -1) {
      setState(() {
        costoController.text = '';
      });
      return;
    }
    final double factor =
        porcionBase > 0 ? (cantidadProducidaNormalizada / porcionBase) : 1.0;
    final double costoFinal = total * factor;

    setState(() {
      costoController.text = costoFinal.toStringAsFixed(2);
    });
  }

  void _guardarIntermedio() async {
    if (nombreController.text.isEmpty ||
        stockController.text.isEmpty ||
        costoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Todos los campos deben estar completos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final ok = await validarYActualizarStock();
    if (!ok) return;
    final double? stock = double.tryParse(stockController.text);
    final double? costo = double.tryParse(costoController.text);
    if (stock == null || costo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Valores numéricos inválidos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Map<String, dynamic> body = {
      'nombre': nombreController.text,
      'imagen': _imagenUrl ?? '',
      'cantidad_producida': stock,
      'unidad': dropdownValue,
      'costo_total_estimado': costo,
      'receta_id': recetaSeleccionadaId,
    };

    final response = await http.post(
      Uri.parse('http://localhost:3000/api/admin/addIntermedio'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 201) {
      await descontarStockConsumibles();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Intermedio guardado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Error al guardar intermedio'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> validarYActualizarStock() async {
    for (final c in consumiblesDeReceta) {
      final int consumibleId = c['idConsumible'] ?? c['id'] ?? 0;
      final double cantidadBase = (c['cantidad'] as num?)?.toDouble() ?? 0.0;
      final double cantidadProducida =
          double.tryParse(stockController.text) ?? porcionBase;
      final double cantidadProducidaNormalizada = convertirUnidad(
          cantidadProducida,
          dropdownValue, // U, Kg, L
          porcionBaseUnidad // gr, ml, etc
          );
      if (cantidadProducidaNormalizada == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Unidad incompatible con la receta'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
      final double factor =
          porcionBase > 0 ? (cantidadProducidaNormalizada / porcionBase) : 1.0;
      final double cantidadNecesaria = cantidadBase * factor;
      final response = await http.get(Uri.parse(
          'http://localhost:3000/api/admin/getConsumible/$consumibleId'));
      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('❌ Error al consultar stock de ${c['nombre']}')),
        );
        return false;
      }
      final data = jsonDecode(response.body);
      final double stockActual = (data['stock'] as num?)?.toDouble() ?? 0.0;

      if (stockActual < cantidadNecesaria) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '❌ Stock insuficiente para "${c['nombre']}". Disponible: $stockActual, requerido: $cantidadNecesaria'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> descontarStockConsumibles() async {
    for (final c in consumiblesDeReceta) {
      final int consumibleId = c['idConsumible'] ?? c['id'] ?? 0;
      final double cantidadBase = (c['cantidad'] as num?)?.toDouble() ?? 0.0;
      final double cantidadProducida =
          double.tryParse(stockController.text) ?? porcionBase;
      final double factor =
          porcionBase > 0 ? (cantidadProducida / porcionBase) : 1.0;
      final double cantidadDescontar = cantidadBase * factor;

      await http.put(
        Uri.parse(
            'http://localhost:3000/api/admin/descontarStock/$consumibleId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'cantidad': cantidadDescontar}),
      );
    }
  }

  String mapDropdownToUnidad(String dropdownValue, String unidadReceta) {
    dropdownValue = dropdownValue.toLowerCase();
    unidadReceta = unidadReceta.toLowerCase();
    if (dropdownValue == 'kg' && (unidadReceta == 'gr' || unidadReceta == 'kg'))
      return 'kg';
    if (dropdownValue == 'l' && (unidadReceta == 'ml' || unidadReceta == 'l'))
      return 'l';
    if (dropdownValue == 'u' && unidadReceta == 'u') return 'u';
    return dropdownValue;
  }

  double convertirUnidad(
      double cantidad, String unidadOrigen, String unidadDestino) {
    unidadOrigen = unidadOrigen.toLowerCase();
    unidadDestino = unidadDestino.toLowerCase();

    // Peso
    if ((unidadOrigen == 'gr' || unidadOrigen == 'kg') &&
        (unidadDestino == 'gr' || unidadDestino == 'kg')) {
      if (unidadOrigen == unidadDestino) return cantidad;
      if (unidadOrigen == 'gr' && unidadDestino == 'kg') return cantidad / 1000;
      if (unidadOrigen == 'kg' && unidadDestino == 'gr') return cantidad * 1000;
    }
    // Volumen
    if ((unidadOrigen == 'ml' || unidadOrigen == 'l') &&
        (unidadDestino == 'ml' || unidadDestino == 'l')) {
      if (unidadOrigen == unidadDestino) return cantidad;
      if (unidadOrigen == 'ml' && unidadDestino == 'l') return cantidad / 1000;
      if (unidadOrigen == 'l' && unidadDestino == 'ml') return cantidad * 1000;
    }
    // Unidades
    if (unidadOrigen == 'u' && unidadDestino == 'u') return cantidad;

    // Incompatibles
    return -1; // Señal de incompatibilidad
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
                    'Registro de Intermedios',
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
                          //_seleccionarImagen
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
                                                const ListaIntermedios()),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  //mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Nombre del Intermedio',
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
                                        controller: nombreController,
                                        cursorColor: Colors.black,
                                        style: const TextStyle(
                                            color: Colors.black),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                              left: 10, bottom: 10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    const Text(
                                      'Receta a usar',
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
                                      child:
                                          RawAutocomplete<Map<String, dynamic>>(
                                        textEditingController:
                                            recetasController,
                                        focusNode: FocusNode(),
                                        optionsBuilder: (TextEditingValue
                                            textEditingValue) {
                                          final input = textEditingValue.text
                                              .toLowerCase();
                                          if (input.isEmpty)
                                            return const Iterable.empty();
                                          return recetas.where((r) =>
                                              (r['nombre'] ?? '')
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains(input));
                                        },
                                        displayStringForOption: (r) =>
                                            r['nombre'] ?? '',
                                        onSelected: (r) {
                                          setState(() {
                                            recetaSeleccionadaId = r['id'];
                                            recetasController.text =
                                                r['nombre'] ?? '';
                                            consumiblesDeReceta =
                                                List<Map<String, dynamic>>.from(
                                                    r['ingredientes']);
                                            porcionBase = (r['porcion'] as num?)
                                                    ?.toDouble() ??
                                                1.0;
                                            porcionBaseUnidad =
                                                r['unidadPorcion'] ?? 'U';
                                            _calcularCostoTotal();
                                          });
                                        },
                                        fieldViewBuilder: (context, controller,
                                            focusNode, onFieldSubmitted) {
                                          return Container(
                                            width: 250,
                                            height: 35,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: TextField(
                                              controller: controller,
                                              focusNode: focusNode,
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              decoration: const InputDecoration(
                                                prefixIcon: Icon(Icons.search),
                                                hintText: 'Buscar receta',
                                                hintStyle: TextStyle(
                                                    color: Colors.black54),
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.only(
                                                    left: 10, bottom: 10),
                                              ),
                                            ),
                                          );
                                        },
                                        optionsViewBuilder:
                                            (context, onSelected, options) {
                                          return Align(
                                            alignment: Alignment.topLeft,
                                            child: Material(
                                              elevation: 4,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: ConstrainedBox(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxHeight: 200,
                                                        maxWidth: 250),
                                                child: ListView.separated(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  shrinkWrap: true,
                                                  itemCount: options.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final r = options
                                                        .elementAt(index);
                                                    return ListTile(
                                                      title: Text(r['nombre']),
                                                      onTap: () =>
                                                          onSelected(r),
                                                    );
                                                  },
                                                  separatorBuilder: (_, __) =>
                                                      const Divider(height: 1),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Lista de Ingredientes',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      width: 250,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: ListView.builder(
                                        itemCount: consumiblesDeReceta.length,
                                        itemBuilder: (context, index) {
                                          final c = consumiblesDeReceta[index];
                                          return ListTile(
                                            title: Text('${c['nombre']}',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            subtitle: Text(
                                                'Cantidad: ${c['cantidad']} ${c['unidad']}'),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Cantidad producida',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Container(
                                          width: 190,
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
                                            onChanged: (value) {
                                              _calcularCostoTotal();
                                            },
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
                                    const SizedBox(height: 20),
                                    Text(
                                      'Unidad base de la receta: $porcionBaseUnidad',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                    const SizedBox(height: 50),
                                    const Text(
                                      'Costo Total estimado',
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
                                        readOnly: true,
                                        cursorColor: const Color(0xff000000),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff000000)),
                                        controller: costoController,
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
                        ],
                      ),
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: SizedBox(
                          height: 40,
                          width: 200,
                          child: ElevatedButton(
                            onPressed: _guardarIntermedio,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              backgroundColor: const Color(0xff14AE5C),
                            ),
                            child: const Text('Guardar Intermedio',
                                style: TextStyle(color: Color(0xffF5F5F5))),
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
