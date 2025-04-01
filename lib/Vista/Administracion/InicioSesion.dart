import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: InicioSesion(),
  ));
}

class InicioSesion extends StatefulWidget {
  const InicioSesion({super.key});
  @override
  _InicioSesionState createState() => _InicioSesionState();
}

class _InicioSesionState extends State<InicioSesion> {
  bool contrasenaVisible = false;
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
        child: Row(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 60,
                    left: 80,
                    child: circle(140, Colors.blue.withOpacity(0.15)),
                  ),
                  Positioned(
                    bottom: 100,
                    right: 100,
                    child: circle(100, Colors.blueAccent.withOpacity(0.2)),
                  ),
                  Positioned(
                    top: 150,
                    right: 30,
                    child: circle(60, Colors.cyanAccent.withOpacity(0.1)),
                  ),
                  Positioned(
                    bottom: 60,
                    left: 40,
                    child: circle(80, Colors.lightBlue.withOpacity(0.15)),
                  ),
                  Container(
                    width: 320,
                    height: 320,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF081C42),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF0BD4CF),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF0665A4),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage('images/PICNITO LOGO.jpeg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Usuario',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Ingrese su usuario',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Contraseña',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  contrasenaVisible = !contrasenaVisible;
                                });
                              },
                              icon: Icon(
                                contrasenaVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.black,
                              )),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('INGRESAR'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
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

  Widget circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
