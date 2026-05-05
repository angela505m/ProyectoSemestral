import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../model/mascota.dart';
import '../model/paseo.dart';
import '../model/ubicacion.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MascotaViewModel extends ChangeNotifier {
  final List<Mascota> _mascotas = [];
  final List<Paseo> _paseos = [];
  final List<Ubicacion> _ubicaciones = [];

  List<Mascota> get mascotas => _mascotas;
  List<Paseo> get paseos => _paseos;
  List<Ubicacion> get ubicaciones => _ubicaciones;

  String ubicacionActual = "Sin datos";
  Paseo? paseoActivo;
  LatLng? _currentPosition;
  LatLng? get currentPosition => _currentPosition;

  // 🟢 Timer para el registro automático de ubicación durante el paseo
  Timer? _ubicacionTimer;

  final String baseUrl = "http://192.168.1.9:3000";

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

  // --------------------------------------------------------------
  // 🟢 OBTENER UBICACIÓN MANUAL (también actualiza la posición para el mapa)
  // --------------------------------------------------------------
  Future<void> obtenerUbicacion() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ubicacionActual = "Activa la ubicación del dispositivo";
      _currentPosition = null;
      notifyListeners();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ubicacionActual = "Permiso denegado";
        _currentPosition = null;
        notifyListeners();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ubicacionActual = "Permiso denegado permanentemente";
      _currentPosition = null;
      notifyListeners();
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    final lat = position.latitude;
    final lon = position.longitude;

    ubicacionActual =
        "Lat: ${lat.toStringAsFixed(6)}, Lon: ${lon.toStringAsFixed(6)}";
    _currentPosition = LatLng(lat, lon);
    notifyListeners();

    // Si hay un paseo activo, registra también la ubicación en ese momento
    if (paseoActivo != null) {
      await registrarUbicacionPaseo(paseoActivo!.id, lat, lon);
    }
  }

  // --------------------------------------------------------------
  // 🟢 INICIAR PASEO (con registro automático cada 10 segundos)
  // --------------------------------------------------------------
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

      // 🔁 Arrancar el registro automático de ubicación
      _iniciarRegistroAutomatico();
    }
  }

  // --------------------------------------------------------------
  // 🟢 FINALIZAR PASEO (detiene el registro automático)
  // --------------------------------------------------------------
  Future<void> finalizarPaseo() async {
    if (paseoActivo == null) return;

    // 🛑 Detener el timer automático
    _detenerRegistroAutomatico();

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

  // --------------------------------------------------------------
  // 🟢 REGISTRAR UBICACIÓN (manual o automática)
  // --------------------------------------------------------------
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

  // --------------------------------------------------------------
  // 🟢 MÉTODOS PRIVADOS PARA EL REGISTRO AUTOMÁTICO
  // --------------------------------------------------------------
  void _iniciarRegistroAutomatico() {
    _ubicacionTimer?.cancel(); // por si acaso
    _ubicacionTimer =
        Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (paseoActivo == null) {
        // Si ya no hay paseo activo, nos detenemos
        timer.cancel();
        _ubicacionTimer = null;
        return;
      }

      // Verificar permisos de ubicación
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) return;

      try {
        final position = await Geolocator.getCurrentPosition();
        await registrarUbicacionPaseo(
          paseoActivo!.id,
          position.latitude,
          position.longitude,
        );

        // También actualizamos el texto de ubicación actual en la UI
        ubicacionActual =
            "Paseo en curso - Lat: ${position.latitude.toStringAsFixed(6)}, Lon: ${position.longitude.toStringAsFixed(6)}";
        notifyListeners();
      } catch (e) {
        print("Error registrando ubicación automática: $e");
      }
    });
  }

  void _detenerRegistroAutomatico() {
    _ubicacionTimer?.cancel();
    _ubicacionTimer = null;
  }

  // --------------------------------------------------------------
  // 🟢 LIMPIAR (cierra sesión)
  // --------------------------------------------------------------
  void limpiarMascotas() {
    _detenerRegistroAutomatico(); // asegurar que el timer se detenga
    _mascotas.clear();
    _paseos.clear();
    _ubicaciones.clear();
    paseoActivo = null;
    _currentPosition = null;
    notifyListeners();
  }
}
