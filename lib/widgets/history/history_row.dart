import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/score_record.dart';

class HistoryRow extends StatelessWidget {
  const HistoryRow({super.key, required ScoreRecord this.record});
  const HistoryRow.header({super.key}) : record = null;
  final ScoreRecord? record;
  @override
  Widget build(BuildContext context) {
    final entry = record;
    final style = entry == null
        ? AppTextStyles.of(context).monoLabel
        : AppTextStyles.of(context).monoData;
    Widget cell(String value, int flex) => Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.r.xs),
        child: Text(value, style: style),
      ),
    );
    return Container(
      padding: EdgeInsets.symmetric(vertical: context.r.sm),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: AppGeometry.of(context).strokeThin,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          cell(entry?.playerName ?? AppStrings.nameLabel, 3),
          cell(
            entry == null
                ? AppStrings.scoreHeader
                : AppStrings.scoreValue(entry.percent),
            1,
          ),
          cell(
            entry == null
                ? AppStrings.dateHeader
                : AppStrings.historyDate(entry.finishedAt),
            2,
          ),
        ],
      ),
    );
  }
}
