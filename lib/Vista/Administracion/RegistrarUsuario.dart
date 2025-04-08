import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RegistroU(),
  ));
}

class RegistroU extends StatefulWidget {
  const RegistroU({super.key});

  @override
  _RegistroUState createState() => _RegistroUState();
}

class _RegistroUState extends State<RegistroU> {
  final nombreController = TextEditingController();
  final apellidosController = TextEditingController();
  final telefonoController = TextEditingController();
  final rfcController = TextEditingController();
  final usuarioController = TextEditingController();
  final contrasenaController = TextEditingController();
  final confirmarContrasenaController = TextEditingController();
  final fechaController = TextEditingController();

  String departamento = 'Taquilla';
  final List<String> departamentos = [
    'Taquilla',
    'Dulceria',
    'Cafeteria',
    'Limpieza'
  ];
//HomeScreen
  Widget textFields(String label, TextEditingController controller,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
    );
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
            const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Center(
                  child: Text(
                    'Nuevos Usuarios',
                    style: TextStyle(
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
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.arrow_back,
                                        color: Colors.white, size: 30),
                                  ),
                                  const Text(
                                    'Atras',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
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
                          const SizedBox(height: 30),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          child: textFields(
                                              'Nombre', nombreController)),
                                      const SizedBox(width: 30),
                                      Expanded(
                                          child: textFields(
                                              'Teléfono', telefonoController,
                                              keyboardType:
                                                  TextInputType.phone)),
                                      const SizedBox(width: 30),
                                      Expanded(
                                          child: textFields('Contraseña',
                                              contrasenaController,
                                              obscureText: true)),
                                    ],
                                  ),
                                  const SizedBox(height: 30),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: textFields('Apellidos',
                                              apellidosController)),
                                      const SizedBox(width: 30),
                                      Expanded(
                                          child:
                                              textFields('RFC', rfcController)),
                                      const SizedBox(width: 30),
                                      Expanded(
                                          child: textFields(
                                              'Confirmar Contraseña',
                                              confirmarContrasenaController,
                                              obscureText: true)),
                                    ],
                                  ),
                                  const SizedBox(height: 30),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: textFields(
                                              'Usuario', usuarioController)),
                                      const SizedBox(width: 30),
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: departamento,
                                          items:
                                              departamentos.map((String value) {
                                            return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value));
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              setState(() {
                                                departamento = newValue;
                                              });
                                            }
                                          },
                                          decoration: InputDecoration(
                                            fillColor: Colors.white,
                                            filled: true,
                                            labelText: 'Departamento',
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 30),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: TextField(
                                            mouseCursor:
                                                SystemMouseCursors.click,
                                            controller: fechaController,
                                            readOnly: true,
                                            decoration: const InputDecoration(
                                              hintText: 'Fecha de nacimiento',
                                              hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 15),
                                              prefixIcon:
                                                  Icon(Icons.date_range),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.only(
                                                  left: 10,
                                                  bottom: 10,
                                                  top: 10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30),
                                ],
                              );
                            },
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
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              backgroundColor: const Color(0xff14AE5C),
                            ),
                            child: const Text(
                              'Guardar Usuario',
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
