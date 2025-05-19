import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_cine_equipo3/Modelo/ModeloPeliculas.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/Menu.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/Peliculas.dart';
import 'package:proyecto_cine_equipo3/Controlador/Administracion/peliculas_controller.dart';

import 'dart:io';
import 'package:proyecto_cine_equipo3/Vistas/Services/Multiseleccion.dart';
import 'Funciones.dart';

void main() {
  runApp(const RPeliculas());
}

class RPeliculas extends StatelessWidget {
  final Map<String, dynamic>? pelicula;
  const RPeliculas({super.key, this.pelicula});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListaPeliculas(pelicula: pelicula),
    );
  }
}

class ListaPeliculas extends StatefulWidget {
  final Map<String, dynamic>? pelicula;
  const ListaPeliculas({super.key, this.pelicula});

  @override
  _ListaPeliculasState createState() => _ListaPeliculasState();
}

//Guardar
class _ListaPeliculasState extends State<ListaPeliculas> {
  String? _posterUrlActual;

  @override
  void initState() {
    super.initState();
    if (widget.pelicula != null) {
      final p = widget.pelicula!;
      tituloController.text = p['titulo'] ?? '';
      directorController.text = p['director'] ?? '';
      duracionController.text = _formatoDuracion(p['duracion']);
      idiomaController.text = p['idioma'] ?? '';
      generoController.text = p['genero'] ?? '';
      dropdownValue = p['clasificacion'] ?? 'B';
      sinopsisController.text = p['sinopsis'] ?? '';
      if (p['poster'] != null && p['poster'].toString().isNotEmpty) {
        _posterUrlActual = p['poster'];
      }

      final valor = p['subtitulos'];
      subtitulos = (valor == true || valor == 1 || valor == '1') ? 'Si' : 'No';
    }
  }

  String _formatoDuracion(dynamic duracionSQL) {
    try {
      if (duracionSQL is String && duracionSQL.contains(':')) {
        final partes = duracionSQL.split(':');
        final horas = int.tryParse(partes[0]) ?? 0;
        final minutos = int.tryParse(partes[1]) ?? 0;
        return '${horas}h ${minutos}m';
      }
    } catch (_) {}
    return '0h 0m';
  }

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
  String convertirDuracion(String duracion) {
    final RegExp regex = RegExp(r'(\d+)h\s*(\d+)m'); // Extrae "2h 30m"
    final match = regex.firstMatch(duracion);

    if (match != null) {
      final horas = match.group(1) ?? "0";
      final minutos = match.group(2) ?? "0";
      return "${horas.padLeft(2, '0')}:${minutos.padLeft(2, '0')}:00"; // Formato HH:mm:ss
    }

    return "00:00:00"; // Si no se puede convertir, envía duración en ceros
  }

  Future<String?> subirImagen(File imagen) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:3000/api/admin/uploadImage'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('poster', imagen.path),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        final res = await response.stream.bytesToString();
        final data = json.decode(res);
        return data['imageUrl'];
      } else {
        print('Error al subir imagen: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Excepción al subir imagen: $e');
      return null;
    }
  }

  Future<void> guardarPelicula() async {
    final titulo = tituloController.text.trim();
    final director = directorController.text.trim();
    final duracion = convertirDuracion(duracionController.text.trim());
    final idiomaTexto = idiomaController.text.trim();
    final genero = generoController.text.trim();
    final clasificacion = dropdownValue;
    final sinopsis = sinopsisController.text.trim();
    final subtitulosBool = subtitulos == "Si";

// Validación de campos
    if ([
      titulo,
      director,
      duracion,
      idiomaTexto,
      genero,
      clasificacion,
      sinopsis
    ].any((element) => element.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Todos los campos son obligatorios"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

// Subir imagen si existe
    String? posterUrl;

    if (_imagen != null) {
      posterUrl = await subirImagen(_imagen!);
    }

    if (posterUrl == null && _posterUrlActual != null) {
      posterUrl = _posterUrlActual;
    }

// Crear el modelo
    final pelicula = PeliculaModel(
      titulo: titulo,
      director: director,
      duracion: duracion,
      idioma: idiomaTexto,
      genero: genero,
      clasificacion: clasificacion,
    );

    final body = pelicula.toJson(sinopsis, subtitulosBool, posterUrl);

    bool exito;

    if (widget.pelicula != null && widget.pelicula!['id'] != null) {
      final id = widget.pelicula!['id'];
      exito = await PeliculasController.actualizarPelicula(id, body);
    } else {
      exito = await PeliculasController.guardarPelicula(body);
    }

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Película guardada con éxito"),
          backgroundColor: Colors.green,
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Peliculas()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Error al guardar película"),
          backgroundColor: Colors.red,
        ),
      );
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

  Future<void> _seleccionarDuracion() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 0, minute: 0),
      initialEntryMode: TimePickerEntryMode.inputOnly,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xff14AE5C), // Verde
                onPrimary: Colors.white,
                surface: Color(0xFF022044), // Fondo dialog
                onSurface: Colors.white,
              ),
              timePickerTheme: const TimePickerThemeData(
                backgroundColor: Color(0xFF022044),
                hourMinuteTextColor: Colors.white,
                dialHandColor: Color(0xff14AE5C),
                dialBackgroundColor: Color(0xFF0D1B3D),
                entryModeIconColor: Color(0xff14AE5C),
              ),
              textButtonTheme: TextButtonThemeData(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(Color(0xff14AE5C)),
                ),
              ),
            ),
            child: child!,
          ),
        );
      },
      confirmText: "Aceptar",
      cancelText: "Cancelar",
      helpText: 'Selecciona la duración',
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
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: Text(
                    widget.pelicula != null
                        ? 'Editar Película'
                        : 'Registrar Película',
                    style: const TextStyle(
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
                                        ? (_posterUrlActual != null
                                            ? Image.network(
                                                _posterUrlActual!,
                                                width: 150,
                                                height: 200,
                                                fit: BoxFit.contain,
                                              )
                                            : Container(
                                                width: 150,
                                                height: 200,
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.image,
                                                    size: 100,
                                                    color: Colors.grey),
                                              ))
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
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            backgroundColor:
                                                const Color(0xff434343)),
                                        child: const Text(
                                          'Cargar Imagen',
                                          style: TextStyle(
                                              color: Color(0xffF5F5F5)),
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
                                          contentPadding: EdgeInsets.only(
                                              left: 10, bottom: 10),
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
                                          contentPadding: EdgeInsets.only(
                                              left: 10, bottom: 10),
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
                                          contentPadding: EdgeInsets.only(
                                              left: 10, bottom: 10),
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
                                          contentPadding: EdgeInsets.only(
                                              left: 10, bottom: 10),
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
                                          fillColor:
                                              WidgetStateColor.resolveWith(
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
                                          fillColor:
                                              WidgetStateColor.resolveWith(
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
                                          prefixIcon:
                                              Icon(Icons.movie_outlined),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                              left: 10, bottom: 10),
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
                                        dropdownColor: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        value: dropdownValue,
                                        icon: const Icon(Icons.arrow_drop_down,
                                            color: Colors.black),
                                        iconSize: 24,
                                        //elevation: 16,
                                        style: const TextStyle(
                                            color: Colors.black),
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
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
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
                          width: 250,
                          child: ElevatedButton(
                            onPressed: guardarPelicula,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              backgroundColor: const Color(0xff14AE5C),
                            ),
                            child: const Text(
                              'Guardar Pelicula',
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
