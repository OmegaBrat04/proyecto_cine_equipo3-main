import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:proyecto_cine_equipo3/Vista/Services/Multiseleccion.dart';
import 'Funciones.dart';

void main() {
  runApp(const RPeliculas());
}

class RPeliculas extends StatelessWidget {
  const RPeliculas({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: ListaPeliculas(),
      ),
    );
  }
}

class ListaPeliculas extends StatefulWidget {
  const ListaPeliculas({super.key});

  @override
  _ListaPeliculasState createState() => _ListaPeliculasState();
}

class _ListaPeliculasState extends State<ListaPeliculas> {
  final tituloController = TextEditingController();
  final directorController = TextEditingController();
  final duracionController = TextEditingController();
  final idiomaController = TextEditingController();
  final subtitulosController = TextEditingController();
  final generoController = TextEditingController();
  final clasificacionController = TextEditingController();
  final sinopsisController = TextEditingController();
  File? _imagen;

  List<String> idiomas = ['Español', 'Inglés', 'Francés', 'Japones'];
  List<String> idiomasSeleccionados = [];
  List<String> generos = ['Acción', 'Comedia', 'Drama', 'Terror'];
  List<String> generosSeleccionados = [];
  List<String> clasificaciones = ['A', 'B', 'B15', 'C', 'D'];
  List<String> clasificacionesSeleccionadas = [];
  String? subtitulos = 'Si';
  String dropdownValue = 'B';

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

  Future<void> _seleccionarDuracion() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 0, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        duracionController.text = '${picked.hour}h ${picked.minute}m';
      });
    }
  }

  Future<void> _seleccionarIdiomas() async {
    final List<String> seleccionados = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: idiomas,
          initialSelectedItems: idiomasSeleccionados,
          titulo: 'Selecciona los idiomas',
        );
      },
    );

    if (seleccionados != null) {
      setState(() {
        idiomasSeleccionados = seleccionados;
        idiomaController.text = idiomasSeleccionados.join(', ');
      });
    }
  }

  Future<void> _seleccionarGenero() async {
    final List<String> seleccionados = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: generos,
          initialSelectedItems: generosSeleccionados,
          titulo: 'Selecciona los generos',
        );
      },
    );

    if (seleccionados != null) {
      setState(() {
        generosSeleccionados = seleccionados;
        generoController.text = generosSeleccionados.join(', ');
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
        child: Center(
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255)),
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
                    padding: const EdgeInsets.only(left: 30.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Poster',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            _imagen == null
                                ? Container(
                                    width: 150,
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image,
                                        size: 100, color: Colors.grey),
                                  )
                                : Image.file(
                                    _imagen!,
                                    width: 150,
                                    height: 200,
                                    fit: BoxFit.contain,
                                  ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 40,
                              width: 150,
                              child: ElevatedButton(
                                onPressed: () {
                                  _seleccionarImagen();
                                },
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    backgroundColor: const Color(0xff434343)),
                                child: const Text(
                                  'Cargar Imagen',
                                  style: TextStyle(color: Color(0xffF5F5F5)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 30),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Titulo',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width: 200,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: TextField(
                                controller: tituloController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.only(left: 10, bottom: 10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Director',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width: 200,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: TextField(
                                controller: directorController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.only(left: 10, bottom: 10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Duración',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width: 200,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: TextField(
                                controller: duracionController,
                                readOnly: true,
                                onTap: _seleccionarDuracion,
                                decoration: const InputDecoration(
                                  hintText: 'Seleccione la duracion',
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                  prefixIcon: Icon(Icons.access_time),
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.only(left: 10, bottom: 10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Idioma',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width: 200,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: TextField(
                                controller: idiomaController,
                                readOnly: true,
                                onTap: _seleccionarIdiomas,
                                decoration: const InputDecoration(
                                  hintText: 'Seleccione los idiomas',
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                  prefixIcon: Icon(Icons.language),
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.only(left: 10, bottom: 10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Subtitulos',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Radio<String>(
                                  activeColor: Colors.white,
                                  fillColor: WidgetStateColor.resolveWith(
                                      (states) => Colors.white),
                                  value: 'Si',
                                  groupValue: subtitulos,
                                  onChanged: (String? value) {
                                    setState(() {
                                      subtitulos = value;
                                    });
                                  },
                                ),
                                const Text(
                                  'Sí',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Radio<String>(
                                  activeColor: Colors.white,
                                  fillColor: WidgetStateColor.resolveWith(
                                      (states) => Colors.white),
                                  value: 'No',
                                  groupValue: subtitulos,
                                  onChanged: (String? value) {
                                    setState(() {
                                      subtitulos = value;
                                    });
                                  },
                                ),
                                const Text(
                                  'No',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(width: 30),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Genero',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width: 200,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: TextField(
                                controller: generoController,
                                readOnly: true,
                                onTap: _seleccionarGenero,
                                decoration: const InputDecoration(
                                  hintText: 'Seleccione los generos',
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                  prefixIcon: Icon(Icons.movie_outlined),
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.only(left: 10, bottom: 10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Clasificacion',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: EdgeInsets.only(left: 10),
                              width: 200,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: DropdownButton<String>(
                                underline: Container(
                                  color: Colors.transparent,
                                ),
                                dropdownColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                value: dropdownValue,
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: Colors.black),
                                iconSize: 24,
                                //elevation: 16,
                                style: const TextStyle(color: Colors.black),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dropdownValue = newValue!;
                                  });
                                },
                                items: <String>[
                                  'A',
                                  'B',
                                  'B15',
                                  'C',
                                  'D'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Sinopsis',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width: 200,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: TextField(
                                style: const TextStyle(fontSize: 14),
                                controller: sinopsisController,
                                maxLines: 5,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.only(left: 10, bottom: 10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              height: 40,
                              width: 200,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    backgroundColor: const Color(0xff14AE5C)),
                                child: const Text(
                                  'Guardar Usuario',
                                  style: TextStyle(color: Color(0xffF5F5F5)),
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
            ),
          ),
        ),
      ),
    );
  }
}
