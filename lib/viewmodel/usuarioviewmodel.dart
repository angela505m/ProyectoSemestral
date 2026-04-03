import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UsuarioViewModel extends ChangeNotifier {
  Map<String, dynamic>? usuario;
  final String baseUrl = "http://192.168.1.17:3000";

  // LOGIN
  Future<String?> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return "Los campos no pueden estar vacíos";
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/login'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        usuario = json.decode(response.body);
        notifyListeners();
        return null; // Éxito
      } else {
        return "Email o contraseña incorrectos";
      }
    } catch (e) {
      return "Error al conectar con el servidor";
    }
  }

  // CREAR CUENTA
  Future<String?> crearCuenta(
      String nombre, String email, String password) async {
    if (nombre.isEmpty || email.isEmpty || password.isEmpty) {
      return "Todos los campos son obligatorios";
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/registrar'),
        headers: {"Content-Type": "application/json"},
        body: json
            .encode({"nombre": nombre, "email": email, "password": password}),
      );

      if (response.statusCode == 201) {
        usuario = json.decode(response.body);
        notifyListeners();
        return null; // Éxito
      } else {
        return "No se pudo crear la cuenta";
      }
    } catch (e) {
      return "Error al conectar con el servidor";
    }
  }

  // ========== NUEVOS MÉTODOS AGREGADOS ==========

  // CERRAR SESIÓN
  void cerrarSesion() {
    usuario = null;
    notifyListeners();
  }

  // VERIFICAR SI HAY USUARIO LOGUEADO
  bool get isLoggedIn => usuario != null;

  // OBTENER ID DEL USUARIO LOGUEADO
  int? get usuarioId {
    return usuario?['id_usuario'];
  }

  // OBTENER NOMBRE DEL USUARIO LOGUEADO
  String? get usuarioNombre {
    return usuario?['nombre'];
  }

  // OBTENER EMAIL DEL USUARIO LOGUEADO
  String? get usuarioEmail {
    return usuario?['email'];
  }
}
