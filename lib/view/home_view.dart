import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/mascotaviewmodel.dart';
import '../viewmodel/usuarioviewmodel.dart';
import 'agregar_view.dart';
import 'login_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MascotaViewModel>(context);
    final usuarioVM = Provider.of<UsuarioViewModel>(context, listen: false);

    // Cargar mascotas cuando se abre la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final idUsuario = usuarioVM.usuarioId;
      if (idUsuario != null) {
        vm.cargarMascotas(idUsuario);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("PetCare 🐾"),
        actions: [
          // Mostrar nombre del usuario
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                usuarioVM.usuarioNombre ?? '',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          // Botón de cerrar sesión
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              _confirmarCerrarSesion(context, usuarioVM);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text("Ubicación: ${vm.ubicacionActual}"),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: vm.obtenerUbicacion,
              child: const Text("Obtener ubicación"),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: vm.mascotas.isEmpty
                  ? const Center(child: Text("No hay mascotas"))
                  : ListView.builder(
                      itemCount: vm.mascotas.length,
                      itemBuilder: (context, index) {
                        final mascota = vm.mascotas[index];
                        return Card(
                          child: ListTile(
                            title: Text(mascota.nombre),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
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
        child: const Icon(Icons.add),
        onPressed: () {
          final idUsuario = usuarioVM.usuarioId;
          if (idUsuario != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AgregarView(idUsuario: idUsuario),
              ),
            );
          }
        },
      ),
    );
  }

  // Función para confirmar el cierre de sesión
  void _confirmarCerrarSesion(
      BuildContext context, UsuarioViewModel usuarioVM) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Cerrar sesión"),
          content: const Text("¿Estás seguro de que deseas cerrar sesión?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                _cerrarSesion(context, usuarioVM);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text("Cerrar sesión"),
            ),
          ],
        );
      },
    );
  }

  // Función para cerrar sesión
  void _cerrarSesion(BuildContext context, UsuarioViewModel usuarioVM) {
    // Limpiar los datos del usuario
    usuarioVM.cerrarSesion();

    // Limpiar las mascotas
    final mascotaVM = Provider.of<MascotaViewModel>(context, listen: false);
    mascotaVM.limpiarMascotas();

    // Navegar al LoginView y eliminar el historial
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false,
    );
  }
}
