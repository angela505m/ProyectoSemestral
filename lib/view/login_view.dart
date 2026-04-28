import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
                  "Bienvenido a PetCare",
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
                            final error = await usuarioVM.login(
                              emailController.text,
                              passwordController.text,
                            );
                            if (error != null) {
                              setState(() {
                                errorText = error;
                              });
                            } else {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final acepto =
                                  prefs.getBool('politica_aceptada') ?? false;
                              if (!acepto) {
                                _mostrarPoliticaPrivacidad(context, prefs);
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const HomeView()),
                                );
                              }
                            }
                          },
                          child: const Text("Iniciar sesión",
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
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

  void _mostrarPoliticaPrivacidad(
      BuildContext context, SharedPreferences prefs) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text(
          "Política de Privacidad",
          style:
              TextStyle(color: Color(0xFF96C9F2), fontWeight: FontWeight.bold),
        ),
        content: const SingleChildScrollView(
          child: Text(
            "PetCare respeta tu privacidad.\n\n"
            "Recopilamos:\n"
            "• Datos de tu mascota (nombre, tipo, edad)\n"
            "• Ubicación GPS durante los paseos (solo con tu permiso)\n"
            "• Recordatorios que configures\n\n"
            "No compartimos tus datos con terceros.\n\n"
            "Al aceptar, confirmas que has leído nuestra política.\n\n"
            "Puedes solicitar la eliminación de tus datos en cualquier momento desde la configuración de la app.",
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB7E3F6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () async {
              await prefs.setBool('politica_aceptada', true);
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeView()),
              );
            },
            child:
                const Text("Aceptar", style: TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
