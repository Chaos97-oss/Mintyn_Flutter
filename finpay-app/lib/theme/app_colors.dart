import 'package:flutter/material.dart';

/// Design tokens — app shell uses user-specified palette; semantic colors align with product spec.
abstract final class AppColors {
  static const Color background = Color(0xFF1C1C1D);
  static const Color card = Color(0xFF232325);
  static const Color surface = Color(0xFF232325);
  static const Color border = Color(0xFF272729);

  static const Color accent = Color(0xFF0065FF);
  static const Color accentLight = Color(0xFF5B9BFF);
  static const Color chartBlueOpaque = Color(0xFF2B7FFF);
  static const Color chartBlueTransparent = Color(0x000047B3);

  static const Color red = Color(0xFFEF4444);
  static const Color green = Color(0xFF22C55E);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF475569);

  static const Color mastercardRed = Color(0xFFEB001B);
  static const Color mastercardOrange = Color(0xFFFF5F00);

  static const Color overlayScrim = Color(0x80000000);

  /// Logout pill (reference UI).
  static const Color logoutSurface = Color(0xFFFFDADA);
  static const Color logoutForeground = Color(0xFF7F1D1D);

  /// linear-gradient(180deg, #2B7FFF 0%, rgba(0, 71, 179, 0) 100%)
  static const LinearGradient chartAreaGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2B7FFF),
      Color(0x000047B3),
    ],
  );

  static const LinearGradient paymentCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F3460),
      Color(0xFF16213E),
    ],
  );
}
