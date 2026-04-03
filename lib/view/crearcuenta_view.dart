import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/usuarioviewmodel.dart';
import 'home_view.dart';

class CrearCuentaView extends StatefulWidget {
  const CrearCuentaView({super.key});

  @override
  State<CrearCuentaView> createState() => _CrearCuentaViewState();
}

class _CrearCuentaViewState extends State<CrearCuentaView> {
  final nombreController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? errorText;

  @override
  Widget build(BuildContext context) {
    final usuarioVM = Provider.of<UsuarioViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF96C9F2),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.asset(
                  'assets/logo.png',
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: 600,
                height: 400,
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        controller: nombreController,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          errorText: errorText,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration:
                            const InputDecoration(labelText: 'Contraseña'),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final error = await usuarioVM.crearCuenta(
                              nombreController.text,
                              emailController.text,
                              passwordController.text,
                            );
                            if (error != null) {
                              setState(() {
                                errorText = error;
                              });
                            } else {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const HomeView()));
                            }
                          },
                          child: const Text("Crear cuenta"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
