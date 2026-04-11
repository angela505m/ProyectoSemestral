import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/recordatorio.dart';

class RecordatorioViewModel extends ChangeNotifier {
  final Map<int, List<Recordatorio>> _recordatoriosPorMascota = {};

  List<Recordatorio> getRecordatorios(int idMascota) {
    return _recordatoriosPorMascota[idMascota] ?? [];
  }

  final String baseUrl = "http://192.168.1.28:3000";

  Future<void> cargarRecordatoriosPorMascota(int idMascota) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/recordatorios?mascota=$idMascota'));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final recordatorios =
            data.map((json) => Recordatorio.fromJson(json)).toList();
        _recordatoriosPorMascota[idMascota] = recordatorios;
        notifyListeners();
      } else {
        _recordatoriosPorMascota[idMascota] = [];
        notifyListeners();
      }
    } catch (e) {
      _recordatoriosPorMascota[idMascota] = [];
      notifyListeners();
    }
  }

  Future<void> agregarRecordatorio(
      int idMascota, String tipo, String hora, String dias) async {
    final recordatorio = {
      'id_mascota': idMascota,
      'tipo': tipo,
      'hora': hora,
      'dias': dias,
      'activo': true,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/recordatorios'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(recordatorio),
    );

    if (response.statusCode == 201) {
      final nuevo = Recordatorio.fromJson(json.decode(response.body));
      final lista = _recordatoriosPorMascota[idMascota] ?? [];
      lista.add(nuevo);
      _recordatoriosPorMascota[idMascota] = lista;
      notifyListeners();
    }
  }

  Future<void> toggleRecordatorio(
      int idMascota, int idRecordatorio, bool activo) async {
    final response = await http.put(
      Uri.parse('$baseUrl/recordatorios/$idRecordatorio'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'activo': activo}),
    );

    if (response.statusCode == 200) {
      final lista = _recordatoriosPorMascota[idMascota];
      if (lista != null) {
        final index = lista.indexWhere((r) => r.id == idRecordatorio);
        if (index != -1) {
          lista[index].activo = activo;
          _recordatoriosPorMascota[idMascota] = lista;
          notifyListeners();
        }
      }
    }
  }

  // NUEVO: Actualizar todos los campos del recordatorio
  Future<void> actualizarRecordatorio(int idMascota, int idRecordatorio,
      String tipo, String hora, String dias, bool activo) async {
    final recordatorio = {
      'tipo': tipo,
      'hora': hora,
      'dias': dias,
      'activo': activo,
    };

    final response = await http.put(
      Uri.parse('$baseUrl/recordatorios/$idRecordatorio'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(recordatorio),
    );

    if (response.statusCode == 200) {
      final actualizado = Recordatorio.fromJson(json.decode(response.body));
      final lista = _recordatoriosPorMascota[idMascota];
      if (lista != null) {
        final index = lista.indexWhere((r) => r.id == idRecordatorio);
        if (index != -1) {
          lista[index] = actualizado;
          _recordatoriosPorMascota[idMascota] = lista;
          notifyListeners();
        }
      }
    } else {
      throw Exception("No se pudo actualizar el recordatorio");
    }
  }

  Future<void> eliminarRecordatorio(int idMascota, int idRecordatorio) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/recordatorios/$idRecordatorio'));
    if (response.statusCode == 200) {
      final lista = _recordatoriosPorMascota[idMascota];
      if (lista != null) {
        lista.removeWhere((r) => r.id == idRecordatorio);
        _recordatoriosPorMascota[idMascota] = lista;
        notifyListeners();
      }
    }
  }

  void limpiarRecordatorios() {
    _recordatoriosPorMascota.clear();
    notifyListeners();
  }
}
