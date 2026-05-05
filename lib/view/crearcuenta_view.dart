import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/usuarioviewmodel.dart';
import 'login_view.dart';
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
    final screenSize = MediaQuery.of(context).size;
    final isSmall = screenSize.width < 400;
    final logoSize = isSmall ? 180.0 : 220.0;
    final containerPadding = isSmall ? 24.0 : 32.0;

    return Scaffold(
      backgroundColor: const Color(0xFF96C9F2),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                    'assets/logo.png',
                    height: logoSize,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Crea tu cuenta",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: EdgeInsets.all(containerPadding),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
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
                      // Campo NOMBRE
                      TextField(
                        controller: nombreController,
                        cursorColor: const Color(0xFF96C9F2),
                        decoration: InputDecoration(
                          labelText: 'Nombre',
                          floatingLabelStyle:
                              const TextStyle(color: Color(0xFF96C9F2)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                color: Color(0xFF96C9F2), width: 2),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Campo EMAIL
                      TextField(
                        controller: emailController,
                        cursorColor: const Color(0xFF96C9F2),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          floatingLabelStyle:
                              const TextStyle(color: Color(0xFF96C9F2)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                color: Color(0xFF96C9F2), width: 2),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          errorText: errorText,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Campo CONTRASEÑA
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        cursorColor: const Color(0xFF96C9F2),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          floatingLabelStyle:
                              const TextStyle(color: Color(0xFF96C9F2)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                color: Color(0xFF96C9F2), width: 2),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 25),
                      // Botón CREAR CUENTA
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB7E3F6),
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
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
                                    builder: (_) => const HomeView()),
                              );
                            }
                          },
                          child: const Text("Crear cuenta",
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Enlace para volver al login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "¿Ya tienes cuenta?",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginView()),
                        );
                      },
                      child: const Text(
                        "Iniciar sesión",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
