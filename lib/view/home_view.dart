import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/mascotaviewmodel.dart';
import 'agregar_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MascotaViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text("PetCare 🐾")),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // 🔥 SENSORES
            Text("Ubicación: ${vm.ubicacionActual}"),
            Text("Movimiento: ${vm.movimiento.toStringAsFixed(2)}"),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: vm.obtenerUbicacion,
                  child: Text("GPS"),
                ),
                ElevatedButton(
                  onPressed: vm.iniciarSensor,
                  child: Text("Sensor"),
                ),
              ],
            ),

            SizedBox(height: 10),

            // 📋 LISTA
            Expanded(
              child: vm.mascotas.isEmpty
                  ? Center(child: Text("No hay mascotas"))
                  : ListView.builder(
                      itemCount: vm.mascotas.length,
                      itemBuilder: (context, index) {
                        final mascota = vm.mascotas[index];

                        return Card(
                          child: ListTile(
                            title: Text(mascota.nombre),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => vm.eliminarMascota(mascota.id),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AgregarView()),
          );
        },
      ),
    );
  }
}
