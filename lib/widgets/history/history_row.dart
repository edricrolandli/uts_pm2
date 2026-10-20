import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/score_record.dart';
import '../../core/constants/asset_paths.dart';
import '../common/app_icon.dart';

class HistoryRow extends StatelessWidget {
  const HistoryRow({
    super.key,
    required ScoreRecord this.record,
    this.onPressed,
  });
  const HistoryRow.header({super.key}) : record = null, onPressed = null;
  final ScoreRecord? record;
  final VoidCallback? onPressed;
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
    return InkWell(
      onTap: onPressed,
      child: Container(
        constraints: BoxConstraints(minHeight: AppGeometry.of(context).touch),
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
            cell(
              entry == null
                  ? AppStrings.dateHeader
                  : AppStrings.historyDate(entry.finishedAt),
              2,
            ),
            cell(
              entry == null
                  ? AppStrings.correctHeader
                  : AppStrings.correctTotal(entry.correct, entry.total),
              1,
            ),
            cell(
              entry == null
                  ? AppStrings.scoreHeader
                  : AppStrings.scoreValue(entry.percent),
              1,
            ),
            if (entry != null) const AppIcon(AssetPaths.arrow),
          ],
        ),
      ),
    );
  }
}
