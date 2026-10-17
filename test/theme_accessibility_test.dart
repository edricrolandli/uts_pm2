import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uts_pm2/core/theme/app_theme.dart';
import 'package:uts_pm2/core/theme/app_tokens.dart';
import 'package:uts_pm2/core/theme/quiz_colors.dart';

double contrast(Color a, Color b) {
  final x = a.computeLuminance();
  final y = b.computeLuminance();
  return (math.max(x, y) + .05) / (math.min(x, y) + .05);
}

void main() {
  for (final theme in [AppTheme.light(), AppTheme.dark()]) {
    test(
      '${theme.brightness}: active text >= 4.5 and control borders >= 3',
      () {
        final scheme = theme.colorScheme;
        final p = theme.extension<QuizColors>()!.palette;
        for (final pair in [
          (p.ink, p.paper),
          (p.ink, p.surface),
          (p.inkMuted, p.paper),
          (p.inkMuted, p.surface),
          (scheme.onPrimary, p.amber),
          (p.onAmberContainer, p.amberContainer),
          (p.onCorrectContainer, p.correctContainer),
          (p.onWrongContainer, p.wrongContainer),
          (p.onWrongContainer, p.paper),
          (p.codeText, p.codeBg),
          (p.amber, p.codeBg),
        ]) {
          expect(contrast(pair.$1, pair.$2), greaterThanOrEqualTo(4.5));
        }
        for (final pair in [
          (p.outlineStrong, p.surface),
          (p.correct, p.surface),
          (p.wrong, p.surface),
        ]) {
          expect(contrast(pair.$1, pair.$2), greaterThanOrEqualTo(3));
        }
      },
    );
  }
  test('semantic extension lerps both endpoints without losing tokens', () {
    expect(
      QuizColors.light.lerp(QuizColors.dark, 0).codeBg,
      QuizColors.light.codeBg,
    );
    expect(
      QuizColors.light.lerp(QuizColors.dark, 1).onCorrectContainer,
      QuizColors.dark.onCorrectContainer,
    );
    expect(
      QuizColors.light.lerp(QuizColors.dark, .5).keyEdge,
      Color.lerp(QuizColors.light.keyEdge, QuizColors.dark.keyEdge, .5),
    );
  });
  testWidgets('touch target stays at least 48dp on narrow phones', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(320, 568)),
          child: Builder(
            builder: (context) {
              expect(AppGeometry.of(context).touch, greaterThanOrEqualTo(48));
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  });
}
