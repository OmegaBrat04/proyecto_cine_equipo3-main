import 'package:flutter/material.dart';
import 'package:proyecto_cine_equipo3/Controlador/Administracion/funciones_controller.dart';
import 'package:proyecto_cine_equipo3/Modelo/ModeloFunciones.dart';
import 'package:proyecto_cine_equipo3/Vistas/Administracion/Menu.dart';
import 'RegistrarFunciones.dart';
import 'RegistrarPeliculas.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const ListaFunciones());
}

class ListaFunciones extends StatelessWidget {
  const ListaFunciones({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Funciones(),
    );
  }
}

class Funciones extends StatefulWidget {
  const Funciones({super.key});

  @override
  _FuncionesState createState() => _FuncionesState();
}

class _FuncionesState extends State<Funciones> {
  final TextEditingController buscadorController = TextEditingController();
  String dropdownValue = 'Por Horario';
  List<FuncionLista> todasFunciones = [];
  List<FuncionLista> funcionesFiltradas = [];

  @override
  void initState() {
    super.initState();
    cargarFunciones();
  }

  void cargarFunciones() async {
    final funciones = await ControladorFun.obtenerFuncionesVigentes();
    setState(() {
      todasFunciones = funciones;
      funcionesFiltradas = List.from(funciones);
      ordenarFunciones();
    });
  }

  void filtrarFunciones(String texto) {
    final textoLower = texto.toLowerCase();

    setState(() {
      funcionesFiltradas = todasFunciones.where((f) {
        return f.titulo.toLowerCase().contains(textoLower);
      }).toList();
      ordenarFunciones();
    });
  }

  void ordenarFunciones() {
    funcionesFiltradas.sort((a, b) {
      if (dropdownValue == 'Por Fecha') {
        return DateTime.parse(a.fecha).compareTo(DateTime.parse(b.fecha));
      } else {
        return DateTime.parse(a.horario).compareTo(DateTime.parse(b.horario));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Menu()),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Regresar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                        controller: buscadorController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Buscar por titulo...',
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
                        onChanged: (String value) {
                          filtrarFunciones(value);
                        },
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Ordenar:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        dropdownColor: const Color(0xFF022044),
                        value: dropdownValue,
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.white),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.white),
                        underline: Container(
                          height: 2,
                          color: Colors.white,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                            ordenarFunciones();
                          });
                        },
                        items: <String>[
                          'Por Horario',
                          'Por Fecha',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
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
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    const Text(
                      'Funciones',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: funcionesFiltradas.isEmpty
                          ? const Center(
                              child: Text('😶 No hay funciones programadas.',
                                  style: TextStyle(color: Colors.white)))
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                border: TableBorder.all(color: Colors.grey),
                                headingTextStyle:
                                    const TextStyle(color: Colors.white),
                                dataTextStyle:
                                    const TextStyle(color: Colors.white),
                                columns: const [
                                  DataColumn(label: Text('Título')),
                                  DataColumn(label: Text('Horario')),
                                  DataColumn(label: Text('Fecha')),
                                  DataColumn(label: Text('Sala')),
                                  DataColumn(label: Text('Tipo')),
                                  DataColumn(label: Text('Idioma')),
                                  DataColumn(label: Text('Opciones')),
                                ],
                                rows: funcionesFiltradas
                                    .map((f) => DataRow(
                                          cells: [
                                            DataCell(Text(f.titulo)),
                                            DataCell(Text(
                                              DateFormat('HH:mm:ss').format(
                                                  DateTime.parse(f.horario)),
                                            )),
                                            DataCell(Text(
                                              DateFormat('dd/MM/yyyy').format(
                                                  DateTime.parse(f.fecha)),
                                            )),
                                            DataCell(Text(f.sala.toString())),
                                            DataCell(Text(f.tipoSala)),
                                            DataCell(Text(f.idioma)),
                                            DataCell(
                                              Row(
                                                children: [
                                                  /*IconButton(
                                                    icon: const Icon(Icons.edit,
                                                        color: Colors.white),
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const AFunciones()
                                                                  .buildWithFuncionEditar(
                                                                      f),
                                                        ),
                                                      );
                                                    },
                                                  ),*/
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.white),
                                                    onPressed: () async {
                                                      final confirmado =
                                                          await showDialog<
                                                              bool>(
                                                        context: context,
                                                        builder: (context) =>
                                                            AlertDialog(
                                                          title: const Text(
                                                              'Eliminar Función'),
                                                          content: const Text(
                                                              '¿Estás seguro que deseas eliminar esta función?'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context,
                                                                      false),
                                                              child: const Text(
                                                                  'Cancelar'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context,
                                                                      true),
                                                              child: const Text(
                                                                  'Eliminar'),
                                                            ),
                                                          ],
                                                        ),
                                                      );

                                                      if (confirmado == true) {
                                                        final eliminado =
                                                            await ControladorFun
                                                                .eliminarFuncion(
                                                                    f.id);
                                                        if (eliminado) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                                content: Text(
                                                                    '✅ Función eliminada')),
                                                          );
                                                          cargarFunciones(); // recargar lista
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                                content: Text(
                                                                    '❌ Error al eliminar función')),
                                                          );
                                                        }
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ))
                                    .toList(),
                              ),
                            ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RPeliculas(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff14AE5C),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.movie_creation,
                            color: Color(0xffF5F5F5), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Nueva Pelicula',
                          style:
                              TextStyle(color: Color(0xffF5F5F5), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final resultado = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AFunciones(),
                        ),
                      );

                      if (resultado == true) {
                        cargarFunciones();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff14AE5C),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.movie_filter,
                            color: Color(0xffF5F5F5), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Nueva Funcion',
                          style:
                              TextStyle(color: Color(0xffF5F5F5), fontSize: 14),
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
    );
  }
}
