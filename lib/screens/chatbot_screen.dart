import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart'; // 🚀 NUEVO IMPORT PARA GRÁFICOS

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
          '¡Hola! 🚗 Soy el asistente virtual de Xtreme Performance. \n\nPuedes preguntarme por el estado de tu vehículo o pedirme estadísticas. Escribe por ejemplo: "¿Cuántas órdenes hay por estado?".',
      'esBot': true,
      'chart': null // Inicializamos sin gráfico
    }
  ];

  bool _escribiendo = false;

  Future<void> _enviarMensaje() async {
    if (_escribiendo) return;

    final texto = _mensajeController.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      _escribiendo = true;
      _mensajes.add({'texto': texto, 'esBot': false, 'chart': null});
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

        String textoRespuesta = data['respuesta'] ?? '';
        if (textoRespuesta.contains('429') ||
            textoRespuesta.contains('Too Many')) {
          textoRespuesta =
              'Mecánico ocupado analizando datos ⏱️. Por favor, dame un minuto y vuelve a consultarme.';
        }

        // 📊 NUEVO: Atrapamos los datos del gráfico si la API los envía
        Map<String, dynamic>? datosGrafico = data['chart'];

        if (mounted) {
          setState(() {
            _mensajes.add({
              'texto': textoRespuesta,
              'esBot': true,
              'chart': datosGrafico // Guardamos el gráfico en el historial
            });
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _mensajes.add({
              'texto': 'Tuve un problema conectando con el taller.',
              'esBot': true,
              'chart': null
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
            'esBot': true,
            'chart': null
          });
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _escribiendo = false;
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
    const Color bgColor = Color(0xFF0F111A);
    const Color botBubbleColor = Color(0xFF1E2235);
    const Color userBubbleColor = Color(0xFF0052D4);
    const Color accentColor = Color(0xFF4376FF);

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
              color: Colors.transparent,
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
                        // Burbuja de mensaje + Gráfico
                        Flexible(
                          child: Column(
                            crossAxisAlignment: esBot
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 14),
                                decoration: BoxDecoration(
                                  color:
                                      esBot ? botBubbleColor : userBubbleColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(20),
                                    topRight: const Radius.circular(20),
                                    bottomLeft: Radius.circular(esBot ? 4 : 20),
                                    bottomRight:
                                        Radius.circular(esBot ? 20 : 4),
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
                                    color:
                                        esBot ? Colors.grey[200] : Colors.white,
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              // 📊 NUEVO: Si hay gráfico, lo dibujamos aquí abajo
                              if (mensaje['chart'] != null) ...[
                                const SizedBox(height: 10),
                                ChatChartWidget(chartData: mensaje['chart']),
                              ]
                            ],
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
                          hintText: 'Ej: ¿Cuántas órdenes hay?',
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

// ==========================================
// NUEVO WIDGET: EL LIENZO DE GRÁFICOS INTELIGENTE
// ==========================================
class ChatChartWidget extends StatelessWidget {
  final Map<String, dynamic> chartData;

  const ChatChartWidget({Key? key, required this.chartData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Definimos los colores neón estilo Xtreme Performance
    const Color neonBlue = Color(0xFF00C6FF);
    const Color neonGreen = Color(0xFF00E676);
    const Color bgBubble = Color(0xFF1E2235); // Fondo de la burbuja del bot

    // ----------------------------------------------------
    // GRÁFICO DE BARRAS 💰 (Caso 3: Ingresos/Ganancias)
    // ----------------------------------------------------
    if (chartData['tipo'] == 'barras') {
      final List<String> labels = List<String>.from(chartData['labels']);
      final List<double> data = List<double>.from(chartData['data']);

      // Calculamos el valor máximo para el eje Y
      double maxY = 1000;
      if (data.isNotEmpty) {
        maxY = data.reduce((a, b) => a > b ? a : b) * 1.2;
      }

      return Container(
        height: 250, // Un poco más alto para las barras y ejes
        width: 280,
        padding: const EdgeInsets.only(top: 16, bottom: 8, left: 10, right: 20),
        decoration: BoxDecoration(
          color: bgBubble,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              chartData['titulo'] ?? 'Flujo',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => const Color(0xFF2A2D3E),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          'S/ ${rod.toY.toStringAsFixed(2)}',
                          const TextStyle(
                              color: neonGreen, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                labels[index],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            'S/ ${value.toInt()}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 9,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.white.withOpacity(0.03),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    data.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data[index],
                          width: 14,
                          borderRadius: BorderRadius.circular(4),
                          gradient: const LinearGradient(
                            colors: [neonGreen, neonBlue],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY,
                            color: Colors.white.withOpacity(0.01),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ----------------------------------------------------
    // GRÁFICO DE DONA 🍩 (Caso 2: Totales de Órdenes)
    // ----------------------------------------------------
    if (chartData['tipo'] == 'pastel') {
      return Container(
        height: 220,
        width: 250,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgBubble,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              chartData['titulo'] ?? 'Estadísticas',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: _getPastelSections(
                      chartData['series'], neonBlue, neonGreen),
                  centerSpaceRadius: 35,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox
        .shrink(); // Si no es gráfico soportado, no mostramos nada
  }

  // Función auxiliar para las secciones del gráfico de dona
  List<PieChartSectionData> _getPastelSections(
      List<dynamic> series, Color colorBlue, Color colorGreen) {
    return series.map((data) {
      Color color = Colors.grey;
      if (data['color'] == 'blue') color = colorBlue; // Abiertas
      if (data['color'] == 'green') color = colorGreen; // Facturadas

      return PieChartSectionData(
        color: color,
        value: (data['value'] as num).toDouble(),
        title: '${data['value']}',
        radius: 40,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
        ),
        badgeWidget: _BadgePastel(
          data['label'],
          color: color,
        ),
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }
}

// Widget auxiliar para las etiquetas bonitas afuera del gráfico de dona
class _BadgePastel extends StatelessWidget {
  final String text;
  final Color color;

  const _BadgePastel(this.text, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
