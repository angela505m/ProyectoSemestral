import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/usuarioviewmodel.dart';
import 'crearcuenta_view.dart';
import 'home_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
                height: 350,
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
                      // EMAIL
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
                        ),
                      ),
                      const SizedBox(height: 25),
                      // CONTRASEÑA
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
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB7E3F6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          onPressed: () async {
                            final error = await usuarioVM.login(
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
                          child: const Text("Iniciar sesión",
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "¿No tienes cuenta?",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CrearCuentaView()),
                      );
                    },
                    child: const Text(
                      "Crear cuenta",
                      style: TextStyle(fontSize: 14),
                    ),
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
