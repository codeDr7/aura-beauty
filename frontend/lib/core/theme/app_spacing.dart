import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double unit = 8.0;

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  static const double sectionGap = 64.0;
  static const double containerMargin = 24.0;
  static const double gutter = 24.0;

  static const double pageHorizontalPadding = 24.0;
  static const double pageVerticalPadding = 24.0;

  static const double inputMinHeight = 56.0;
  static const double bottomNavHeight = 72.0;
  static const double appBarHeight = 64.0;

  // Border radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusCards = 24.0;
  static const double radiusButtons = 18.0;
  static const double radiusInputs = 16.0;
  static const double radiusFull = 9999.0;

  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: pageHorizontalPadding,
    vertical: pageVerticalPadding,
  );

  static const EdgeInsets horizontalPadding = EdgeInsets.symmetric(
    horizontal: pageHorizontalPadding,
  );

  static const EdgeInsets verticalPadding = EdgeInsets.symmetric(
    vertical: pageVerticalPadding,
  );

  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  static const EdgeInsets cardPaddingLg = EdgeInsets.all(lg);

  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: sm + 4,
  );

  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: sm + 4,
    vertical: xs + 2,
  );

  // SizedBox helpers
  static const Widget hXs = SizedBox(height: xs);
  static const Widget hSm = SizedBox(height: sm);
  static const Widget hMd = SizedBox(height: md);
  static const Widget hLg = SizedBox(height: lg);
  static const Widget hXl = SizedBox(height: xl);
  static const Widget hXxl = SizedBox(height: xxl);

  static const Widget wXs = SizedBox(width: xs);
  static const Widget wSm = SizedBox(width: sm);
  static const Widget wMd = SizedBox(width: md);
  static const Widget wLg = SizedBox(width: lg);
  static const Widget wXl = SizedBox(width: xl);
  static const Widget wXxl = SizedBox(width: xxl);
}
