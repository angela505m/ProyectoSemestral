import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view/home_view.dart';
import 'viewmodel/mascotaviewmodel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MascotaViewModel(),
      child: MaterialApp(debugShowCheckedModeBanner: false, home: HomeView()),
    );
  }
}
