import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_tokens.dart';
import '../common/mono_label.dart';

class ScoreDisplay extends StatelessWidget {
  const ScoreDisplay({super.key, required this.percent});
  final double percent;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Semantics(
        label: AppStrings.scoreValue(percent),
        child: ExcludeSemantics(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percent),
            duration: AppMotion.of(context).score,
            curve: AppTokens.curveStandard,
            builder: (context, value, child) => Text(
              AppStrings.scoreValue(value),
              style: AppTextStyles.of(context).displayXL,
            ),
          ),
        ),
      ),
      const MonoLabel(AppStrings.outOfHundred),
      SizedBox(height: context.r.md),
      Text(
        AppStrings.grade(percent),
        style: AppTextStyles.of(context).headline,
      ),
    ],
  );
}
