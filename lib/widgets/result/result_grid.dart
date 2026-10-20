import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/quiz_colors.dart';
import '../../models/score_record.dart';

class ResultGrid extends StatelessWidget {
  const ResultGrid({super.key, required this.record});
  final ScoreRecord record;
  @override
  Widget build(BuildContext context) {
    final g = AppGeometry.of(context);
    final p = context.quizColors.palette;
    Widget row(List<String> values, {bool header = false}) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < values.length; i++)
          Expanded(
            flex: i == 0 ? 2 : 1,
            child: Padding(
              padding: EdgeInsets.all(context.r.sm),
              child: Text(
                values[i],
                style: header
                    ? AppTextStyles.of(context).monoLabel
                          .copyWith(color: p.paper)
                    : AppTextStyles.of(context).monoData,
              ),
            ),
          ),
      ],
    );
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: g.radiusMd,
        border: Border.all(color: p.ink, width: g.strokeThick),
      ),
      child: Column(
        children: [
          ColoredBox(
            color: p.ink,
            child: row([
              AppStrings.nimLabel,
              AppStrings.correctHeader,
              AppStrings.scoreHeader,
            ], header: true),
          ),
          row([
            record.nim,
            AppStrings.correctTotal(record.correct, record.total),
            AppStrings.scoreValue(record.percent),
          ]),
        ],
      ),
    );
  }
}
