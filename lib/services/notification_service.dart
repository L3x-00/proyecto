import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Envuelve flutter_local_notifications para mostrar notificaciones en el
/// panel de notificaciones del teléfono (Android/iOS) a partir de eventos
/// recibidos por Pusher (ver PusherConfig).
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _channelId = 'ordenes_channel';
  static const String _channelName = 'Órdenes de reparación';
  static const String _channelDescription =
      'Notificaciones de nuevas órdenes de reparación asignadas';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: settings);

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      ),
    );
    await androidPlugin?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    await init();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(id: id, title: title, body: body, notificationDetails: details);
  }

  /// Muestra la notificación de "nueva-orden" recibida por Pusher
  /// (ver eventos 'admin-notificaciones', 'cliente-{id}', 'mecanico-{id}'
  /// disparados por OrdenReparacionModelo::alta() en el backend).
  Future<void> showNuevaOrden(dynamic rawData, {required String title}) async {
    final Map data = rawData is String ? jsonDecode(rawData) : rawData as Map;
    final idOrden = int.tryParse(data['idOrden'].toString()) ?? 0;
    final vehiculo = (data['vehiculo'] ?? '').toString();
    final placas = (data['placas'] ?? '').toString();

    final placasSufijo = placas.isNotEmpty ? ' ($placas)' : '';
    final body = 'Orden #$idOrden · $vehiculo$placasSufijo';

    await show(id: idOrden, title: title, body: body);
  }
}
