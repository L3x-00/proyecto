import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'dart:developer'; 

class PusherConfig {
  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  Future<void> initPusher({
    required String channelName,
    required String eventName,
    required Function(PusherEvent) onEventTriggered,
  }) async {
    try {
      try {
        await pusher.disconnect();
      } catch (_) {
      }

      await pusher.init(
        apiKey: "24883b4239d5fad125df",
        cluster: "mt1", 
        onConnectionStateChange: (currentState, previousState) {
          log("Conexión: $previousState -> $currentState");
        },
        onError: (message, code, e) {
          print("ERROR Pusher: $message (Código: $code)");
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

      await pusher.subscribe(channelName: channelName);
      print("DEBUG: Suscrito a canal $channelName");
      await pusher.connect();
      print("DEBUG: Conectado a Pusher");
    } catch (e) {
      log("Error al inicializar Pusher: $e");
    }
  }

  void disconnect() {
    pusher.disconnect();
  }
}
