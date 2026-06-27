import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextStyle get _playfairDisplay => GoogleFonts.playfairDisplay();
  static TextStyle get _manrope => GoogleFonts.manrope();

  static TextStyle get heroTitle => _playfairDisplay.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        height: 1.1,
        letterSpacing: -0.5,
      );

  static TextStyle get heroTitleMobile => _playfairDisplay.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        height: 1.15,
        letterSpacing: -0.3,
      );

  static TextStyle get sectionTitle => _playfairDisplay.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.3,
      );

  static TextStyle get cardTitle => _playfairDisplay.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.0,
      );

  static TextStyle get bodyLarge => _manrope.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        height: 1.5,
        letterSpacing: 0.0,
      );

  static TextStyle get bodyMain => _manrope.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.5,
        letterSpacing: 0.0,
      );

  static TextStyle get bodySmall => _manrope.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.4,
        letterSpacing: 0.1,
      );

  static TextStyle get caption => _manrope.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        height: 1.3,
        letterSpacing: 0.2,
      );

  static TextStyle get buttonLabel => _manrope.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        height: 1.2,
        letterSpacing: 0.8,
      );

  static TextStyle get overline => _manrope.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 1.5,
      );

  static TextStyle get brandName => _playfairDisplay.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 2.0,
      );

  static TextStyle get displaySmall => _playfairDisplay.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.2,
      );

  static TextStyle get labelMedium => _manrope.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.5,
      );

  static TextStyle get titleMedium => _manrope.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.1,
      );

  static TextStyle get headlineMedium => _playfairDisplay.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.2,
      );
}
