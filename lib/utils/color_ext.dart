import 'package:flutter/material.dart';

extension ColorExt on Color {
  /// Safe replacement for deprecated `withOpacity`.
  /// Uses `withAlpha` to avoid precision-loss deprecation warnings.
  Color withOpacitySafe(double opacity) {
    final o = opacity.clamp(0.0, 1.0);
    return withAlpha((o * 255).round());
  }
}
