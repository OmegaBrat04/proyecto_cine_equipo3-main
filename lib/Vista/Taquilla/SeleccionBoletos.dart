import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const SBoletos());
}

class SBoletos extends StatelessWidget {
  const SBoletos({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SeleccionBoletos(),
      ),
    );
  }
}

class SeleccionBoletos extends StatefulWidget {
  const SeleccionBoletos({super.key});

  @override
  _SeleccionBoletosState createState() => _SeleccionBoletosState();
}

class _SeleccionBoletosState extends State<SeleccionBoletos> {
  final TextEditingController fechaController = TextEditingController();
  final String titulo = 'Jurassic Park';
  final String fecha = '15/07/2025';
  final String horario = '16:00';
  final String sala = '1';

  Widget TarjetaPelicula(
    String titulo,
    String fecha,
    String horario,
    String sala,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget SeleccionBoletos() {
    double total = 0.0;

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            TiposBoletos(
              'Adulto',
              100.0,
            ),
            const Divider(color: Colors.black54),
            TiposBoletos(
              'Niños',
              70.0,
            ),
            const Divider(color: Colors.black54),
            TiposBoletos(
              '3ra Edad',
              50.0,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.black54),
                    ),
                    child: TextField(
                      readOnly: true,
                      controller: TextEditingController(
                          text: 'Total: \$${total.toStringAsFixed(2)}'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0665A4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Siguiente',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget TiposBoletos(
    String tipo,
    double precio,
  ) {
    int cantidad = 0;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tipo,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              '\$$precio',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (cantidad > 0) {
                      setState(() {
                        cantidad--;
                      });
                    }
                  },
                  icon: const Icon(Icons.remove, color: Colors.black),
                ),
                Text(
                  '$cantidad',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      cantidad++;
                    });
                  },
                  icon: const Icon(Icons.add, color: Colors.black),
                ),
              ],
            ),
          ],
        );
      },
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
                          'Seleccion de Boletos',
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
                                  titulo,
                                  fecha,
                                  horario,
                                  sala,
                                ),
                                const SizedBox(height: 15),
                                SeleccionBoletos(),
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
