import 'package:flutter/material.dart';

import 'app_tokens.dart';

@immutable
class QuizColors extends ThemeExtension<QuizColors> {
  const QuizColors(this.palette);
  final AppPalette palette;
  static const light = QuizColors(AppTokens.light);
  static const dark = QuizColors(AppTokens.dark);
  Color get correct => palette.correct;
  Color get correctContainer => palette.correctContainer;
  Color get onCorrectContainer => palette.onCorrectContainer;
  Color get wrong => palette.wrong;
  Color get wrongContainer => palette.wrongContainer;
  Color get onWrongContainer => palette.onWrongContainer;
  Color get selected => palette.amber;
  Color get selectedContainer => palette.amberContainer;
  Color get codeBg => palette.codeBg;
  Color get codeText => palette.codeText;
  Color get keyEdge => palette.keyEdge;

  @override
  QuizColors copyWith({AppPalette? palette}) =>
      QuizColors(palette ?? this.palette);
  @override
  QuizColors lerp(ThemeExtension<QuizColors>? other, double t) =>
      other is QuizColors ? QuizColors(palette.lerp(other.palette, t)) : this;
}

extension QuizColorsX on BuildContext {
  QuizColors get quizColors => Theme.of(this).extension<QuizColors>()!;
}
