import 'package:flutter/material.dart';

void main() {
  runApp(const RegistroU());
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
  final cumpleanosController = TextEditingController();
  String departamento = 'Taquilla';

  Widget textFields(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return TextField(
      style: const TextStyle(
        color: Color.fromARGB(255, 0, 0, 0),
      ),
      controller: controller,
      decoration: InputDecoration(
        fillColor: const Color.fromARGB(255, 255, 255, 255),
        filled: true,
        labelText: label,
        floatingLabelStyle: const TextStyle(
          color: Color.fromARGB(255, 75, 73, 73),
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        labelStyle: const TextStyle(
          color: Color.fromARGB(255, 75, 73, 73),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 15, 15, 15), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 15, 15, 15), width: 1),
        ),
      ),
      obscureText: obscureText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF022044), Color(0xFF01021E)],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 180,
              margin: const EdgeInsets.only(
                  left: 30, right: 30, top: 60, bottom: 60),
              decoration: BoxDecoration(
                color: const Color(0xFF081C42),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  Container(
                    height: 100,
                    margin: const EdgeInsets.only(top: 20),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.asset(
                          'images/PICNITO LOGO.jpeg',
                          fit: BoxFit.cover,
                        )),
                  ),
                ],
              ),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 30, top: 50, bottom: 60),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back,
                              color: Color.fromARGB(255, 255, 255, 255),
                              size: 30)),
                      /*const SizedBox(
                        width: 10,
                      ),*/
                      const Text(
                        'Nuevo Usuario',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xFF081C42),
                        child: Icon(
                          Icons.account_circle_outlined,
                          size: 50,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: Color(0xFF081C42),
                        child: Text(
                          '1',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        'Perfil',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      SizedBox(
                        width: 600,
                      ),
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: Color(0xFF081C42),
                        child: Text(
                          '2',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        'Contraseña',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: SizedBox(
                                      height: 50,
                                      child: textFields(
                                          'Nombre', nombreController))),
                              const SizedBox(width: 30),
                              Expanded(
                                  flex: 2,
                                  child: SizedBox(
                                      height: 50,
                                      child: textFields(
                                          'Teléfono', telefonoController))),
                              const SizedBox(width: 30),
                              Expanded(
                                  flex: 2,
                                  child: SizedBox(
                                      height: 50,
                                      child: textFields(
                                          'Contraseña', contrasenaController,
                                          obscureText: true))),
                            ],
                          ),
                          const SizedBox(height: 60),
                          Row(
                            children: [
                              SizedBox(
                                  height: 50,
                                  width: constraints.maxWidth / 3 - 20,
                                  child: textFields(
                                      'Apellidos', apellidosController)),
                              const SizedBox(width: 30),
                              SizedBox(
                                  height: 50,
                                  width: constraints.maxWidth / 3 - 20,
                                  child: textFields('RFC', rfcController)),
                              const SizedBox(width: 30),
                              SizedBox(
                                      height: 50,
                                      width: constraints.maxWidth / 3 - 20,
                                      child: textFields(
                                          'Confirmar Contraseña', confirmarContrasenaController,
                                          obscureText: true)),
                            ],
                          ),
                          const SizedBox(height: 60),
                          Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: SizedBox(
                                      height: 50,
                                      child: textFields(
                                          'Usuario', usuarioController))),
                              const SizedBox(width: 30),
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: 50,
                                  child: DropdownButtonFormField<String>(
                                    value: departamento,
                                    items: <String>[
                                      'Taquilla',
                                      'Dulceria',
                                      'Cafeteria',
                                      'Limpieza',
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          departamento = newValue;
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      fillColor: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      filled: true,
                                      floatingLabelStyle: const TextStyle(
                                        color: Color.fromARGB(255, 75, 73, 73),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      labelStyle: const TextStyle(
                                        color: Color.fromARGB(255, 75, 73, 73),
                                      ),
                                      labelText: 'Departamento',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color:
                                                Color.fromARGB(255, 15, 15, 15),
                                            width: 1),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 30),
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xff14AE5C)),
                                    child: const Text(
                                      'Guardar Usuario',
                                      style:
                                          TextStyle(color: Color(0xffF5F5F5)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 60),
                          Row(
                            children: [
                              SizedBox(
                                  height: 50,
                                  width: constraints.maxWidth / 3 - 20,
                                  child: textFields('Cumpleaños', cumpleanosController),
                                ),
                              
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ))
          ],
        ),
      )),
    );
  }
}
