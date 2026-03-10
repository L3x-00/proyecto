import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'dart:developer'; // <-- Esto soluciona el error en "log"

class PusherConfig {
  // Instancia única (Singleton) según la documentación oficial
  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  Future<void> initPusher({
    required String channelName,
    required String eventName,
    required Function(PusherEvent) onEventTriggered,
  }) async {
    try {
      // 1. MATAR CUALQUIER CONEXIÓN PREVIA (La clave para Flutter Web)
      try {
        await pusher.disconnect();
      } catch (_) {
        // Ignoramos si da error porque simplemente no estaba conectado aún
      }

      // 2. Inicializar Pusher de forma limpia
      await pusher.init(
        apiKey: "24883b4239d5fad125df",
        cluster: "mt1",
        onConnectionStateChange: (currentState, previousState) {
          log("Conexión: $previousState -> $currentState");
        },
        onError: (message, code, e) {
          log("Error Pusher: $message (Código: $code)");
        },
        onEvent: (PusherEvent event) {
          log("Evento recibido en canal general: ${event.eventName}");
          if (event.eventName == eventName) {
            onEventTriggered(event);
          }
        },
        onSubscriptionSucceeded: (channel, data) {
          log("Suscrito con éxito a: $channel");
        },
      );

      // Suscribirse al canal específico después de inicializar
      await pusher.subscribe(channelName: channelName);
      await pusher.connect();
    } catch (e) {
      log("Error al inicializar Pusher: $e");
    }
  }

  void disconnect() {
    pusher.disconnect();
  }
}
