import 'package:flutter/material.dart';

import 'quiz_colors.dart';

class AppTheme {
  AppTheme._();

  static const Color _seed = Color(0xFF0E7C86); // teal

  static ThemeData light() => _build(Brightness.light, QuizColors.light);
  static ThemeData dark() => _build(Brightness.dark, QuizColors.dark);

  static ThemeData _build(Brightness brightness, QuizColors quizColors) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Nunito',
      extensions: [quizColors],
    );
  }
}
