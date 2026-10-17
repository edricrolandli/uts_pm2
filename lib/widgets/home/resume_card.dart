import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/quiz_session.dart';
import '../common/ink_surface.dart';
import '../common/key_button.dart';

class ResumeCard extends StatelessWidget {
  const ResumeCard({
    super.key,
    required this.session,
    required this.onResume,
    required this.onDiscard,
  });
  final QuizSession session;
  final VoidCallback? onResume;
  final VoidCallback? onDiscard;
  @override
  Widget build(BuildContext context) => InkSurface(
    emphasis: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppStrings.resumeTitle, style: AppTextStyles.of(context).title),
        SizedBox(height: context.r.sm),
        Text(
          AppStrings.resumeDetail(
            session.playerName,
            session.currentIndex,
            session.items.length,
          ),
          style: AppTextStyles.of(context).body,
        ),
        SizedBox(height: context.r.md),
        KeyButton(
          label: AppStrings.resume,
          icon: AssetPaths.resume,
          onPressed: onResume,
        ),
        SizedBox(height: context.r.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onDiscard,
            style: TextButton.styleFrom(
              minimumSize: Size(0, AppGeometry.of(context).touch),
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
            child: Text(
              AppStrings.discard,
              style: AppTextStyles.of(context).body,
            ),
          ),
        ),
      ],
    ),
  );
}
