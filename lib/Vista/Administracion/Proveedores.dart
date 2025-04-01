import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'RegistrarFunciones.dart';
import 'RegistrarPeliculas.dart';

void main() {
  runApp(const Proveedores());
}

class Proveedores extends StatelessWidget {
  const Proveedores({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: ListaProveedores(),
      ),
    );
  }
}

class ListaProveedores extends StatefulWidget {
  const ListaProveedores({super.key});

  @override
  _ListaProveedoresState createState() => _ListaProveedoresState();
}

class _ListaProveedoresState extends State<ListaProveedores> {
  final TextEditingController buscadorController = TextEditingController();

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
                        onPressed: () {},
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
                          hintText: 'Buscar por Nombre...',
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.white),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (String value) {},
                      ),
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
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    const Text(
                      'Proveedores',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DataTable(
                      border: TableBorder.all(color: Colors.grey),
                      headingTextStyle: const TextStyle(color: Colors.white),
                      dataTextStyle: const TextStyle(color: Colors.white),
                      columns: const <DataColumn>[
                        DataColumn(label: Text('Nombre')),
                        DataColumn(label: Text('Telefono')),
                        DataColumn(label: Text('Correo')),
                        DataColumn(label: Text('Direccion')),
                        DataColumn(label: Text('RFC')),
                        DataColumn(label: Text('Opciones')),
                      ],
                      rows: <DataRow>[
                        DataRow(
                          cells: <DataCell>[
                            DataCell(Text('FEMSA')),
                            DataCell(Text('+52 833 123 4567')),
                            DataCell(Text('GrupoFEMSA2025@gmail.com')),
                            DataCell(Text('Av. Universidad #123')),
                            DataCell(Text('FEMSA123456')),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.white),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.white),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                        Icon(EvaIcons.peopleOutline,
                            color: Color(0xffF5F5F5), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Nuevo Proveedor',
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
