import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../model/mascota.dart';
import '../model/paseo.dart';
import '../model/ubicacion.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class MascotaViewModel extends ChangeNotifier {
  final List<Mascota> _mascotas = [];
  final List<Paseo> _paseos = [];
  final List<Ubicacion> _ubicaciones = [];

  List<Mascota> get mascotas => _mascotas;
  List<Paseo> get paseos => _paseos;
  List<Ubicacion> get ubicaciones => _ubicaciones;

  String ubicacionActual = "Sin datos";
  Paseo? paseoActivo;

  final String baseUrl = "http://192.168.1.28:3000";

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

  Future<void> eliminarMascota(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/mascotas/$id'));
    if (response.statusCode == 200) {
      _mascotas.removeWhere((m) => m.id == id);
      notifyListeners();
    } else {
      throw Exception("No se pudo eliminar la mascota");
    }
  }

  // Actualizar mascota (nuevo método)
  Future<void> actualizarMascota(
      int id, String nombre, String tipo, String? tipoOtro, int? edad) async {
    final mascota = {
      'nombre': nombre,
      'tipo': tipo,
      'tipo_otro': tipoOtro,
      'edad': edad,
    };

    final response = await http.put(
      Uri.parse('$baseUrl/mascotas/$id'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(mascota),
    );

    if (response.statusCode == 200) {
      final index = _mascotas.indexWhere((m) => m.id == id);
      if (index != -1) {
        _mascotas[index] = Mascota.fromJson(json.decode(response.body));
        notifyListeners();
      }
    } else {
      throw Exception("No se pudo actualizar la mascota");
    }
  }

  Future<void> obtenerUbicacion() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ubicacionActual = "Activa la ubicación del dispositivo";
      notifyListeners();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ubicacionActual = "Permiso denegado";
        notifyListeners();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ubicacionActual = "Permiso denegado permanentemente";
      notifyListeners();
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    ubicacionActual =
        "Lat: ${position.latitude.toStringAsFixed(6)}, Lon: ${position.longitude.toStringAsFixed(6)}";
    notifyListeners();

    if (paseoActivo != null) {
      await registrarUbicacionPaseo(
          paseoActivo!.id, position.latitude, position.longitude);
    }
  }

  Future<void> iniciarPaseo(int idMascota) async {
    final now = DateTime.now();
    final paseo = {
      'id_mascota': idMascota,
      'fecha': now.toIso8601String().split('T')[0],
      'hora_inicio':
          now.toIso8601String().replaceAll('T', ' ').substring(0, 19),
    };

    final response = await http.post(
      Uri.parse('$baseUrl/paseos'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(paseo),
    );

    if (response.statusCode == 201) {
      paseoActivo = Paseo.fromJson(json.decode(response.body));
      notifyListeners();
    }
  }

  Future<void> finalizarPaseo() async {
    if (paseoActivo == null) return;

    final now = DateTime.now();
    final duracion =
        now.difference(DateTime.parse(paseoActivo!.horaInicio)).inMinutes;

    final response = await http.put(
      Uri.parse('$baseUrl/paseos/${paseoActivo!.id}'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'hora_fin': now.toIso8601String().replaceAll('T', ' ').substring(0, 19),
        'duracion': duracion,
      }),
    );

    if (response.statusCode == 200) {
      paseoActivo = null;
      notifyListeners();
    }
  }

  Future<void> registrarUbicacionPaseo(
      int idPaseo, double lat, double lon) async {
    final ubicacion = {
      'id_paseo': idPaseo,
      'latitud': lat,
      'longitud': lon,
      'fecha_hora': DateTime.now()
          .toIso8601String()
          .replaceAll('T', ' ')
          .substring(0, 19),
    };

    await http.post(
      Uri.parse('$baseUrl/ubicaciones'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(ubicacion),
    );
  }

  void limpiarMascotas() {
    _mascotas.clear();
    _paseos.clear();
    _ubicaciones.clear();
    paseoActivo = null;
    notifyListeners();
  }
}
