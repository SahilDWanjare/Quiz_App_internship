import 'package:flutter/material.dart';
import 'dart:ui';

/// Executive Intelligence Color Palette
/// Navy Blue (Trust, Authority) | Silver/Light Gray (Sophistication) | Teal (Focus, Clarity)
class ExecutiveColors {
  // Primary - Navy Blue (Authority & Trust)
  static const Color navy = Color(0xFF0A1929);
  static const Color navyLight = Color(0xFF132F4C);
  static const Color navyMedium = Color(0xFF0D2137);
  static const Color navyDark = Color(0xFF051221);

  // Accent - Teal/Bright Blue (Focus & Clarity)
  static const Color teal = Color(0xFF00BFA5);
  static const Color tealLight = Color(0xFF5DF2D6);
  static const Color brightBlue = Color(0xFF29B6F6);
  static const Color cyan = Color(0xFF00E5FF);

  // Neutral - Silver/Light Gray (Sophistication)
  static const Color silver = Color(0xFFB0BEC5);
  static const Color silverLight = Color(0xFFECEFF1);
  static const Color silverMedium = Color(0xFF78909C);
  static const Color silverDark = Color(0xFF546E7A);

  // Functional
  static const Color white = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFEF5350);
  static const Color success = Color(0xFF66BB6A);

  // Glassmorphism
  static Color glassWhite = Colors.white.withOpacity(0.12);
  static Color glassBorder = Colors.white. withOpacity(0.2);

  // Gradients
  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navyLight, navy, navyDark],
  );

  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment. topLeft,
    end: Alignment. bottomRight,
    colors: [tealLight, teal],
  );

  static LinearGradient glassGradient = LinearGradient(
    begin:  Alignment.topLeft,
    end:  Alignment.bottomRight,
    colors: [
      Colors.white.withOpacity(0.15),
      Colors.white.withOpacity(0.05),
    ],
  );
}

/// Executive Typography using Inter font style
class ExecutiveTypography {
  static const String fontFamily = 'Inter';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight. w700,
    letterSpacing: -0.5,
    color: ExecutiveColors.white,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color:  ExecutiveColors.white,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color:  ExecutiveColors.white,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily:  fontFamily,
    fontSize: 16,
    fontWeight:  FontWeight.w400,
    letterSpacing: 0.15,
    color:  ExecutiveColors.silver,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize:  14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color:  ExecutiveColors.silver,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily:  fontFamily,
    fontSize: 14,
    fontWeight:  FontWeight.w600,
    letterSpacing: 0.5,
    color:  ExecutiveColors.teal,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily:  fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color:  ExecutiveColors.silverMedium,
  );
}