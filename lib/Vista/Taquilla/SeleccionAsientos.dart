import 'package:flutter/material.dart';

void main() {
  runApp(const SAsientos());
}

class SAsientos extends StatelessWidget {
  const SAsientos({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SeleccionAsientos(),
      ),
    );
  }
}

class SeleccionAsientos extends StatefulWidget {
  const SeleccionAsientos({super.key});

  @override
  _SeleccionAsientosState createState() => _SeleccionAsientosState();
}

class _SeleccionAsientosState extends State<SeleccionAsientos> {
  final String titulo = 'Jurassic Park';
  final String fecha = '15/07/2025';
  final String horario = '16:00';
  final String sala = '1';
  final String boletos = '2';

  Widget TarjetaPelicula(
    String titulo,
    String fecha,
    String horario,
    String sala,
    String boletos,
  ) {
    return Card(
      color: Colors.grey[200],
      margin: const EdgeInsets.symmetric(
        vertical: 10, /*horizontal: 4*/
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Image.asset('images/Poster JWR.jpeg').image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Fecha: $fecha',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        'Hora: $horario',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        'Sala: $sala',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Boletos: $boletos',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
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

  Widget SeleccionAsientos() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox.square(
                      dimension: 30,
                      child: Container(
                        color: const Color(0xFFFAB802),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Asiento Seleccionado',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox.square(
                      dimension: 30,
                      child: Container(
                        color: const Color(0xFF767676),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Ocupado',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox.square(
                      dimension: 30,
                      child: Container(
                        color: const Color(0xFF14AE5C),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Disponible',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            const Divider(
              color: Colors.black54,
              thickness: 1,
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              height: 30,
              color: Color(0XFF767676),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('PANTALLA',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Asientos(),
            const SizedBox(height: 8),
            Asientos(),
            const SizedBox(height: 8),
            Asientos(),
            const SizedBox(height: 8),
            Asientos(),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget Asientos() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.chair_rounded,
                  color: Color(0xFF14AE5C),
                  size: 30,
                )),
            const SizedBox(width: 8),
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.chair_rounded,
                  color: Color(0xFF14AE5C),
                  size: 30,
                )),
          ],
        ),
        Row(
          children: [
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.chair_rounded,
                  color: Color(0xFF14AE5C),
                  size: 30,
                )),
            const SizedBox(width: 8),
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.chair_rounded,
                  color: Color(0xFF14AE5C),
                  size: 30,
                )),
          ],
        ),
        Row(
          children: [
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.chair_rounded,
                  color: Color(0xFF14AE5C),
                  size: 30,
                )),
            const SizedBox(width: 8),
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.chair_rounded,
                  color: Color(0xFF14AE5C),
                  size: 30,
                )),
          ],
        ),
        Row(
          children: [
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.chair_rounded,
                  color: Color(0xFF14AE5C),
                  size: 30,
                )),
            const SizedBox(width: 8),
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.chair_rounded,
                  color: Color(0xFF14AE5C),
                  size: 30,
                )),
          ],
        ),
      ],
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
                              onPressed: () {},
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
                        const Text(
                          'Seleccion de Asientos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
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
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 900,
                          height: 550,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xff081C42),
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
                                TarjetaPelicula(
                                    titulo, fecha, horario, sala, boletos),
                                const SizedBox(height: 20),
                                SeleccionAsientos(),
                                const SizedBox(height: 10),
                                /* Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(children: [
                                    Asientos(),
                                    const SizedBox(height: 8),
                                    Asientos(),
                                    const SizedBox(height: 8),
                                    Asientos(),
                                    const SizedBox(height: 8),
                                    Asientos(),
                                    const SizedBox(height: 5),
                                  ]),
                                )*/
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  /*const SizedBox(width: 20),
                  Column(
                    children: [
                      Center(
                        child: IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.arrow_right_alt_sharp,
                              color: Color(0xfffffffff),
                            )),
                      )
                    ],
                  )*/
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
