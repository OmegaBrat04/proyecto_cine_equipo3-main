import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import 'package:proyecto_cine_equipo3/Controlador/Administracion/funciones_controller.dart';
import 'package:proyecto_cine_equipo3/Modelo/ModeloFunciones.dart';

void main() {
  runApp(const AFunciones());
}

class AFunciones extends StatelessWidget {
  const AFunciones({super.key});

  Widget buildWithFuncionEditar(FuncionLista funcion) {
    return Scaffold(
      body: Funciones(funcionEditar: funcion),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Funciones(),
    );
  }
}

class Funciones extends StatefulWidget {
  final FuncionLista? funcionEditar;

  const Funciones({super.key, this.funcionEditar});

  @override
  _FuncionesState createState() => _FuncionesState();
}

class _FuncionesState extends State<Funciones> {
  // — Datos para el buscador
  List<Map<String, dynamic>> peliculas = [];
  String query = '';
  String? posterBase64;
  List<String> horariosAsignados = [];
  Map<String, dynamic>? peliculaSeleccionada;

  // — Controladores
  final tituloController = TextEditingController();
  final horarioController = TextEditingController();
  final salaController = TextEditingController();
  final fechaController = TextEditingController();
  final tipoController = TextEditingController();
  final idiomaController = TextEditingController();
  final buscadorController = TextEditingController();

  File? _imagen;
  String dropdownValue = '2D';
  String dropdownValue2 = '1';
  String dropdownValue3 = 'Español';

  @override
  void initState() {
    super.initState();
    if (widget.funcionEditar != null) {
      final f = widget.funcionEditar!;
      tituloController.text = f.titulo;
      dropdownValue2 = f.sala.toString();
      dropdownValue = f.tipoSala;
      dropdownValue3 = f.idioma;
      fechaController.text = f.fecha;
      horariosAsignados = [f.horario]; // Solo uno porque la función es única
    }

    fetchPeliculas();
  }

  Future<void> fetchPeliculas() async {
    try {
      final resp = await http
          .get(Uri.parse('http://localhost:3000/api/admin/getMovies'));
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
        final nuevoHorario =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';

        if (!horariosAsignados.contains(nuevoHorario)) {
          setState(() {
            horariosAsignados.add(nuevoHorario);
          });
        }
      });
    }
  }

  Future<void> _seleccionarFecha() async {
    final DateTime ahora = DateTime.now();
    final DateTime hoy = DateTime(ahora.year, ahora.month, ahora.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: hoy,
      firstDate: hoy,
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
              height: 600,
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
                              Navigator.pop(context);
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
                      RawAutocomplete<Map<String, dynamic>>(
                        textEditingController: buscadorController,
                        focusNode: FocusNode(),
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          final input = textEditingValue.text.toLowerCase();
                          if (input.isEmpty) return const Iterable.empty();

                          return peliculas.where((p) {
                            final titulo =
                                (p['titulo'] ?? '').toString().toLowerCase();
                            return titulo.contains(input);
                          });
                        },
                        displayStringForOption: (p) => p['titulo'],
                        onSelected: (p) {
                          setState(() {
                            peliculaSeleccionada = p;
                            tituloController.text = p['titulo'];
                            posterBase64 = p['poster'];
                          });
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                          return SizedBox(
                            width: 300,
                            child: TextField(
                              controller: controller,
                              focusNode: focusNode,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Buscar Película',
                                hintStyle:
                                    const TextStyle(color: Colors.white70),
                                prefixIcon: const Icon(Icons.search,
                                    color: Colors.white),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(10),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                    maxHeight: 200, maxWidth: 300),
                                child: ListView.separated(
                                  padding: const EdgeInsets.all(8),
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final p = options.elementAt(index);
                                    return ListTile(
                                      title: Text(p['titulo']),
                                      onTap: () => onSelected(p),
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
                            const SizedBox(height: 10),
                            _imagen != null
                                ? Image.file(
                                    _imagen!,
                                    width: 150,
                                    height: 250,
                                    fit: BoxFit.contain,
                                  )
                                : (posterBase64 != null &&
                                        posterBase64!.isNotEmpty
                                    ? Image.network(
                                        posterBase64!,
                                        width: 150,
                                        height: 250,
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
                        const SizedBox(width: 40),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Titulo',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              Container(
                                width: double.infinity,
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
                                width: double.infinity,
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
                              Container(
                                height: 150,
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: horariosAsignados.isEmpty
                                    ? const Center(
                                        child:
                                            Text('No se han asignado horarios'))
                                    : SingleChildScrollView(
                                        child: Column(
                                            children:
                                                horariosAsignados.map((h) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8.0),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xff14AE5C),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(h,
                                                      style: const TextStyle(
                                                          color: Colors.white)),
                                                  const SizedBox(width: 10),
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        horariosAsignados
                                                            .remove(h);
                                                      });
                                                    },
                                                    child: const Icon(
                                                        Icons.close,
                                                        size: 16,
                                                        color: Colors.white),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList()),
                                      ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 40),

                        // Segunda columna
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Seleccione una Sala',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.only(left: 10),
                                width: double.infinity,
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
                              const Text('Asigne una Fecha',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              Container(
                                width: double.infinity,
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
                                width: double.infinity,
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
                              const Text('Tipo de Sala',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.only(left: 10),
                                width: double.infinity,
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
                                  items: <String>['2D', '3D']
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 100),
                              Container(
                                height: 40,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (peliculaSeleccionada == null ||
                                        peliculaSeleccionada!['id'] == null ||
                                        fechaController.text.trim().isEmpty ||
                                        horariosAsignados.isEmpty ||
                                        dropdownValue2.isEmpty ||
                                        dropdownValue3.isEmpty ||
                                        dropdownValue.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "❗Completa todos los campos antes de continuar"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    final fecha = fechaController.text.trim();
                                    final idioma = dropdownValue3;
                                    final tipoSala = dropdownValue;
                                    final sala = int.tryParse(dropdownValue2);
                                    final hoy = DateTime.now();
                                    final fechaSeleccionada =
                                        DateTime.tryParse(fecha);

                                    if (fechaSeleccionada != null &&
                                        fechaSeleccionada.isBefore(hoy.subtract(
                                            const Duration(days: 1)))) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "❗No puedes seleccionar una fecha pasada"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    final horario = horariosAsignados.first;
                                    final horarioFormateado =
                                        horario.length == 5
                                            ? "$horario:00"
                                            : horario;

                                    final data = {
                                      "id_pelicula":
                                          peliculaSeleccionada!['id'],
                                      "fecha": fecha,
                                      "horario": horarioFormateado,
                                      "sala": sala,
                                      "tipo_sala": tipoSala,
                                      "idioma": idioma
                                    };

                                    if (widget.funcionEditar == null) {
                                      // NUEVA
                                      final yaExiste =
                                          await ControladorFun.funcionExiste({
                                        "fecha": fecha,
                                        "horario": horarioFormateado,
                                        "sala": sala
                                      });

                                      if (yaExiste) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "❌ Ya existe una función en esa sala y horario"),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                        return;
                                      }

                                      final ok =
                                          await ControladorFun.agregarFuncion(
                                              data);
                                      if (ok) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "✅ Función registrada con éxito"),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        Navigator.pop(context,
                                            true); 
                                      }
                                    } else {
                                      // EDICIÓN
                                      final ok = await ControladorFun
                                          .actualizarFuncion(
                                        widget.funcionEditar!.id,
                                        data,
                                      );

                                      if (ok) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "✅ Función actualizada correctamente"),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        Navigator.pop(context);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "❌ Error al actualizar función"),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    backgroundColor: const Color(0xff14AE5C),
                                  ),
                                  child: Text(
                                    widget.funcionEditar == null
                                        ? 'Guardar Funcion'
                                        : 'Actualizar Funcion',
                                    style: TextStyle(color: Color(0xffF5F5F5)),
                                  ),
                                ),
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
        ),
      ),
    );
  }
}
