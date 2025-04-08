import 'package:flutter/material.dart';
import 'package:proyecto_cine_equipo3/Vista/Taquilla/SeleccionFuncion.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MenuTaquilla(),
    );
  }
}

class MenuTaquilla extends StatefulWidget {
  const MenuTaquilla({super.key});

  @override
  _MenuTaquillaState createState() => _MenuTaquillaState();
}

class _MenuTaquillaState extends State<MenuTaquilla> {
  Widget _buildSidebarButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(width: 15),
              Expanded(
                child: TextButton(
                  onPressed: onPressed,
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
        child: Row(
          children: [
            // Sidebar
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
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildSidebarButton(
                    icon: Icons.card_membership,
                    label: 'Membresias',
                    onPressed: () {},
                  ),
                  const Divider(
                    color: Colors.white,
                    thickness: 1,
                    indent: 12,
                    endIndent: 12,
                  ),
                  _buildSidebarButton(
                    icon: Icons.shopping_cart_rounded,
                    label: 'Taquilla',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SFunciones(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 30, top: 50, bottom: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bienvenido Sr(a) Usuario',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
                          ],
                          onSelected: (value) {
                            if (value == 0) {}
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Funciones programadas para hoy',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          border: TableBorder.all(color: Colors.grey),
                          headingTextStyle:
                              const TextStyle(color: Colors.white),
                          dataTextStyle: const TextStyle(color: Colors.white),
                          columns: const <DataColumn>[
                            DataColumn(label: Text('Titulo')),
                            DataColumn(label: Text('Horario')),
                            DataColumn(label: Text('Fecha')),
                            DataColumn(label: Text('Sala')),
                            DataColumn(label: Text('Tipo')),
                            DataColumn(label: Text('Idioma')),
                            DataColumn(label: Text('Estado')),
                          ],
                          rows: <DataRow>[
                            DataRow(
                              cells: <DataCell>[
                                DataCell(Text('Jurassic World: Rebirth')),
                                DataCell(Text('13:20')),
                                DataCell(Text('06-03-2025')),
                                DataCell(Text('8')),
                                DataCell(Text('Tradicional')),
                                DataCell(Text('Español')),
                                DataCell(Text('Finalizado')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
