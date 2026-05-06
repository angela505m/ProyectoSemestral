import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/recordatorio.dart';
import '../services/notification_service.dart';

class RecordatorioViewModel extends ChangeNotifier {
  final Map<int, List<Recordatorio>> _recordatoriosPorMascota = {};
  final NotificationService _notifications = NotificationService();
  final Map<int, Timer> _timers = {};

  List<Recordatorio> getRecordatorios(int idMascota) {
    return _recordatoriosPorMascota[idMascota] ?? [];
  }

  // ✅ IP CORRECTA
  final String baseUrl = "http://192.168.172.15:3000";

  Future<bool> _notificacionesGlobalActivadas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notificaciones_global') ?? true;
  }

  List<String> _diasStringToList(String dias) {
    final mapDias = {
      'Lunes': 'Monday',
      'Martes': 'Tuesday',
      'Miércoles': 'Wednesday',
      'Jueves': 'Thursday',
      'Viernes': 'Friday',
      'Sábado': 'Saturday',
      'Domingo': 'Sunday',
    };
    final List<String> result = [];
    final partes = dias.split(',');
    for (var p in partes) {
      if (mapDias.containsKey(p)) {
        result.add(mapDias[p]!);
      }
    }
    return result;
  }

  String _weekdayToString(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return 'Monday';
    }
  }

  Future<void> _scheduleRecordatorio(Recordatorio r) async {
    if (!(await _notificacionesGlobalActivadas())) return;
    if (!r.activo) return;

    if (_timers.containsKey(r.id)) {
      _timers[r.id]?.cancel();
      _timers.remove(r.id);
    }

    final horaParts = r.hora.split(':');
    final targetTime = TimeOfDay(
      hour: int.parse(horaParts[0]),
      minute: int.parse(horaParts[1]),
    );

    final diasList = _diasStringToList(r.dias);
    if (diasList.isEmpty) return;

    final now = DateTime.now();
    DateTime? targetDate;

    for (int i = 0; i <= 7; i++) {
      final testDate = now.add(Duration(days: i));
      final weekdayName = _weekdayToString(testDate.weekday);
      if (diasList.contains(weekdayName)) {
        targetDate = DateTime(
          testDate.year,
          testDate.month,
          testDate.day,
          targetTime.hour,
          targetTime.minute,
        );
        if (targetDate.isAfter(now)) break;
      }
    }

    if (targetDate == null) return;

    final delay = targetDate.difference(now);
    if (delay.inMilliseconds <= 0) return;

    final timer = Timer(delay, () async {
      await _notifications.showNow(
        id: r.id,
        title: 'Recordatorio de ${r.tipo}',
        body: 'Es hora de ${r.tipo} para tu mascota',
      );
      _reprogramarSiguienteSemana(r);
    });
    _timers[r.id] = timer;
  }

  void _reprogramarSiguienteSemana(Recordatorio r) {
    if (!r.activo) return;
    final now = DateTime.now();
    final horaParts = r.hora.split(':');
    final targetTime = TimeOfDay(
      hour: int.parse(horaParts[0]),
      minute: int.parse(horaParts[1]),
    );
    DateTime nextDate = DateTime(
      now.year,
      now.month,
      now.day + 7,
      targetTime.hour,
      targetTime.minute,
    );
    final delay = nextDate.difference(now);
    if (delay.inMilliseconds > 0) {
      final timer = Timer(delay, () async {
        await _notifications.showNow(
          id: r.id,
          title: 'Recordatorio de ${r.tipo}',
          body: 'Es hora de ${r.tipo} para tu mascota',
        );
        _reprogramarSiguienteSemana(r);
      });
      _timers[r.id] = timer;
    }
  }

  Future<void> _cancelRecordatorio(int id) async {
    if (_timers.containsKey(id)) {
      _timers[id]?.cancel();
      _timers.remove(id);
    }
    await _notifications.cancel(id);
  }

  Future<void> actualizarEstadoGlobal() async {
    final globalActivo = await _notificacionesGlobalActivadas();
    if (!globalActivo) {
      for (var timer in _timers.values) {
        timer.cancel();
      }
      _timers.clear();
      for (var lista in _recordatoriosPorMascota.values) {
        for (var r in lista) {
          await _notifications.cancel(r.id);
        }
      }
    } else {
      for (var lista in _recordatoriosPorMascota.values) {
        for (var r in lista) {
          if (r.activo) {
            await _scheduleRecordatorio(r);
          }
        }
      }
    }
    notifyListeners();
  }

  Future<void> cargarRecordatoriosPorMascota(int idMascota) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/recordatorios?mascota=$idMascota'));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final recordatorios =
            data.map((json) => Recordatorio.fromJson(json)).toList();
        _recordatoriosPorMascota[idMascota] = recordatorios;
        for (var r in recordatorios) {
          if (r.activo) {
            await _scheduleRecordatorio(r);
          }
        }
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
      await _scheduleRecordatorio(nuevo);
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
          if (activo) {
            await _scheduleRecordatorio(lista[index]);
          } else {
            await _cancelRecordatorio(idRecordatorio);
          }
          notifyListeners();
        }
      }
    }
  }

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
          await _cancelRecordatorio(idRecordatorio);
          if (activo) {
            await _scheduleRecordatorio(actualizado);
          }
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
        await _cancelRecordatorio(idRecordatorio);
        notifyListeners();
      }
    }
  }

  void limpiarRecordatorios() {
    for (var timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _recordatoriosPorMascota.clear();
    notifyListeners();
  }
}
