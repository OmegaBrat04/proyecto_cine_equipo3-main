import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_cine_equipo3/Vista/Dulceria/PagoDulceria.dart';
import 'package:proyecto_cine_equipo3/Vista/Taquilla/SeleccionBoletos.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CarritoDulceria(),
  ));
}

class CarritoDulceria extends StatelessWidget {
  const CarritoDulceria({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CDulces(),
    );
  }
}

class CDulces extends StatefulWidget {
  const CDulces({super.key});

  @override
  _CDulcesState createState() => _CDulcesState();
}

class _CDulcesState extends State<CDulces> {
  final TextEditingController fechaController = TextEditingController();
  final String nombre = 'Palomitas';
  final String tamano = 'Grande';
  final int cantidad = 5;
  final double precio = 50.00;
  DateTime? selectedDate;

  Widget TarjetaProducto(
    String nombre,
    String tamano,
    int cantidad,
  ) {
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
                    image: Image.asset('images/palomas.png').image,
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
                      nombre,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(EvaIcons.grid,
                            color: Colors.amber, size: 16),
                        const SizedBox(width: 5),
                        Text(
                          'Tamaño: $tamano',
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
                        const Icon(EvaIcons.npmOutline,
                            color: Colors.blue, size: 16),
                        const SizedBox(width: 5),
                        Text(
                          'Cantidad: $cantidad unidades',
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
                        const Icon(Icons.price_change,
                            color: Colors.green, size: 16),
                        const SizedBox(width: 5),
                        Text(
                          'Precio: \$ $precio',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ]),
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
                        PopupMenuButton<int>(
                          tooltip: 'Opciones de usuario',
                          icon: const CircleAvatar(
                            radius: 25,
                            backgroundColor: Color(0xFF081C42),
                            child: Icon(
                              Icons.account_circle_outlined,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          color: const Color(0xFF081C42),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          offset: const Offset(0, 50),
                          itemBuilder: (context) => [
                            PopupMenuItem<int>(
                              value: 0,
                              child: Row(
                                children: const [
                                  Icon(Icons.logout, color: Colors.white),
                                  SizedBox(width: 10),
                                  Text(
                                    "Cerrar sesión",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<int>(
                              value: 1,
                              child: Row(
                                children: const [
                                  Icon(Icons.notifications_active,
                                      color: Colors.white),
                                  SizedBox(width: 10),
                                  Text(
                                    "Notificaciones",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 0) {}
                          },
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
                            color: Color(0xff081C42),
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
                                  'Carrito de Compras',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TarjetaProducto(
                                  nombre,
                                  tamano,
                                  cantidad,
                                ),
                                TarjetaProducto(
                                  nombre,
                                  tamano,
                                  cantidad,
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
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SDulceria(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0665A4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.arrow_forward_ios_sharp,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Continuar al pago',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
