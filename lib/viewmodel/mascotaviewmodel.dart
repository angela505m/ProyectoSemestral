import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../model/mascota.dart';

class MascotaViewModel extends ChangeNotifier {
  final List<Mascota> _mascotas = [];

  List<Mascota> get mascotas => _mascotas;

  String ubicacionActual = "Sin datos";
  double movimiento = 0.0;

  // 📍 GPS
  Future<void> obtenerUbicacion() async {
    bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) return;

    LocationPermission permiso = await Geolocator.requestPermission();
    if (permiso == LocationPermission.denied) return;

    Position posicion = await Geolocator.getCurrentPosition();

    ubicacionActual = "Lat: ${posicion.latitude}, Lon: ${posicion.longitude}";

    notifyListeners();
  }

  // 📱 Sensor
  void iniciarSensor() {
    accelerometerEvents.listen((event) {
      movimiento = event.x + event.y + event.z;
      notifyListeners();
    });
  }

  // CRUD
  void agregarMascota(String nombre) {
    _mascotas.add(Mascota(id: DateTime.now().toString(), nombre: nombre));
    notifyListeners();
  }

  void eliminarMascota(String id) {
    _mascotas.removeWhere((m) => m.id == id);
    notifyListeners();
  }
}
