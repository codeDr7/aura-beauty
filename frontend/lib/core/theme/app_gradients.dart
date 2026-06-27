import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  AppGradients._();

  static const LinearGradient auraWarm = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.warmNude, AppColors.sandBeige],
  );

  static const LinearGradient auraGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.matteGold, AppColors.warmNude],
  );

  static const LinearGradient auraDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.softCharcoal, AppColors.primary],
  );

  static const LinearGradient auraFresh = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.sageGreen, AppColors.surface],
  );

  static const LinearGradient heroOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, AppColors.background],
    stops: [0.5, 1.0],
  );

  static const LinearGradient shimmer = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8E4DE),
      Color(0xFFF2EFEA),
      Color(0xFFE8E4DE),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient heroOverlayDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, AppColors.darkBackground],
    stops: [0.5, 1.0],
  );

  static const LinearGradient shimmerDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2E2E2E),
      Color(0xFF3A3A3A),
      Color(0xFF2E2E2E),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient splashPrimary = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      AppColors.warmNude,
      AppColors.background,
      AppColors.sandBeige,
    ],
  );

  static const LinearGradient cardOverlay = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Colors.black54,
      Colors.transparent,
    ],
    stops: [0.0, 1.0],
  );

  static const LinearGradient goldenButton = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.matteGold,
      Color(0xFFD4B896),
    ],
  );

  static const LinearGradient progressGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary,
      AppColors.matteGold,
    ],
  );

  static BoxDecoration auraCardDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    gradient: auraWarm,
  );

  static BoxDecoration goldCardDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    gradient: auraGold,
  );

  static BoxDecoration darkCardDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    gradient: auraDark,
  );

  static BoxDecoration freshCardDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    gradient: auraFresh,
  );
}
