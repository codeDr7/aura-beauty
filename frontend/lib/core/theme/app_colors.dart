import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF725A37);
  static const Color matteGold = Color(0xFFB89B72);
  static const Color warmNude = Color(0xFFE7D7C9);
  static const Color sandBeige = Color(0xFFD8C3A5);
  static const Color sageGreen = Color(0xFFA8B2A1);
  static const Color ivoryWhite = Color(0xFFF8F6F2);
  static const Color softCharcoal = Color(0xFF2B2B2B);
  static const Color background = Color(0xFFFBF9F5);

  static const Color surface = Color(0xFFFFFCF8);
  static const Color surfaceDim = Color(0xFFE8E4DE);
  static const Color surfaceBright = Color(0xFFFFFCF8);
  static const Color surfaceContainerLowest = Color(0xFFFFFCF8);
  static const Color surfaceContainerLow = Color(0xFFF8F6F2);
  static const Color surfaceContainer = Color(0xFFF2EFEA);
  static const Color surfaceContainerHigh = Color(0xFFECEAE4);
  static const Color surfaceContainerHighest = Color(0xFFE6E4DE);

  static const Color onSurface = Color(0xFF2B2B2B);
  static const Color onSurfaceVariant = Color(0xFF6B625A);
  static const Color outline = Color(0xFFC4BDB5);
  static const Color outlineVariant = Color(0xFFE0D8D0);

  static const Color success = Color(0xFF4CAF50);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFC8E6C9);
  static const Color onSuccessContainer = Color(0xFF1B5E20);

  static const Color warning = Color(0xFFFFA726);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFFE0B2);
  static const Color onWarningContainer = Color(0xFFBF5F00);

  static const Color error = Color(0xFFD32F2F);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFCDD2);
  static const Color onErrorContainer = Color(0xFFB71C1C);

  static const Color info = Color(0xFF1976D2);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFBBDEFB);
  static const Color onInfoContainer = Color(0xFF0D47A1);

  // Dark theme colors
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkSurfaceDim = Color(0xFF121212);
  static const Color darkSurfaceBright = Color(0xFF2B2B2B);
  static const Color darkOnSurface = Color(0xFFE6E1DC);
  static const Color darkOnSurfaceVariant = Color(0xFFB8AFA6);
  static const Color darkOutline = Color(0xFF544E48);
  static const Color darkOutlineVariant = Color(0xFF3F3A35);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurfaceContainerLowest = Color(0xFF121212);
  static const Color darkSurfaceContainerLow = Color(0xFF1D1D1D);
  static const Color darkSurfaceContainer = Color(0xFF252525);
  static const Color darkSurfaceContainerHigh = Color(0xFF2E2E2E);
  static const Color darkSurfaceContainerHighest = Color(0xFF3A3A3A);

  // Light gradients
  static const LinearGradient auraWarmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warmNude, sandBeige],
  );

  static const LinearGradient auraGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [matteGold, warmNude],
  );

  static const LinearGradient auraDarkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [softCharcoal, primary],
  );

  static const LinearGradient auraFreshGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [sageGreen, surface],
  );

  static const LinearGradient heroOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, background],
    stops: [0.5, 1.0],
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8E4DE),
      Color(0xFFF2EFEA),
      Color(0xFFE8E4DE),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient glassHighlight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white70, Colors.white10],
  );

  static BoxDecoration glassMorphism({
    double blur = 20,
    double opacity = 0.15,
    Color? tint,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      color: (tint ?? Colors.white).withOpacity(opacity),
      border: Border.all(
        color: Colors.white.withOpacity(0.3),
        width: 0.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: blur,
          spreadRadius: 0,
        ),
      ],
    );
  }

  static BoxDecoration glassMorphismDark({
    double blur = 20,
    double opacity = 0.1,
    Color? tint,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      color: (tint ?? Colors.white).withOpacity(opacity),
      border: Border.all(
        color: Colors.white.withOpacity(0.08),
        width: 0.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: blur,
          spreadRadius: 0,
        ),
      ],
    );
  }
}
