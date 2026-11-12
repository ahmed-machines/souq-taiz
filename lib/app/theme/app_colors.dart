import 'package:flutter/material.dart';

/// Brand design tokens. Widgets must read colors from the theme
/// (`Theme.of(context).colorScheme`), not from here directly,
/// except for one-off decorations (gradients, shadows).
abstract final class AppColors {
  // ── Primary palette ──────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1B5E3B);
  static const Color primaryLight = Color(0xFF2E7D52);
  static const Color primaryDark = Color(0xFF0D3D22);

  // ── Secondary / accent ───────────────────────────────────────────────────
  static const Color secondary = Color(0xFFF2A516);
  static const Color secondaryLight = Color(0xFFFFC947);

  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF4F6F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEFF3F4);
  static const Color surfaceDim = Color(0xFFE8ECEE);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);

  // ── UI chrome ────────────────────────────────────────────────────────────
  static const Color divider = Color(0xFFE5E7EB);
  static const Color shadow = Color(0x14000000);
  static const Color cardShadow = Color(0x0D000000);

  // ── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B5E3B), Color(0xFF2E7D52)],
  );

  static const LinearGradient heroBgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D3D22), Color(0xFF1B5E3B), Color(0xFF2E7D52)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient imageOverlay = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [Color(0xAA000000), Color(0x00000000)],
  );

  static const LinearGradient amberGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF2A516), Color(0xFFFFB940)],
  );

  // ── Category card gradient presets ───────────────────────────────────────
  static const List<List<Color>> categoryGradients = [
    [Color(0xFF1B5E3B), Color(0xFF2E7D52)],
    [Color(0xFF1565C0), Color(0xFF1E88E5)],
    [Color(0xFFB71C1C), Color(0xFFE53935)],
    [Color(0xFF4A148C), Color(0xFF7B1FA2)],
    [Color(0xFFE65100), Color(0xFFFF6D00)],
    [Color(0xFF006064), Color(0xFF00838F)],
    [Color(0xFF33691E), Color(0xFF558B2F)],
    [Color(0xFF880E4F), Color(0xFFC2185B)],
    [Color(0xFF37474F), Color(0xFF546E7A)],
    [Color(0xFF1A237E), Color(0xFF283593)],
  ];
}
