import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography. Cairo covers Arabic and Latin glyphs with a consistent look.
abstract final class AppTypography {
  static TextTheme textTheme(TextTheme base) =>
      GoogleFonts.cairoTextTheme(base);
}
