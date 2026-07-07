import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colores semánticos de superficie/texto que varían entre tema claro y oscuro.
/// Los colores de marca/acento (azules, gradientes, estados) se mantienen
/// iguales en ambos temas y no forman parte de esta extensión.
class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color shadow;

  const AppColors({
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.shadow,
  });

  static const dark = AppColors(
    background: Color(0xFF0B0D17),
    surface: Color(0xFF15192B),
    textPrimary: Colors.white,
    textSecondary: Colors.white70,
    textMuted: Colors.white38,
    border: Color(0x0DFFFFFF), // Colors.white con 5% de opacidad
    shadow: Color(0x66000000), // Colors.black con 40% de opacidad
  );

  static const light = AppColors(
    background: Color(0xFFF4F6FA),
    surface: Colors.white,
    textPrimary: Color(0xFF12171D),
    textSecondary: Color(0xFF4B5563),
    textMuted: Color(0xFF9AA1AC),
    border: Color(0x14000000), // Colors.black con 8% de opacidad
    shadow: Color(0x1F000000), // Colors.black con 12% de opacidad
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? shadow,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

/// Rojo racing de marca (Xtreme Performance) usado como color primario/de
/// acento en toda la app: botones, gradientes de cards, iconos destacados,
/// gráficos y navegación. `kBrandAccent` se mantiene por compatibilidad con
/// el código existente que ya lo referencia.
const Color kBrandPrimary = Color(0xFFE10600);
const Color kBrandSecondary = Color(0xFFB00020);
const Color kBrandAccent = kBrandPrimary;

/// Gradiente de marca reutilizable (tarjetas, botones, headers, gráficos).
const LinearGradient kBrandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kBrandPrimary, kBrandSecondary],
);

class AppTheme {
  /// Combina dos tipografías de Google Fonts: Rajdhani (carácter
  /// automotriz/tech) para títulos y display, Inter (legible) para el
  /// resto del cuerpo de texto. Se aplica sobre el `textTheme` base de
  /// Material para conservar tamaños/alturas por defecto.
  static TextTheme _brandTextTheme(TextTheme base) {
    final withBody = GoogleFonts.interTextTheme(base);
    return withBody.copyWith(
      displayLarge: GoogleFonts.rajdhani(textStyle: withBody.displayLarge, fontWeight: FontWeight.w700),
      displayMedium: GoogleFonts.rajdhani(textStyle: withBody.displayMedium, fontWeight: FontWeight.w700),
      displaySmall: GoogleFonts.rajdhani(textStyle: withBody.displaySmall, fontWeight: FontWeight.w700),
      headlineLarge: GoogleFonts.rajdhani(textStyle: withBody.headlineLarge, fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.rajdhani(textStyle: withBody.headlineMedium, fontWeight: FontWeight.w700),
      headlineSmall: GoogleFonts.rajdhani(textStyle: withBody.headlineSmall, fontWeight: FontWeight.w700),
      titleLarge: GoogleFonts.rajdhani(textStyle: withBody.titleLarge, fontWeight: FontWeight.w700),
      titleMedium: GoogleFonts.rajdhani(textStyle: withBody.titleMedium, fontWeight: FontWeight.w600),
    );
  }

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.dark.background,
        cardColor: AppColors.dark.surface,
        dividerColor: AppColors.dark.border,
        primaryColor: kBrandAccent,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kBrandAccent,
          brightness: Brightness.dark,
          surface: AppColors.dark.surface,
          onSurface: AppColors.dark.textPrimary,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.dark.textPrimary,
        ),
        textTheme: _brandTextTheme(ThemeData.dark().textTheme).apply(
          bodyColor: AppColors.dark.textPrimary,
          displayColor: AppColors.dark.textPrimary,
        ),
        extensions: const [AppColors.dark],
      );

  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.light.background,
        cardColor: AppColors.light.surface,
        dividerColor: AppColors.light.border,
        primaryColor: kBrandAccent,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kBrandAccent,
          brightness: Brightness.light,
          surface: AppColors.light.surface,
          onSurface: AppColors.light.textPrimary,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.light.textPrimary,
        ),
        textTheme: _brandTextTheme(ThemeData.light().textTheme).apply(
          bodyColor: AppColors.light.textPrimary,
          displayColor: AppColors.light.textPrimary,
        ),
        extensions: const [AppColors.light],
      );
}

extension AppColorsX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
