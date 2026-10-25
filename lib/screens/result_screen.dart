import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_strings.dart';
import '../core/responsive/responsive.dart';
import '../core/routes/app_routes.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/quiz_provider.dart';
import '../widgets/common/responsive_body.dart';
import '../widgets/common/mono_label.dart';
import '../widgets/common/key_button.dart';
import '../widgets/common/bottom_action_bar.dart';
import '../widgets/quiz/segmented_progress.dart';
import '../widgets/result/score_display.dart';
import '../widgets/result/result_grid.dart';
import 'no_session_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final record = quiz.result;
    final session = quiz.session;
    void home() =>
        Navigator.of(context).popUntil(ModalRoute.withName(AppRoutes.home));
    if (record == null || session == null) {
      return NoSessionScreen(title: AppStrings.noSession, onReturn: home);
    }
    final score = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScoreDisplay(percent: record.percent),
        SizedBox(height: context.r.lg),
        SegmentedProgress(session: session, result: true),
      ],
    );
    final details = ResultGrid(record: record);
    return Scaffold(
      body: ResponsiveBody(
        bottomBar: BottomActionBar(
          primary: KeyButton(
            label: AppStrings.seeReview,
            onPressed: () =>
                Navigator.of(context)
                    .pushNamed(AppRoutes.review, arguments: record),
          ),
          secondary: KeyButton(
            label: AppStrings.returnHome,
            secondary: true,
            onPressed: home,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MonoLabel(AppStrings.resultEyebrow),
            SizedBox(height: context.r.sm),
            Text(record.playerName, style: AppTextStyles.of(context).headline),
            SizedBox(height: context.r.xl),
            if (context.r.isCompact) ...[
              score,
              SizedBox(height: context.r.lg),
              details,
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: score),
                  SizedBox(width: context.r.lg),
                  Expanded(child: details),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
