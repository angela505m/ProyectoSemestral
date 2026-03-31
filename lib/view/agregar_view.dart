import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/mascotaviewmodel.dart';

class AgregarView extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  AgregarView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MascotaViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text("Agregar Mascota")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(labelText: "Nombre de la mascota"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isEmpty) return;

                vm.agregarMascota(controller.text);
                Navigator.pop(context);
              },
              child: Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }
}
