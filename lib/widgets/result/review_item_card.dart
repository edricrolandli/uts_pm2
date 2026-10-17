import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/quiz_colors.dart';
import '../../models/session_question.dart';
import '../common/ink_surface.dart';
import '../common/mono_label.dart';
import '../common/app_icon.dart';
import '../quiz/code_block.dart';
import 'review_answer_chip.dart';

class ReviewItemCard extends StatelessWidget {
  const ReviewItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.answer,
  });
  final SessionQuestion item;
  final int index;
  final int? answer;
  @override
  Widget build(BuildContext context) {
    final correct = answer == item.displayedCorrectIndex;
    final g = AppGeometry.of(context);
    final colors = context.quizColors;
    final status = correct ? AppStrings.correct : AppStrings.wrong;
    return InkSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: MonoLabel(AppStrings.questionNumber(index))),
              Semantics(
                label: status,
                child: ExcludeSemantics(
                  child: AppIcon(
                    correct ? AssetPaths.check : AssetPaths.close,
                    color: correct ? colors.correct : colors.wrong,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.r.md),
          Text(item.question.text, style: AppTextStyles.of(context).question),
          if (item.question.codeSnippet != null) ...[
            SizedBox(height: context.r.md),
            CodeBlock(item.question.codeSnippet!),
          ],
          SizedBox(height: context.r.md),
          ReviewAnswerChip(
            label: AppStrings.yourAnswer,
            answer: answer == null
                ? AppStrings.unanswered
                : item.displayedOptions[answer!],
            correct: correct,
          ),
          SizedBox(height: context.r.sm),
          ReviewAnswerChip(
            label: AppStrings.keyAnswer,
            answer: item.displayedOptions[item.displayedCorrectIndex],
            correct: true,
          ),
          SizedBox(height: context.r.sm),
          ExpansionTile(
            key: PageStorageKey(item.question.id),
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.only(bottom: context.r.sm),
            minTileHeight: g.touch,
            shape: const Border(),
            collapsedShape: const Border(),
            iconColor: Theme.of(context).colorScheme.onSurface,
            collapsedIconColor: Theme.of(context).colorScheme.onSurface,
            expansionAnimationStyle: AnimationStyle(
              duration: AppMotion.of(context).medium,
              curve: AppTokens.curveStandard,
            ),
            title: const MonoLabel(AppStrings.why),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  item.question.explanation,
                  style: AppTextStyles.of(context).body,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
