import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/quiz_colors.dart';
import '../../models/quiz_session.dart';

class SegmentedProgress extends StatelessWidget {
  const SegmentedProgress({
    super.key,
    required this.session,
    this.result = false,
  });
  final bool result;
  final QuizSession session;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final qc = context.quizColors;
    final g = AppGeometry.of(context);
    var correct = 0;
    var wrong = 0;
    for (var i = 0; i < session.items.length; i++) {
      final answer = session.answers[i];
      if (answer != null) {
        answer == session.items[i].displayedCorrectIndex ? correct++ : wrong++;
      }
    }
    return Semantics(
      label: AppStrings.progressSemantics(
        session.currentIndex,
        session.items.length,
        correct,
        wrong,
      ),
      child: ExcludeSemantics(
        child: Row(
          children: [
            for (var i = 0; i < session.items.length; i++) ...[
              if (i != 0) SizedBox(width: context.r.xs),
              Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: result ? 0 : 1, end: 1),
                  duration: result
                      ? AppMotion.of(context).segmentStagger * (i + 1)
                      : AppTokens.noMotion,
                  builder: (context, value, child) => Opacity(
                    opacity: result && value < 1 ? 0 : 1,
                    child: child,
                  ),
                  child: AnimatedContainer(
                    duration: AppMotion.of(context).medium,
                    height: g.segmentHeight,
                    decoration: BoxDecoration(
                      borderRadius: AppTokens.fullRadius,
                      color: session.answers[i] != null
                          ? session.answers[i] ==
                                    session.items[i].displayedCorrectIndex
                                ? qc.correct
                                : qc.wrong
                          : i == session.currentIndex
                          ? scheme.primary
                          : scheme.outlineVariant,
                      border: !result && i == session.currentIndex
                          ? Border.all(
                              color: scheme.outline,
                              width: g.strokeThin,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
