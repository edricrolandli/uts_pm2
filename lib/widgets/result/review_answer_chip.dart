import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/quiz_colors.dart';
import '../common/mono_label.dart';

class ReviewAnswerChip extends StatelessWidget {
  const ReviewAnswerChip({
    super.key,
    required this.label,
    required this.answer,
    required this.correct,
  });
  final String label;
  final String answer;
  final bool correct;
  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;
    final foreground = correct
        ? colors.onCorrectContainer
        : colors.onWrongContainer;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.r.sm),
      decoration: BoxDecoration(
        color: correct ? colors.correctContainer : colors.wrongContainer,
        borderRadius: AppGeometry.of(context).radiusSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonoLabel(label, color: foreground),
          SizedBox(height: context.r.xs),
          Text(
            answer,
            style: AppTextStyles.of(context).body.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
