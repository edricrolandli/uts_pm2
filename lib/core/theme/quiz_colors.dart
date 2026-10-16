import 'package:flutter/material.dart';

@immutable
class QuizColors extends ThemeExtension<QuizColors> {
  const QuizColors({
    required this.correct,
    required this.correctContainer,
    required this.wrong,
    required this.wrongContainer,
    required this.selected,
    required this.selectedContainer,
  });

  final Color correct;
  final Color correctContainer;
  final Color wrong;
  final Color wrongContainer;
  final Color selected;
  final Color selectedContainer;

  static const light = QuizColors(
    correct: Color(0xFF2E7D32),
    correctContainer: Color(0xFFDCEFDD),
    wrong: Color(0xFFC62828),
    wrongContainer: Color(0xFFFADBD8),
    selected: Color(0xFF0E7C86),
    selectedContainer: Color(0xFFD3ECEE),
  );

  static const dark = QuizColors(
    correct: Color(0xFF81C784),
    correctContainer: Color(0xFF1F3D22),
    wrong: Color(0xFFEF9A9A),
    wrongContainer: Color(0xFF4A1F1F),
    selected: Color(0xFF7FD1D9),
    selectedContainer: Color(0xFF16393C),
  );

  @override
  QuizColors copyWith({
    Color? correct,
    Color? correctContainer,
    Color? wrong,
    Color? wrongContainer,
    Color? selected,
    Color? selectedContainer,
  }) {
    return QuizColors(
      correct: correct ?? this.correct,
      correctContainer: correctContainer ?? this.correctContainer,
      wrong: wrong ?? this.wrong,
      wrongContainer: wrongContainer ?? this.wrongContainer,
      selected: selected ?? this.selected,
      selectedContainer: selectedContainer ?? this.selectedContainer,
    );
  }

  @override
  QuizColors lerp(ThemeExtension<QuizColors>? other, double t) {
    if (other is! QuizColors) return this;
    return QuizColors(
      correct: Color.lerp(correct, other.correct, t)!,
      correctContainer: Color.lerp(
        correctContainer,
        other.correctContainer,
        t,
      )!,
      wrong: Color.lerp(wrong, other.wrong, t)!,
      wrongContainer: Color.lerp(wrongContainer, other.wrongContainer, t)!,
      selected: Color.lerp(selected, other.selected, t)!,
      selectedContainer: Color.lerp(
        selectedContainer,
        other.selectedContainer,
        t,
      )!,
    );
  }
}

extension QuizColorsX on BuildContext {
  QuizColors get quizColors => Theme.of(this).extension<QuizColors>()!;
}
