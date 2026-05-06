import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/mascotaviewmodel.dart';

class AgregarView extends StatefulWidget {
  final int idUsuario;
  final VoidCallback? onClose;

  const AgregarView({super.key, required this.idUsuario, this.onClose});

  @override
  State<AgregarView> createState() => _AgregarViewState();
}

class _AgregarViewState extends State<AgregarView> {
  final TextEditingController controller = TextEditingController();
  String selectedTipo = 'perro';
  final TextEditingController tipoOtroController = TextEditingController();
  final TextEditingController edadController = TextEditingController();
  bool mostrarCampoOtro = false;

  final Map<String, IconData> tipoIconos = {
    'perro': Icons.pets,
    'gato': Icons.pets,
    'ave': Icons.flutter_dash,
    'otro': Icons.help_outline,
  };

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MascotaViewModel>(context, listen: false);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      elevation: 8,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: SizedBox(
        width: 500, // Ancho fijo más pequeño
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo centrado
              Center(
                child: Image.asset('assets/logo.png', height: 200),
              ),
              const SizedBox(height: 5),
              // Texto debajo del logo
              const Text(
                "Agregar mascota",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF96C9F2),
                ),
              ),
              const SizedBox(height: 25),
              // Campo nombre
              TextField(
                controller: controller,
                cursorColor: const Color(0xFF96C9F2),
                decoration: InputDecoration(
                  labelText: "Nombre",
                  floatingLabelStyle: const TextStyle(color: Color(0xFF96C9F2)),
                  prefixIcon: const Icon(Icons.badge, color: Color(0xFF96C9F2)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        const BorderSide(color: Color(0xFF96C9F2), width: 2),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Dropdown tipo (sin icono en el borde, solo en los items)
              DropdownButtonFormField<String>(
                initialValue: selectedTipo,
                decoration: InputDecoration(
                  labelText: "Tipo",
                  floatingLabelStyle: const TextStyle(color: Color(0xFF96C9F2)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        const BorderSide(color: Color(0xFF96C9F2), width: 2),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'perro',
                    child: Row(children: [
                      Icon(Icons.pets, color: Color(0xFF96C9F2)),
                      SizedBox(width: 8),
                      Text('Perro')
                    ]),
                  ),
                  DropdownMenuItem(
                    value: 'gato',
                    child: Row(children: [
                      Icon(Icons.pets, color: Color(0xFF96C9F2)),
                      SizedBox(width: 8),
                      Text('Gato')
                    ]),
                  ),
                  DropdownMenuItem(
                    value: 'ave',
                    child: Row(children: [
                      Icon(Icons.flutter_dash, color: Color(0xFF96C9F2)),
                      SizedBox(width: 8),
                      Text('Ave')
                    ]),
                  ),
                  DropdownMenuItem(
                    value: 'otro',
                    child: Row(children: [
                      Icon(Icons.help_outline, color: Color(0xFF96C9F2)),
                      SizedBox(width: 8),
                      Text('Otro')
                    ]),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedTipo = value!;
                    mostrarCampoOtro = (value == 'otro');
                    if (!mostrarCampoOtro) tipoOtroController.clear();
                  });
                },
              ),
              if (mostrarCampoOtro) ...[
                const SizedBox(height: 15),
                TextField(
                  controller: tipoOtroController,
                  cursorColor: const Color(0xFF96C9F2),
                  decoration: InputDecoration(
                    labelText: "Especificar",
                    floatingLabelStyle:
                        const TextStyle(color: Color(0xFF96C9F2)),
                    prefixIcon:
                        const Icon(Icons.edit, color: Color(0xFF96C9F2)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:
                          const BorderSide(color: Color(0xFF96C9F2), width: 2),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 15),
              TextField(
                controller: edadController,
                keyboardType: TextInputType.number,
                cursorColor: const Color(0xFF96C9F2),
                decoration: InputDecoration(
                  labelText: "Edad (años)",
                  floatingLabelStyle: const TextStyle(color: Color(0xFF96C9F2)),
                  prefixIcon: const Icon(Icons.cake, color: Color(0xFF96C9F2)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        const BorderSide(color: Color(0xFF96C9F2), width: 2),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Botones centrados
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      if (widget.onClose != null) {
                        widget.onClose!();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                    ),
                    child: const Text("Cancelar"),
                  ),
                  const SizedBox(width: 25),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB7E3F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 15),
                    ),
                    onPressed: () async {
                      if (controller.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("El nombre es obligatorio")),
                        );
                        return;
                      }
                      if (selectedTipo == 'otro' &&
                          tipoOtroController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Especifica el tipo")),
                        );
                        return;
                      }
                      final edad = edadController.text.isNotEmpty
                          ? int.tryParse(edadController.text)
                          : null;
                      await vm.agregarMascota(
                        controller.text,
                        widget.idUsuario,
                        tipo: selectedTipo,
                        tipoOtro: selectedTipo == 'otro'
                            ? tipoOtroController.text
                            : null,
                        edad: edad,
                      );
                      if (widget.onClose != null) {
                        widget.onClose!();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Guardar",
                        style: TextStyle(color: Colors.black87)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
