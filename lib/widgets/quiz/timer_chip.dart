import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/quiz_colors.dart';

class TimerChip extends StatelessWidget {
  const TimerChip({
    super.key,
    required this.seconds,
    required this.answered,
    this.expired = false,
  });
  final int seconds;
  final bool answered;
  // Soal ditutup oleh waktu habis: tampilkan "Habis", bukan 00:00 terkunci.
  final bool expired;

  @override
  Widget build(BuildContext context) {
    final urgent = expired || (!answered && seconds <= kTimerWarningSeconds);
    final label = expired
        ? AppStrings.timerExpired
        : answered
        ? AppStrings.locked
        : seconds == 0
        ? AppStrings.timerExpired
        : urgent
        ? AppStrings.timerWarning
        : AppStrings.timerReady;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      // Stable within each threshold: no spoken announcement every second.
      label: label,
      liveRegion: urgent,
      child: ExcludeSemantics(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.r.sm,
            vertical: context.r.xs,
          ),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: AppTokens.fullRadius,
            border: Border.all(
              color: urgent ? context.quizColors.wrong : scheme.outline,
              width: AppGeometry.of(context).strokeThin,
            ),
          ),
          child: Text(
            expired ? AppStrings.timerOut : AppStrings.timerValue(seconds),
            style: AppTextStyles.of(context).monoData.copyWith(
              color: urgent ? context.quizColors.wrong : scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
