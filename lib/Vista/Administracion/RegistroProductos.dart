import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_cine_equipo3/Vista/Services/Multiseleccion.dart';
import 'dart:io';

void main() {
  runApp(const Registroproductos());
}

class Registroproductos extends StatelessWidget {
  const Registroproductos({super.key});

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

  List<String> _consumibles = [
    "Maiz Palomero",
    "Mantequilla",
    "Queso Amarillo"
  ];
  List<String> _intermedios = [
    "Palomitas de Mantequilla",
    "Palomitas de Queso",
    "Palomitas de Caramelo"
  ];
  List<String> _consumiblesSeleccionados = [];
  List<String> _intermediosSeleccionados = [];

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

  Future<void> _seleccionarConsumibles() async {
    final List<String> seleccionados = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: _consumibles,
          initialSelectedItems: _consumiblesSeleccionados,
          titulo: 'Seleccione los consumibles a usar',
        );
      },
    );
    if (seleccionados != null) {
      setState(() {
        _consumiblesSeleccionados = seleccionados;
        //consumiblesController.text = _consumiblesSeleccionados.join(', ');
      });
    }
  }

  Future<void> _seleccionarIntermedios() async {
    final List<String> seleccionados = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: _intermedios,
          initialSelectedItems: _intermediosSeleccionados,
          titulo: 'Seleccione los intermedios a usar',
        );
      },
    );
    if (seleccionados != null) {
      setState(() {
        _intermediosSeleccionados = seleccionados;
        //consumiblesController.text = _consumiblesSeleccionados.join(', ');
      });
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
                    'Registro de Productos',
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
                                      /*   Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const HomeScreen()),
                                      );*/
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
                          const SizedBox(height: 20),
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
                                    const SizedBox(
                                      height: 80,
                                    ),
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
                                      'Nombre del Producto',
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
                                    const SizedBox(height: 15),
                                    const Text(
                                      'Seleccionar Tamaño',
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
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: dropdownValue3,
                                        hint: const Padding(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Text(
                                            'Selecciona un tamaño',
                                            style: TextStyle(
                                                color: Color(0xff000000),
                                                fontSize: 14),
                                          ),
                                        ),
                                        items: <String>[
                                          'PEQUEÑO',
                                          'MEDIANAS',
                                          'GRANDES',
                                          'JUMBO',
                                        ].map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Text(value),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? value) {
                                          setState(() {
                                            dropdownValue3 = value;
                                          });
                                        },
                                        icon: const Icon(Icons.arrow_drop_down,
                                            color: Colors.black),
                                        iconSize: 20,
                                        elevation: 16,
                                        underline: Container(
                                          height: 0,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    const Text(
                                      'Tamaño de la Porcion',
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
                                            controller: cPorcioncontroller,
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
                                              'gr',
                                              'kg',
                                              'ml',
                                              'L',
                                            ].map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                            onChanged: (String? value) {
                                              setState(() {
                                                dropdownValue2 = value!;
                                              });
                                            },
                                            value: dropdownValue2,
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
                                    const SizedBox(height: 15),
                                    const Text(
                                      'Consumibles a usar',
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
                                        onTap: () {},
                                        controller: consumiblesController,
                                        decoration: const InputDecoration(
                                            hintText: 'Buscar consumibles',
                                            hintStyle: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 14),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.only(
                                                left: 10, bottom: 10),
                                            prefixIcon: Icon(Icons.search)),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Consumibles Seleccionados',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      width: 250,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: _consumiblesSeleccionados
                                              .map((consumible) => ListTile(
                                                    title: Text(
                                                      consumible,
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    trailing: Row(
                                                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          width: 40,
                                                          height: 35,
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .black),
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                          child: TextField(
                                                            //controller: cConsumiblesController,
                                                            cursorColor:
                                                                const Color(
                                                                    0xff000000),
                                                            style: const TextStyle(
                                                                color: Color(
                                                                    0xff000000)),
                                                            decoration:
                                                                const InputDecoration(
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              contentPadding:
                                                                  EdgeInsets.only(
                                                                      left: 10,
                                                                      bottom:
                                                                          10),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 6),
                                                        const Text("Unidad"),
                                                        IconButton(
                                                          icon: const Icon(
                                                              Icons.delete,
                                                              color: Colors.red,
                                                              size: 24),
                                                          onPressed: () {
                                                            setState(() {
                                                              _consumiblesSeleccionados
                                                                  .remove(
                                                                      consumible);
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
                                ),
                                const SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          width: 250,
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
                                      ],
                                    ),
                                    const SizedBox(height: 15),
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
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: TextField(
                                        cursorColor: const Color(0xff000000),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff000000)),
                                        controller: precioUController,
                                        decoration: const InputDecoration(
                                          prefixIcon: Icon(Icons.attach_money),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                              left: 10, bottom: 10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 86),
                                    const Text(
                                      'Intermedios a usar',
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
                                        
                                        onTap: () {},
                                        controller: intermediosController,
                                        decoration: const InputDecoration(
                                            hintText: 'Buscar intermedios',
                                            hintStyle: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 14),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.only(
                                                left: 10, bottom: 10),
                                            prefixIcon: Icon(Icons.search)),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Intermedios Seleccionados',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      width: 250,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: _intermediosSeleccionados
                                              .map((intermedio) => ListTile(
                                                    title: Text(
                                                      intermedio,
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    trailing: Row(
                                                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          width: 40,
                                                          height: 35,
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .black),
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                          child: TextField(
                                                            //controller: cConsumiblesController,
                                                            cursorColor:
                                                                const Color(
                                                                    0xff000000),
                                                            style: const TextStyle(
                                                                color: Color(
                                                                    0xff000000)),
                                                            decoration:
                                                                const InputDecoration(
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              contentPadding:
                                                                  EdgeInsets.only(
                                                                      left: 10,
                                                                      bottom:
                                                                          10),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 6),
                                                        const Text("Unidad"),
                                                        IconButton(
                                                          icon: const Icon(
                                                              Icons.delete,
                                                              color: Colors.red,
                                                              size: 24),
                                                          onPressed: () {
                                                            setState(() {
                                                              _intermediosSeleccionados
                                                                  .remove(
                                                                      intermedio);
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
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              backgroundColor: const Color(0xff14AE5C),
                            ),
                            child: const Text(
                              'Guardar Producto',
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
