import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(settings);
  }

  // Solicitar permiso de notificaciones (usando permission_handler)
  Future<bool> requestPermission() async {
    // Para Android 13+, solicita POST_NOTIFICATIONS
    final status = await Permission.notification.request();
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      // El usuario denegó, podemos mostrar un mensaje
      return false;
    } else if (status.isPermanentlyDenied) {
      // El usuario denegó permanentemente, hay que abrir ajustes
      openAppSettings();
      return false;
    }
    return false;
  }

  // Notificación inmediata (para prueba)
  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'test_channel',
      'Canal de Prueba',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails details =
        NotificationDetails(android: androidDetails);
    await _flutterLocalNotificationsPlugin.show(
      8888,
      '🔔 PRUEBA INMEDIATA',
      'Si ves esto, funciona',
      details,
    );
  }

  // Mostrar notificación en el momento (usado por el Timer)
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'recordatorios_channel',
      'Recordatorios',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails details =
        NotificationDetails(android: androidDetails);
    await _flutterLocalNotificationsPlugin.show(id, title, body, details);
  }

  // Cancelar notificación
  Future<void> cancel(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}
