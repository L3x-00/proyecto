import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../screens/chatbot_screen.dart';

/// Botón flotante para abrir el chatbot "Mecánico Virtual".
class ChatbotFab extends StatefulWidget {
  const ChatbotFab({Key? key}) : super(key: key);

  @override
  State<ChatbotFab> createState() => _ChatbotFabState();
}

class _ChatbotFabState extends State<ChatbotFab> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    if (!_visible) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Text(
            '¿Necesitas ayuda?',
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kBrandSecondary.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: FloatingActionButton(
                tooltip: 'Mecánico Virtual',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatbotScreen()),
                  );
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: const CircleBorder(),
                child: ClipOval(
                  child: Image.asset(
                    'assets/maestrito_bot.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(
                  end: 1.08,
                  duration: 1200.ms,
                  curve: Curves.easeInOut,
                ),
            Positioned(
              top: -4,
              right: -4,
              child: GestureDetector(
                onTap: () => setState(() => _visible = false),
                child: Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
