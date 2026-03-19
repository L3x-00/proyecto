import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  // ==========================================
  // LÓGICA CON CANDADO ANTI-SPAM
  // ==========================================
  final TextEditingController _mensajeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _mensajes = [
    {
      'texto':
          '¡Hola! 🚗 Soy el asistente virtual de Xtreme Performance. \n\nPuedes preguntarme por el estado de tu vehículo. Escribe por ejemplo: "estado de mi orden 19".',
      'esBot': true
    }
  ];

  bool _escribiendo = false;

  Future<void> _enviarMensaje() async {
    // 🛑 CANDADO: Si el bot ya está pensando, ignoramos clics extra
    if (_escribiendo) return;

    final texto = _mensajeController.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      _escribiendo = true; // Cerramos candado
      _mensajes.add({'texto': texto, 'esBot': false});
      _mensajeController.clear();
    });

    _bajarScroll();

    try {
      final response = await http.post(
        Uri.parse(
            'https://www.xtremeperformancepe.com/public/api/endpoints/chatbot_pro.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mensaje': texto}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Interceptamos el error de límite de velocidad si viene de Google
        String textoRespuesta = data['respuesta'] ?? '';
        if (textoRespuesta.contains('429') ||
            textoRespuesta.contains('Too Many')) {
          textoRespuesta =
              'Mecánico ocupado analizando datos ⏱️. Por favor, dame un minuto y vuelve a consultarme.';
        }

        if (mounted) {
          setState(() {
            _mensajes.add({'texto': textoRespuesta, 'esBot': true});
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _mensajes.add({
              'texto': 'Tuve un problema conectando con el taller.',
              'esBot': true
            });
          });
        }
      }
    } catch (e) {
      print('🔥 ERROR DEL CHATBOT: $e');
      if (mounted) {
        setState(() {
          _mensajes.add({
            'texto': 'Error de conexión. Verifica tu internet.',
            'esBot': true
          });
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _escribiendo = false; // 🔓 Abrimos candado al terminar
        });
        _bajarScroll();
      }
    }
  }

  void _bajarScroll() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ==========================================
  // NUEVA INTERFAZ VISUAL (UI / Diseño)
  // ==========================================
  @override
  Widget build(BuildContext context) {
    // Paleta de colores moderna para Xtreme Performance
    const Color bgColor = Color(0xFF0F111A); // Fondo más profundo
    const Color botBubbleColor = Color(0xFF1E2235); // Tarjeta del bot
    const Color userBubbleColor = Color(0xFF0052D4); // Azul vibrante usuario
    const Color accentColor = Color(0xFF4376FF); // Acento para íconos

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF12121D), Color(0xFF1E2235)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: accentColor, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mecánico Virtual',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'IA de Xtreme Performance',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Área de mensajes
          Expanded(
            child: Container(
              color: Colors
                  .transparent, // Reemplazo de la imagen que daba error 404
              child: ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                itemCount: _mensajes.length,
                itemBuilder: (context, index) {
                  final mensaje = _mensajes[index];
                  final esBot = mensaje['esBot'];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: esBot
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (esBot) ...[
                          // Avatar del bot
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: botBubbleColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.build,
                                color: accentColor, size: 16),
                          ),
                        ],
                        // Burbuja de mensaje
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                            decoration: BoxDecoration(
                              color: esBot ? botBubbleColor : userBubbleColor,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft: Radius.circular(esBot ? 4 : 20),
                                bottomRight: Radius.circular(esBot ? 20 : 4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              mensaje['texto'],
                              style: TextStyle(
                                color: esBot ? Colors.grey[200] : Colors.white,
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Indicador de "Escribiendo..." moderno
          if (_escribiendo)
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Mecánico analizando...',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Caja de texto inferior
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF151722),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: botBubbleColor,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: TextField(
                        controller: _mensajeController,
                        style: const TextStyle(color: Colors.white),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _enviarMensaje(),
                        decoration: InputDecoration(
                          hintText: 'Ej: ¿Cómo va mi orden 19?',
                          hintStyle:
                              TextStyle(color: Colors.grey[500], fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Botón de enviar con degradado
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [accentColor, Color(0xFF0052D4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 22),
                      onPressed: _enviarMensaje,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
