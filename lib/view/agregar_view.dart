import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/mascotaviewmodel.dart';

class AgregarView extends StatefulWidget {
  final int idUsuario;

  const AgregarView({super.key, required this.idUsuario});

  @override
  State<AgregarView> createState() => _AgregarViewState();
}

class _AgregarViewState extends State<AgregarView> {
  final TextEditingController controller = TextEditingController();
  String selectedTipo = 'perro';
  final TextEditingController tipoOtroController = TextEditingController();
  final TextEditingController edadController = TextEditingController();
  bool mostrarCampoOtro = false;

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MascotaViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Agregar Mascota")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration:
                  const InputDecoration(labelText: "Nombre de la mascota"),
            ),
            const SizedBox(height: 20),

            // Dropdown para tipo de mascota
            DropdownButtonFormField<String>(
              value: selectedTipo,
              decoration: const InputDecoration(labelText: "Tipo de mascota"),
              items: const [
                DropdownMenuItem(value: 'perro', child: Text('Perro')),
                DropdownMenuItem(value: 'gato', child: Text('Gato')),
                DropdownMenuItem(value: 'ave', child: Text('Ave')),
                DropdownMenuItem(value: 'otro', child: Text('Otro')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedTipo = value!;
                  mostrarCampoOtro = (value == 'otro');
                  if (!mostrarCampoOtro) {
                    tipoOtroController.clear();
                  }
                });
              },
            ),

            // Campo "otro" (solo si selecciona "otro")
            if (mostrarCampoOtro) ...[
              const SizedBox(height: 20),
              TextField(
                controller: tipoOtroController,
                decoration:
                    const InputDecoration(labelText: "Especificar tipo"),
              ),
            ],

            const SizedBox(height: 20),
            TextField(
              controller: edadController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Edad (opcional)"),
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("El nombre es obligatorio")),
                  );
                  return;
                }

                if (selectedTipo == 'otro' && tipoOtroController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Especifica el tipo de mascota")),
                  );
                  return;
                }

                final edad = edadController.text.isNotEmpty
                    ? int.tryParse(edadController.text)
                    : null;

                // Usar selectedTipo directamente (sin variable extra)
                vm.agregarMascota(
                  controller.text,
                  widget.idUsuario,
                  tipo: selectedTipo,
                  tipoOtro:
                      selectedTipo == 'otro' ? tipoOtroController.text : null,
                  edad: edad,
                );
                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }
}
