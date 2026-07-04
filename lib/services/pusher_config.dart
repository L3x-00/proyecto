import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'dart:developer';

/// Wrapper sobre pusher_channels_flutter. El plugin expone una única conexión
/// nativa (singleton), así que la conexión/init solo se hace una vez para
/// toda la app: cada pantalla puede suscribirse a su propio canal sin pisar
/// la suscripción de otras pantallas que sigan montadas (p. ej. el home de
/// admin escuchando "admin-notificaciones" mientras se navega a la pantalla
/// de seguimiento de una orden, que escucha "orden-{id}").
class PusherConfig {
  static final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  static bool _connected = false;

  String? _channelName;

  Future<void> initPusher({
    required String channelName,
    required String eventName,
    required Function(PusherEvent) onEventTriggered,
  }) async {
    try {
      _channelName = channelName;

      if (!_connected) {
        await _pusher.init(
          apiKey: "24883b4239d5fad125df",
          cluster: "mt1",
          onConnectionStateChange: (currentState, previousState) {
            log("Conexión: $previousState -> $currentState");
          },
          onError: (message, code, e) {
            log("Error Pusher: $message (Código: $code)");
          },
        );
        await _pusher.connect();
        _connected = true;
      }

      await _pusher.subscribe(
        channelName: channelName,
        onEvent: (dynamic event) {
          final pusherEvent = event as PusherEvent;
          if (pusherEvent.eventName == eventName) {
            onEventTriggered(pusherEvent);
          }
        },
        onSubscriptionSucceeded: (dynamic data) {
          log("Suscrito con éxito a: $channelName");
        },
      );
    } catch (e) {
      log("Error al inicializar Pusher: $e");
    }
  }

  /// Cancela solo la suscripción de este canal, sin cerrar la conexión
  /// global (otras pantallas pueden seguir escuchando sus propios canales).
  void disconnect() {
    final channelName = _channelName;
    if (channelName == null) return;
    _channelName = null;
    _pusher.unsubscribe(channelName: channelName).catchError((e) {
      log("Error al desuscribir $channelName: $e");
    });
  }
}
