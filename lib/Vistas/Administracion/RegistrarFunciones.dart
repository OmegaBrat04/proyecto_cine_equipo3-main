import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import 'package:proyecto_cine_equipo3/Vistas/Administracion/Menu.dart';

void main() {
  runApp(const AFunciones());
}

class AFunciones extends StatelessWidget {
  const AFunciones({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Funciones(),
      ),
    );
  }
}

class Funciones extends StatefulWidget {
  const Funciones({super.key});

  @override
  _FuncionesState createState() => _FuncionesState();
}

class _FuncionesState extends State<Funciones> {
  // — Datos para el buscador
  List<Map<String, dynamic>> peliculas = [];
  String query = '';
  String? posterBase64;

  // — Controladores
  final tituloController = TextEditingController();
  final horarioController = TextEditingController();
  final salaController = TextEditingController();
  final fechaController = TextEditingController();
  final tipoController = TextEditingController();
  final idiomaController = TextEditingController();
  final buscadorController = TextEditingController();

  File? _imagen; // si más adelante permites picker local
  String dropdownValue = 'Tradicional';
  String dropdownValue2 = '1';
  String dropdownValue3 = 'Español';

  @override
  void initState() {
    super.initState();
    fetchPeliculas();
  }

  Future<void> fetchPeliculas() async {
    try {
      final resp = await http.get(Uri.parse('http://localhost:3000/getMovies'));
      if (resp.statusCode == 200) {
        setState(() {
          peliculas = List<Map<String, dynamic>>.from(json.decode(resp.body));
        });
      }
    } catch (e) {
      print("Error al cargar películas: $e");
    }
  }

  Future<void> _seleccionarHorario() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 0, minute: 0),
      builder: (c, w) => MediaQuery(
        data: MediaQuery.of(c).copyWith(alwaysUse24HourFormat: true),
        child: w!,
      ),
    );
    if (picked != null) {
      setState(() {
        horarioController.text =
            '${picked.hour.toString().padLeft(2, '0')}h ${picked.minute.toString().padLeft(2, '0')}m';
      });
    }
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        fechaController.text = DateFormat('yyyy-MM-dd').format(picked);
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
                      color: Colors.black, blurRadius: 5, offset: Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  // ── HEADER: Atrás + Buscador + Logo ─────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Menu()),
                              );
                            },
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white, size: 30),
                          ),
                          const Text('Atras',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ],
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextField(
                            controller: buscadorController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Buscar Pelicula',
                              hintStyle: const TextStyle(color: Colors.white70),
                              prefixIcon:
                                  const Icon(Icons.search, color: Colors.white),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() => query = value.toLowerCase());
                            },
                          ),
                        ),
                      ),
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xFF0665A4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          child: Image(
                            image: AssetImage('images/PICNITO LOGO.jpeg'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ── Sugerencias de búsqueda ────────────────────────
                  if (query.isNotEmpty)
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: 150,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListView(
                        children: peliculas
                            .where((p) => (p['Titulo'] as String)
                                .toLowerCase()
                                .contains(query))
                            .map((p) {
                          return ListTile(
                            title: Text(p['Titulo'],
                                style: const TextStyle(color: Colors.white)),
                            onTap: () {
                              setState(() {
                                tituloController.text = p['Titulo'];
                                posterBase64 = p['posterBase64'] as String;
                                query = '';
                                buscadorController.clear();
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),

                  const SizedBox(height: 75),

                  // ── CUERPO: Poster + Formulario ─────────────────────
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Poster
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Poster',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            // Si subes localmente o viene de la BDD
                            _imagen != null
                                ? Image.file(
                                    _imagen!,
                                    width: 150,
                                    height: 200,
                                    fit: BoxFit.contain,
                                  )
                                : (posterBase64 != null &&
                                        posterBase64!.isNotEmpty
                                    ? Image.memory(
                                        base64Decode(posterBase64!),
                                        width: 150,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.broken_image,
                                                size: 80, color: Colors.grey),
                                      )
                                    : Container(
                                        width: 150,
                                        height: 200,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.image,
                                            size: 100, color: Colors.grey),
                                      )),
                          ],
                        ),

                        const SizedBox(width: 30),

                        // Formulario
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Titulo',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
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
                            const Text('Asigne un horario',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Container(
                              width: 200,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: TextField(
                                controller: horarioController,
                                readOnly: true,
                                onTap: _seleccionarHorario,
                                decoration: const InputDecoration(
                                  hintText: 'Seleccione un horario',
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
                            const Text('Tipo de Sala',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.only(left: 10),
                              width: 200,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: DropdownButton<String>(
                                underline: Container(),
                                dropdownColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                value: dropdownValue,
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: Colors.black),
                                isExpanded: true,
                                onChanged: (String? newValue) {
                                  setState(() => dropdownValue = newValue!);
                                },
                                items: <String>[
                                  'Tradicional',
                                  '3D'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text('Seleccione una Sala',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.only(left: 10),
                              width: 200,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: DropdownButton<String>(
                                underline: Container(),
                                dropdownColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                value: dropdownValue2,
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: Colors.black),
                                isExpanded: true,
                                onChanged: (String? newValue) {
                                  setState(() => dropdownValue2 = newValue!);
                                },
                                items: <String>[
                                  '1',
                                  '2',
                                  '3',
                                  '4',
                                  '5',
                                  '6',
                                  '7',
                                  '8'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text('Asigne una Fecha',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Container(
                              width: 200,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: TextField(
                                controller: fechaController,
                                readOnly: true,
                                onTap: _seleccionarFecha,
                                decoration: const InputDecoration(
                                  hintText: 'Seleccione una fecha',
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                  prefixIcon: Icon(Icons.date_range),
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.only(left: 10, bottom: 10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text('Seleccione Idioma',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.only(left: 10),
                              width: 200,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: DropdownButton<String>(
                                underline: Container(),
                                dropdownColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                value: dropdownValue3,
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: Colors.black),
                                isExpanded: true,
                                onChanged: (String? newValue) {
                                  setState(() => dropdownValue3 = newValue!);
                                },
                                items: <String>[
                                  'Español',
                                  'Ingles',
                                  'Frances',
                                  'Japon'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              height: 40,
                              width: 200,
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: guardar función
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  backgroundColor: const Color(0xff14AE5C),
                                ),
                                child: const Text(
                                  'Guardar Funcion',
                                  style: TextStyle(color: Color(0xffF5F5F5)),
                                ),
                              ),
                            ),
                          ],
                        ),
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
