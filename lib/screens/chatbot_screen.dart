import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _mensajeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Lista de mensajes (Inicia con el saludo del bot)
  final List<Map<String, dynamic>> _mensajes = [
    {
      'texto': '¡Hola! 🚗 Soy el asistente virtual de Xtreme Performance. \n\nPuedes preguntarme por el estado de tu vehículo. Escribe por ejemplo: "estado de mi orden 19".',
      'esBot': true
    }
  ];

  bool _escribiendo = false;

  void _enviarMensaje() {
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty) return;

    // 1. Agregamos el mensaje del usuario
    setState(() {
      _mensajes.add({'texto': texto, 'esBot': false});
      _mensajeController.clear();
      _escribiendo = true; // Simulamos que el bot está pensando
    });
    
    _bajarScroll();

    // 2. Simulamos la conexión al PHP (Aquí luego haremos la petición real)
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      setState(() {
        _escribiendo = false;
        
        // Lógica temporal para demostrar el Nivel 2 (Conexión a BD)
        if (texto.toLowerCase().contains("19")) {
          _mensajes.add({
            'texto': 'Revisando mis registros... 🔍\n\nTu orden #19 se encuentra activa. El último avance registrado fue hoy mismo. ¡Nuestros mecánicos siguen trabajando en él!',
            'esBot': true
          });
        } else {
          _mensajes.add({
            'texto': 'Aún estoy en entrenamiento y mi base de datos es limitada. Por favor, intenta preguntarme por la "orden 19".',
            'esBot': true
          });
        }
      });
      _bajarScroll();
    });
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

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF1A1A27);
    const Color botBubbleColor = Color(0xFF2A2D3E);
    const Color userBubbleColor = Color(0xFF0052D4);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy, color: Colors.blueAccent),
            SizedBox(width: 10),
            Text('Mecánico Virtual', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: const Color(0xFF12121D),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // ZONA DE MENSAJES
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _mensajes.length,
              itemBuilder: (context, index) {
                final mensaje = _mensajes[index];
                final esBot = mensaje['esBot'];

                return Align(
                  alignment: esBot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: esBot ? botBubbleColor : userBubbleColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(esBot ? 0 : 16),
                        bottomRight: Radius.circular(esBot ? 16 : 0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      mensaje['texto'],
                      style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.3),
                    ),
                  ),
                );
              },
            ),
          ),

          // INDICADOR DE ESCRIBIENDO
          if (_escribiendo)
            const Padding(
              padding: EdgeInsets.only(left: 24, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('El asistente está escribiendo...', 
                  style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontStyle: FontStyle.italic)),
              ),
            ),

          // ZONA DE INPUT (Teclado)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF12121D),
              border: Border(top: BorderSide(color: Color(0xFF2A2D3E), width: 1)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _mensajeController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Escribe tu consulta aquí...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: botBubbleColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _enviarMensaje(), // Permite enviar con el botón "Enter" del teclado
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _enviarMensaje,
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