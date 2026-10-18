import 'package:flutter/material.dart';

import 'app_tokens.dart';
import 'quiz_colors.dart';

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light, QuizColors.light);
  static ThemeData dark() => _build(Brightness.dark, QuizColors.dark);

  static ThemeData _build(Brightness brightness, QuizColors quizColors) {
    final p = quizColors.palette;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: p.amber,
      onPrimary: AppTokens.light.ink,
      primaryContainer: p.amberContainer,
      onPrimaryContainer: p.onAmberContainer,
      secondary: p.blueprint,
      onSecondary: p.paper,
      secondaryContainer: p.blueprintContainer,
      onSecondaryContainer: p.ink,
      error: p.wrong,
      onError: brightness == Brightness.dark
          ? AppTokens.light.ink
          : AppTokens.light.surface,
      errorContainer: p.wrongContainer,
      onErrorContainer: p.onWrongContainer,
      surface: p.surface,
      onSurface: p.ink,
      onSurfaceVariant: p.inkMuted,
      outline: p.outlineStrong,
      outlineVariant: p.line,
      surfaceTint: AppTokens.transparent,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.paper,
      fontFamily: AppTokens.nunito,
      extensions: [quizColors],
      textTheme: TextTheme(
        displayLarge: AppTokens.displayXL,
        displayMedium: AppTokens.display,
        headlineMedium: AppTokens.headline,
        titleLarge: AppTokens.title,
        bodyLarge: AppTokens.body,
        bodyMedium: AppTokens.body,
        labelLarge: AppTokens.monoLabel,
      ).apply(bodyColor: p.ink, displayColor: p.ink),
      appBarTheme: AppBarTheme(
        backgroundColor: p.paper,
        foregroundColor: p.ink,
        elevation: AppTokens.zero,
        scrolledUnderElevation: AppTokens.zero,
        surfaceTintColor: AppTokens.transparent,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: AppTokens.transparent,
      hoverColor: AppTokens.transparent,
      focusColor: AppTokens.transparent,
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: AppTokens.transparent,
        elevation: AppTokens.zero,
      ),
    );
  }
}
