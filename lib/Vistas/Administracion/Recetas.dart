import 'package:flutter/material.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/Menu.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const Recetas());
}

class Recetas extends StatelessWidget {
  const Recetas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Ventana(),
    );
  }
}

class Ventana extends StatefulWidget {
  const Ventana({super.key});

  @override
  State<Ventana> createState() => _VentanaState();
}

class Consumible {
  final int id;
  final String nombre;
  final String unidad;

  Consumible({required this.id, required this.nombre, required this.unidad});

  factory Consumible.fromJson(Map<String, dynamic> json) {
    return Consumible(
      id: json['id'] ?? -1,
      nombre: json['nombre'] ?? 'Sin Nombre',
      unidad: json['unidad'] ?? 'Sin Unidad',
    );
  }
}

class ConsumibleSeleccionado {
  final int id;
  final String nombre;
  final String unidad;
  double cantidad;

  ConsumibleSeleccionado({
    required this.id,
    required this.nombre,
    required this.unidad,
    this.cantidad = 0.0,
  });
}

class _VentanaState extends State<Ventana> {
  List<ConsumibleSeleccionado> seleccionados = [];
  List<Consumible> todosLosConsumibles = [];
  TextEditingController buscadorController = TextEditingController();
  TextEditingController nombreRecetaController = TextEditingController();
  TextEditingController cconsumiblesController = TextEditingController();
  TextEditingController porcionController = TextEditingController();
  String unidadSeleccionada = 'Gr';
  int? recetaEditandoId;
  String? recetaEditandoNombre;
  List<ConsumibleSeleccionado> ingredientesEditando = [];
  List<TextEditingController> cantidadControllers = [];

  @override
  void initState() {
    super.initState();
    cargarConsumibles();
    cargarRecetas();
  }

  List<dynamic> recetas = [];

  Future<void> cargarRecetas() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/api/admin/getRecetas'));
    if (response.statusCode == 200) {
      setState(() {
        recetas = jsonDecode(response.body);
      });
    }
  }

//onSelected
  Future<void> cargarConsumibles() async {
    final response = await http.get(
        Uri.parse('http://localhost:3000/api/admin/getConsumiblesParaReceta'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        todosLosConsumibles =
            (data as List).map((json) => Consumible.fromJson(json)).toList();
      });
    }
  }

  void sincronizarCantidadControllers() {
    for (var c in cantidadControllers) {
      c.dispose();
    }
    cantidadControllers = seleccionados
        .map((item) => TextEditingController(
            text: item.cantidad == 0.0 ? '' : item.cantidad.toString()))
        .toList();
  }

  Future<void> guardarReceta() async {
    final nombre = nombreRecetaController.text.trim();
    if (nombre.isEmpty || seleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Completa el nombre y agrega al menos un ingrediente')),
      );
      return;
    }

    // Prepara los ingredientes en el formato que espera el backend
    final ingredientes = seleccionados
        .map((c) => {
              'idConsumible': c.id,
              'cantidad': c.cantidad,
              'unidad': c.unidad,
            })
        .toList();

    final url = Uri.parse('http://localhost:3000/api/admin/addReceta');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'porcion': porcionController.text.trim(),
        'unidadPorcion': unidadSeleccionada,
        'ingredientes': ingredientes,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Receta guardada correctamente')),
      );
      // Limpia campos y seleccionados
      setState(() {
        nombreRecetaController.clear();
        seleccionados.clear();
      });
      //Navigator.pop(context);
      cargarRecetas();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '❌ Error al guardar receta: ${jsonDecode(response.body)['message']}')),
      );
    }
  }

  Future<void> editarReceta(int id) async {
    final nombre = nombreRecetaController.text.trim();
    if (nombre.isEmpty || seleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Completa el nombre y agrega al menos un ingrediente')),
      );
      return;
    }

    final ingredientes = seleccionados
        .map((c) => {
              'idConsumible': c.id,
              'cantidad': c.cantidad,
              'unidad': c.unidad,
            })
        .toList();

    final url = Uri.parse('http://localhost:3000/api/admin/updateReceta/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'porcion': porcionController.text.trim(),
        'unidadPorcion': unidadSeleccionada,
        'ingredientes': ingredientes,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Receta actualizada correctamente')),
      );
      setState(() {
        nombreRecetaController.clear();
        porcionController.clear();
        seleccionados.clear();
        for (var c in cantidadControllers) {
          c.dispose();
        }
        cantidadControllers.clear();
        recetaEditandoId = null;
      });
      Navigator.of(context).pop();
      cargarRecetas();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '❌ Error al actualizar receta: ${jsonDecode(response.body)['message']}')),
      );
    }
  }

  Widget buildRecetaDialog(BuildContext context, {bool isEdit = false}) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return AlertDialog(
          backgroundColor: const Color(0xff081C42),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Recetas',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: 750,
            height: 475,
            child: Column(
              children: [
                TextField(
                  controller: nombreRecetaController,
                  cursorColor: Colors.white,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la Receta',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    contentPadding: EdgeInsets.only(left: 10, bottom: 10),
                  ),
                ),
                const SizedBox(height: 20),
                Autocomplete<Consumible>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    return todosLosConsumibles
                        .where((c) => c.nombre
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()))
                        .toList();
                  },
                  displayStringForOption: (c) => c.nombre,
                  fieldViewBuilder:
                      (context, controller, focusNode, onEditingComplete) {
                    buscadorController = controller;
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Selecciona Ingredientes',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                      ),
                    );
                  },
                  onSelected: (Consumible seleccion) {
                    setModalState(() {
                      if (!seleccionados.any((e) => e.id == seleccion.id)) {
                        seleccionados.add(ConsumibleSeleccionado(
                          id: seleccion.id,
                          nombre: seleccion.nombre,
                          unidad: seleccion.unidad,
                        ));
                        cantidadControllers
                            .add(TextEditingController(text: ''));
                      }
                      buscadorController.clear();
                    });
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: porcionController,
                        cursorColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Porción de la Receta',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          contentPadding: EdgeInsets.only(left: 10, bottom: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: unidadSeleccionada,
                        dropdownColor: const Color(0xff081C42),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.white),
                        underline: const SizedBox(),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (String? newValue) {
                          setModalState(() {
                            unidadSeleccionada = newValue!;
                          });
                        },
                        items: <String>['Gr', 'Ml']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xff0A2440),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Consumibles Seleccionados:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: seleccionados.length,
                            itemBuilder: (context, index) {
                              final item = seleccionados[index];
                              final controller = cantidadControllers[index];
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item.nombre,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                  Row(
                                    children: [
                                      const Text('Cantidad:',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      const SizedBox(width: 5),
                                      SizedBox(
                                        width: 50,
                                        child: TextField(
                                          controller: controller,
                                          keyboardType: TextInputType.number,
                                          style: const TextStyle(
                                              color: Colors.white),
                                          onChanged: (val) {
                                            setModalState(() {
                                              item.cantidad =
                                                  double.tryParse(val) ?? 0.0;
                                            });
                                          },
                                          decoration: const InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 5),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(item.unidad,
                                          style: const TextStyle(
                                              color: Colors.white)),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () {
                                          setModalState(() {
                                            seleccionados.removeAt(index);
                                            cantidadControllers.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () async {
                      await guardarReceta();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      backgroundColor: const Color(0xff14AE5C),
                    ),
                    child: const Text('Guardar',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

//TextField
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Atras',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Recetas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
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
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  border: TableBorder.all(color: Colors.grey),
                  headingTextStyle: const TextStyle(color: Colors.white),
                  dataTextStyle: const TextStyle(color: Colors.white),
                  columns: const [
                    DataColumn(label: Text('Nombre de la Receta')),
                    DataColumn(
                        label:
                            SizedBox(width: 400, child: Text('Ingredientes'))),
                    DataColumn(label: Text('Porción')),
                    DataColumn(label: Text('Opciones')),
                  ],
                  rows: recetas.map<DataRow>((receta) {
                    final ingredientes =
                        receta['ingredientes'] as List<dynamic>;
                    final ingredientesStr =
                        ingredientes.map((i) => i['nombre']).join(', ');
                    return DataRow(
                      cells: [
                        DataCell(Text(receta['nombre'] ?? '')),
                        DataCell(Text(ingredientesStr)),
                        DataCell(Text(receta['porcion']?.toString() ?? '')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    recetaEditandoId = receta['id'];
                                    recetaEditandoNombre = receta['nombre'];
                                    seleccionados =
                                        (receta['ingredientes'] as List)
                                            .map((i) => ConsumibleSeleccionado(
                                                  id: i['idConsumible'],
                                                  nombre: i['nombre'],
                                                  unidad: i['unidad'],
                                                  cantidad:
                                                      (i['cantidad'] as num?)
                                                              ?.toDouble() ??
                                                          0.0,
                                                ))
                                            .toList();
                                    sincronizarCantidadControllers();
                                    nombreRecetaController.text =
                                        receta['nombre'] ?? '';
                                    porcionController.text =
                                        (receta['porcion'] ?? '').toString();
                                  });
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return buildRecetaDialog(context,
                                          isEdit: true);
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.white),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Eliminar receta'),
                                      content: const Text(
                                          '¿Estás seguro de eliminar esta receta?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text('Eliminar',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    final url = Uri.parse(
                                        'http://localhost:3000/api/admin/deleteReceta/${receta['id']}');
                                    final response = await http.delete(url);
                                    if (response.statusCode == 200) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('✅ Receta eliminada')),
                                      );
                                      cargarRecetas();
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                '❌ Error al eliminar receta: ${jsonDecode(response.body)['message'] ?? ''}')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      nombreRecetaController.clear();
                      porcionController.clear();
                      seleccionados.clear();
                      for (var c in cantidadControllers) {
                        c.dispose();
                      }
                      cantidadControllers.clear();
                      recetaEditandoId = null;
                      recetaEditandoNombre = null;
                    });
                    await cargarConsumibles();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return buildRecetaDialog(context);
                      },
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
                      Icon(Icons.receipt_long,
                          color: Color(0xffF5F5F5), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Crear Receta',
                        style:
                            TextStyle(color: Color(0xffF5F5F5), fontSize: 14),
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
