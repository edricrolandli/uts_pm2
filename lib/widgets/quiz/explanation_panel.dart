import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/quiz_colors.dart';
import '../common/mono_label.dart';
import '../common/ink_surface.dart';

class ExplanationPanel extends StatelessWidget {
  const ExplanationPanel({
    super.key,
    required this.explanation,
    required this.answered,
    required this.correct,
  });
  final String explanation;
  final bool answered;
  final bool correct;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final qc = context.quizColors;
    final content = !answered
        ? const SizedBox.shrink()
        : Semantics(
            liveRegion: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(context.r.sm),
                  decoration: BoxDecoration(
                    color: correct ? qc.correctContainer : qc.wrongContainer,
                    borderRadius: AppGeometry.of(context).radiusSm,
                  ),
                  child: Text(
                    correct ? AppStrings.correct : AppStrings.wrong,
                    style: AppTextStyles.of(context).title.copyWith(
                      color: correct
                          ? qc.onCorrectContainer
                          : qc.onWrongContainer,
                    ),
                  ),
                ),
                SizedBox(height: context.r.sm),
                InkSurface(
                  compact: true,
                  color: scheme.primaryContainer,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MonoLabel(
                        AppStrings.why,
                        color: scheme.onPrimaryContainer,
                      ),
                      SizedBox(height: context.r.sm),
                      Text(
                        explanation,
                        style: AppTextStyles.of(context).body
                            .copyWith(color: scheme.onPrimaryContainer),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
    if (AppMotion.of(context).disabled) return content;
    return AnimatedSize(
      duration: AppMotion.of(context).medium,
      alignment: Alignment.topLeft,
      curve: AppTokens.curveStandard,
      child: AnimatedSwitcher(
        duration: AppMotion.of(context).medium,
        child: content,
      ),
    );
  }
}
