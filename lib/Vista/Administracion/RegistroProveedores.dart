import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

void main() {
  runApp(const Rproveedores());
}

class Rproveedores extends StatelessWidget {
  const Rproveedores({super.key});

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
  final correoController = TextEditingController();
  final nombreController = TextEditingController();
  final telefonoController = TextEditingController();
  final direccionController = TextEditingController();

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
            const Padding(padding: const EdgeInsets.only(top: 10), child: Center(
              child: Text(
                'Registro de Proveedores',
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
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                          const SizedBox(height: 100),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(width: 30),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Correo',
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
                                      cursorColor: 
                                        const Color(0xff000000),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xff000000)
                                      ),
                                      controller: correoController,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding:
                                            EdgeInsets.only(left: 10, bottom: 10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 50),
                                  const Text(
                                    'Nombre',
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
                                      cursorColor: 
                                        const Color(0xff000000),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xff000000)
                                      ),
                                      controller: nombreController,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding:
                                            EdgeInsets.only(left: 10, bottom: 10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 70),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Direccion',
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
                                      cursorColor: 
                                        const Color(0xff000000),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xff000000)
                                      ),
                                      controller: direccionController,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding:
                                            EdgeInsets.only(left: 10, bottom: 10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 50),
                                  const Text(
                                    'Telefono',
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
                                      cursorColor: 
                                        const Color(0xff000000),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xff000000)
                                      ),
                                      controller: telefonoController,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding:
                                            EdgeInsets.only(left: 10, bottom: 10),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
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
                              'Guardar Proveedor',
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
