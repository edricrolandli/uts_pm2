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
    TableRow row(List<String> values, {bool header = false}) => TableRow(
      decoration: header ? BoxDecoration(color: p.ink) : null,
      children: [
        for (final value in values)
          Padding(
            padding: EdgeInsets.all(context.r.sm),
            child: Text(
              value,
              style: header
                  ? AppTextStyles.of(context).monoLabel.copyWith(color: p.paper)
                  : AppTextStyles.of(context).monoData,
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
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Table(
              defaultColumnWidth: const IntrinsicColumnWidth(flex: 1),
              columnWidths: const {0: IntrinsicColumnWidth(flex: 2)},
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                row([
                  AppStrings.nimLabel,
                  AppStrings.correctHeader,
                  AppStrings.scoreHeader,
                  AppStrings.durationHeader,
                ], header: true),
                row([
                  record.nim,
                  AppStrings.correctTotal(record.correct, record.total),
                  AppStrings.scoreValue(record.percent),
                  AppStrings.elapsedTime(
                    record.finishedAt.difference(record.session.startedAt),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
