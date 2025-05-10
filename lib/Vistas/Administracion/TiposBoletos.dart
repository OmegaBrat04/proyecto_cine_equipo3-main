import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_cine_equipo3/Modelo/ModeloTipoBoletoSimple.dart';
import 'package:proyecto_cine_equipo3/Controlador/Administracion/tipoboleto_controller.dart';

void main() {
  runApp(const TiposBoletos());
}

class TiposBoletos extends StatelessWidget {
  const TiposBoletos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Formulario(),
    );
  }
}

class Formulario extends StatefulWidget {
  const Formulario({super.key});

  @override
  _FormularioState createState() => _FormularioState();
}

class _FormularioState extends State<Formulario> {
  List<TipoBoletoSimple> boletos = [];
  final TextEditingController DescripcionController = TextEditingController();
  final TextEditingController Precio2DController = TextEditingController();
  final TextEditingController Precio3DController = TextEditingController();
  final TextEditingController fechaEspecialController = TextEditingController();
  bool usarFechaEspecial = false;
  bool _modoEdicion = false;
  int? _idEditando;
  bool _fechaEspecialSeleccionada = false;

  void limpiarCampos() {
    DescripcionController.clear();
    Precio2DController.clear();
    Precio3DController.clear();
    fechaEspecialController.clear();
    _modoEdicion = false;
    _idEditando = null;
    _fechaEspecialSeleccionada = false;
  }

  @override
  void initState() {
    super.initState();
    cargarBoletos();
  }

  Future<void> cargarBoletos() async {
    final lista = await ControladorBoletos.obtenerBoletos();
    setState(() {
      boletos = lista;
    });
  }

  Future<void> guardarBoleto() async {
    if (DescripcionController.text.trim().isEmpty ||
        Precio2DController.text.trim().isEmpty ||
        Precio3DController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('❗Completa todos los campos obligatorios')),
      );
      return;
    }

    final datos = {
      'nombre': DescripcionController.text.trim(),
      'precio_2d': double.tryParse(Precio2DController.text.trim()) ?? 0,
      'precio_3d': double.tryParse(Precio3DController.text.trim()) ?? 0,
      'fecha_especial':
          usarFechaEspecial && fechaEspecialController.text.trim().isNotEmpty
              ? fechaEspecialController.text.trim()
              : null,
    };

    final ok = await ControladorBoletos.agregarBoleto(datos);
    if (ok) {
      Navigator.pop(context);
      cargarBoletos();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Error al guardar boleto')),
      );
    }
  }

  void mostrarFormulario() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return AlertDialog(
            backgroundColor: const Color(0xff081C42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: const Text(
              'Añadir Boleto',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              height: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: DescripcionController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nombre del Boleto',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: Precio2DController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Precio del Boleto 2D',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: Precio3DController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Precio del Boleto 3D',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: usarFechaEspecial,
                        onChanged: (value) {
                          setModalState(() {
                            usarFechaEspecial = value!;
                            if (!usarFechaEspecial) {
                              fechaEspecialController.clear();
                            }
                          });
                        },
                      ),
                      const Text("Usar fecha especial",
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  if (usarFechaEspecial)
                    TextField(
                      controller: fechaEspecialController,
                      style: const TextStyle(color: Colors.white),
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          fechaEspecialController.text =
                              DateFormat('yyyy-MM-dd').format(picked);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Fecha Especial',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final datos = {
                    'nombre': DescripcionController.text.trim(),
                    'precio_2D':
                        double.tryParse(Precio2DController.text.trim()) ?? 0,
                    'precio_3D':
                        double.tryParse(Precio3DController.text.trim()) ?? 0,
                    'fecha_especial': _fechaEspecialSeleccionada &&
                            fechaEspecialController.text.isNotEmpty
                        ? fechaEspecialController.text
                        : null,
                  };

                  bool exito;
                  if (_modoEdicion && _idEditando != null) {
                    exito = await ControladorBoletos.editarBoleto(
                        _idEditando!, datos);
                  } else {
                    exito = await ControladorBoletos.agregarBoleto(datos);
                  }

                  if (exito) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('✅ Operación exitosa')));
                    limpiarCampos();
                    cargarBoletos();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('❌ Error al guardar')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff14AE5C),
                ),
                child: const Text(
                  'Guardar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
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
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Atras',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
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
            ),
            const SizedBox(height: 10),
            const Text(
              'Boletos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  border: TableBorder.all(color: Colors.grey),
                  headingTextStyle: const TextStyle(color: Colors.white),
                  dataTextStyle: const TextStyle(color: Colors.white),
                  columns: const [
                    DataColumn(label: Text('Descripcion')),
                    DataColumn(label: Text('Precio 2D')),
                    DataColumn(label: Text('Precio 3D')),
                    DataColumn(label: Text('Fecha Especial')),
                    DataColumn(label: Text('Opciones')),
                  ],
                  rows: boletos.map((b) {
                    return DataRow(cells: [
                      DataCell(Text(b.nombre)),
                      DataCell(Text('\$${b.precio2D.toStringAsFixed(2)}')),
                      DataCell(Text('\$${b.precio3D.toStringAsFixed(2)}')),
                      DataCell(
                        Text(b.fechaEspecial != null
                            ? DateFormat('dd/MM/yyyy')
                                .format(DateTime.parse(b.fechaEspecial!))
                            : '-'),
                      ),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              setState(() {
                                _modoEdicion = true;
                                _idEditando = b.id;
                                DescripcionController.text = b.nombre;
                                Precio2DController.text = b.precio2D.toString();
                                Precio3DController.text = b.precio3D.toString();
                                if (b.fechaEspecial != null) {
                                  _fechaEspecialSeleccionada = true;
                                  fechaEspecialController.text =
                                      b.fechaEspecial!.contains('T')
                                          ? DateFormat('yyyy-MM-dd').format(
                                              DateTime.parse(b.fechaEspecial!))
                                          : b.fechaEspecial!;
                                } else {
                                  _fechaEspecialSeleccionada = false;
                                  fechaEspecialController.clear();
                                }
                              });
                              mostrarFormulario();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () async {
                              final ok =
                                  await ControladorBoletos.eliminarBoleto(b.id);
                              if (ok) cargarBoletos();
                            },
                          ),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () {
                    limpiarCampos();
                    mostrarFormulario();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff14AE5C),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    minimumSize: const Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.more_horiz,
                          color: Color(0xffF5F5F5), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Agregar Boleto',
                        style:
                            TextStyle(color: Color(0xffF5F5F5), fontSize: 14),
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
