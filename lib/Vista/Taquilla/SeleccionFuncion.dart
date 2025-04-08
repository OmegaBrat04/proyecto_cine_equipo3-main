import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_cine_equipo3/Vista/Taquilla/SeleccionBoletos.dart';

class SFunciones extends StatelessWidget {
  const SFunciones({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SeleccionFunciones(),
    );
  }
}

class SeleccionFunciones extends StatefulWidget {
  const SeleccionFunciones({super.key});

  @override
  _SeleccionFuncionesState createState() => _SeleccionFuncionesState();
}

class _SeleccionFuncionesState extends State<SeleccionFunciones> {
  final TextEditingController fechaController = TextEditingController();
  final String titulo = 'Jurassic Park';
  final String genero = 'Acción, Aventura';
  final String clasificacion = 'PG-13';
  final String duracion = '2h 7m';
  DateTime? selectedDate;

  Future<void> seleccionarFecha() async {
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

  Widget BotonHorario(String texto, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        side: const BorderSide(color: Colors.black, width: 1),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SBoletos(),
          ),
        );
      },
      child: Text(
        texto,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget TarjetaPelicula(String titulo, String genero, String clasificacion,
      String duracion, List<String> horarios) {
    return SingleChildScrollView(
      child: Card(
        margin: const EdgeInsets.only(bottom: 10, top: 10, right: 80, left: 10),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 100,
                height: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: Image.asset('images/Poster JWR.jpeg').image,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    titulo,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 5),
                          Text(
                            'Clasificación: $clasificacion',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              color: Colors.blue, size: 16),
                          const SizedBox(width: 5),
                          Text(
                            'Duración: $duracion',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Row(
                        children: [
                          const Icon(Icons.category,
                              color: Colors.green, size: 16),
                          const SizedBox(width: 5),
                          Text(
                            'Géneros: $genero',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(right: 50),
                    child: Container(
                      height: 1,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text('ESPAÑOL',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      )),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: horarios
                        .map((horario) => BotonHorario(
                              horario,
                              () {},
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(right: 50),
                    child: Container(
                      height: 1,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text('INGLES',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      )),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: horarios
                        .map((horario) => BotonHorario(
                              horario,
                              () {},
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF022044), Color(0xFF01021E)],
              ),
            ),
            child: SingleChildScrollView(
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
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Atras',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              'Fecha: ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Container(
                              width: 200,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: TextField(
                                controller: fechaController,
                                readOnly: true,
                                onTap: seleccionarFecha,
                                decoration: const InputDecoration(
                                  hintText: 'Seleccione una fecha',
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                  prefixIcon: Icon(Icons.date_range),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                      top: 8, left: 10, bottom: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 50),
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
                      ],
                    ),
                  ),
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 900,
                          height: 550,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const Text(
                                  textAlign: TextAlign.center,
                                  'Seleccione una función',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TarjetaPelicula(
                                  titulo,
                                  genero,
                                  clasificacion,
                                  duracion,
                                  ['10:00 AM', '1:00 PM', '4:00 PM'],
                                ),
                                TarjetaPelicula(
                                  titulo,
                                  genero,
                                  clasificacion,
                                  duracion,
                                  ['11:00 AM', '2:00 PM', '5:00 PM'],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
