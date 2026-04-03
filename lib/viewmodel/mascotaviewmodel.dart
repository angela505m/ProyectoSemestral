import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../model/mascota.dart';
import 'dart:convert';

class MascotaViewModel extends ChangeNotifier {
  final List<Mascota> _mascotas = [];

  List<Mascota> get mascotas => _mascotas;

  String ubicacionActual = "Sin datos";

  // URL de tu backend (reemplazar por la real)
  final String baseUrl = "http://192.168.1.17:3000";

  // OBTENER MASCOTAS DE UN USUARIO
  Future<void> cargarMascotas(int idUsuario) async {
    final response =
        await http.get(Uri.parse('$baseUrl/mascotas?user=$idUsuario'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      _mascotas.clear();
      _mascotas.addAll(data.map((json) => Mascota.fromJson(json)).toList());
      notifyListeners();
    } else {
      throw Exception("Error al cargar mascotas");
    }
  }

  // AGREGAR MASCOTA
  Future<void> agregarMascota(String nombre, int idUsuario,
      {String tipo = "otro", String? tipoOtro, int? edad}) async {
    final mascota = {
      'nombre': nombre,
      'tipo': tipo,
      'tipo_otro': tipoOtro,
      'edad': edad,
      'id_usuario': idUsuario,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/mascotas'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(mascota),
    );

    if (response.statusCode == 201) {
      final nuevaMascota = Mascota.fromJson(json.decode(response.body));
      _mascotas.add(nuevaMascota);
      notifyListeners();
    } else {
      throw Exception("No se pudo agregar la mascota");
    }
  }

  // ELIMINAR MASCOTA
  Future<void> eliminarMascota(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/mascotas/$id'));
    if (response.statusCode == 200) {
      _mascotas.removeWhere((m) => m.id == id);
      notifyListeners();
    } else {
      throw Exception("No se pudo eliminar la mascota");
    }
  }

  // UBICACION
  Future<void> obtenerUbicacion() async {
    // Tu código de Geolocator
  }

  // ========== NUEVOS MÉTODOS AGREGADOS ==========

  // LIMPIAR LISTA DE MASCOTAS (al cerrar sesión)
  void limpiarMascotas() {
    _mascotas.clear();
    notifyListeners();
  }

  // ACTUALIZAR UBICACIÓN
  void actualizarUbicacion(String nuevaUbicacion) {
    ubicacionActual = nuevaUbicacion;
    notifyListeners();
  }
}
