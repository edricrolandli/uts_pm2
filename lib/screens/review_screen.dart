import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_strings.dart';
import '../core/responsive/responsive.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_tokens.dart';
import '../providers/quiz_provider.dart';
import '../models/score_record.dart';
import '../widgets/common/bottom_action_bar.dart';
import '../widgets/common/mono_label.dart';
import '../widgets/result/result_grid.dart';
import '../widgets/quiz/segmented_progress.dart';
import '../widgets/common/responsive_body.dart';
import '../widgets/common/key_button.dart';
import '../widgets/result/review_item_card.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key, this.record, this.detail = false});
  final ScoreRecord? record;
  final bool detail;
  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool _wrongOnly = false;
  @override
  Widget build(BuildContext context) {
    final session =
        widget.record?.session ?? context.watch<QuizProvider>().session;
    final indices = session == null
        ? <int>[]
        : List.generate(session.items.length, (i) => i);
    final wrong = indices
        .where(
          (i) => session!.answers[i] != session.items[i].displayedCorrectIndex,
        )
        .toList();
    if (_wrongOnly) indices.removeWhere((i) => !wrong.contains(i));
    final scheme = Theme.of(context).colorScheme;
    final g = AppGeometry.of(context);
    Widget item(int index) => ReviewItemCard(
      key: ValueKey(session!.items[index].question.id),
      item: session.items[index],
      index: index,
      answer: session.answers[index],
    );
    return Scaffold(
      body: ResponsiveBody(
        bottomBar: BottomActionBar(
          primary: KeyButton(
            label: AppStrings.back,
            secondary: true,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.detail ? AppStrings.attemptDetail : AppStrings.review,
              style: AppTextStyles.of(context).headline,
            ),
            if (widget.detail && widget.record != null) ...[
              SizedBox(height: context.r.sm),
              MonoLabel(AppStrings.historyDate(widget.record!.finishedAt)),
              Text(
                widget.record!.playerName,
                style: AppTextStyles.of(context).headline,
              ),
              SizedBox(height: context.r.md),
              SegmentedProgress(
                session: session!,
                result: true,
                animate: false,
              ),
              SizedBox(height: context.r.md),
              ResultGrid(record: widget.record!),
              MonoLabel(
                AppStrings.resultFooter(
                  widget.record!.finishedAt.difference(session.startedAt),
                ),
              ),
            ],
            SizedBox(height: context.r.md),
            SegmentedButton<bool>(
              segments: [
                const ButtonSegment(
                  value: false,
                  label: Text(AppStrings.allAnswers),
                ),
                ButtonSegment(
                  value: true,
                  label: Text(AppStrings.wrongAnswers(wrong.length)),
                ),
              ],
              selected: {_wrongOnly},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  setState(() => _wrongOnly = selection.single),
              style: ButtonStyle(
                textStyle: WidgetStatePropertyAll(
                  AppTextStyles.of(context).monoData,
                ),
                minimumSize: WidgetStatePropertyAll(Size(0, g.touch)),
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(
                    horizontal: context.r.sm,
                    vertical: context.r.sm,
                  ),
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(borderRadius: g.radiusMd),
                ),
                side: WidgetStatePropertyAll(
                  BorderSide(color: scheme.outline, width: g.strokeThick),
                ),
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? scheme.onSurface
                      : scheme.surface,
                ),
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? scheme.surface
                      : scheme.onSurface,
                ),
                overlayColor: const WidgetStatePropertyAll(
                  AppTokens.transparent,
                ),
                animationDuration: AppMotion.of(context).short,
              ),
            ),
            SizedBox(height: context.r.md),
            if (_wrongOnly && wrong.isEmpty && session != null)
              Padding(
                padding: EdgeInsets.only(bottom: context.r.md),
                child: Text(
                  AppStrings.noWrongAnswers,
                  style: AppTextStyles.of(context).body,
                ),
              ),
            if (session == null)
              Text(AppStrings.noSession, style: AppTextStyles.of(context).body),
            if (context.r.isCompact)
              for (final index in indices)
                Padding(
                  padding: EdgeInsets.only(bottom: context.r.md),
                  child: item(index),
                )
            else
              for (var i = 0; i < indices.length; i += 2)
                Padding(
                  padding: EdgeInsets.only(bottom: context.r.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: item(indices[i])),
                      SizedBox(width: context.r.md),
                      Expanded(
                        child: i + 1 < indices.length
                            ? item(indices[i + 1])
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
