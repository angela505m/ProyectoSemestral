import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view/home_view.dart';
import 'view/login_view.dart';
import 'viewmodel/mascotaviewmodel.dart';
import 'viewmodel/usuarioviewmodel.dart'; // <-- nuevo

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MascotaViewModel()),
        ChangeNotifierProvider(create: (_) => UsuarioViewModel()), // <-- nuevo
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginView(),
        routes: {
          '/home': (context) => const HomeView(),
        },
      ),
    );
  }
}
