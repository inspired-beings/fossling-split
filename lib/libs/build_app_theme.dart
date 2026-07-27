import 'package:flutter/material.dart';

/// Shared with the accessibility tests so contrast is checked against the shipped colors.
ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF0C1A4B),
    brightness: Brightness.dark,
  );
  // M3's 38%-opacity disabled text fails the 4.5:1 contrast the a11y suite
  // enforces on every state — keep disabled labels readable instead.
  final disabledForeground = scheme.onSurface.withValues(alpha: 0.78);
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(disabledForegroundColor: disabledForeground),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(disabledForegroundColor: disabledForeground),
    ),
  );
}
