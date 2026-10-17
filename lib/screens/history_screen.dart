import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_strings.dart';
import '../core/responsive/responsive.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/history_provider.dart';
import '../widgets/common/responsive_body.dart';
import '../widgets/common/ink_surface.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/key_button.dart';
import '../widgets/common/confirm_dialog.dart';
import '../widgets/history/history_row.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  Future<void> _clear(BuildContext context) async {
    final history = context.read<HistoryProvider>();
    final confirmed = await ConfirmDialog.ask(
      context,
      title: AppStrings.clearHistoryTitle,
      message: AppStrings.clearHistoryMessage,
      cancelLabel: AppStrings.cancel,
      confirmLabel: AppStrings.delete,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await history.clear();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text(AppStrings.saveFailed)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final records = context.watch<HistoryProvider>().records;
    return Scaffold(
      body: ResponsiveBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.historyTitle,
              style: AppTextStyles.of(context).headline,
            ),
            SizedBox(height: context.r.lg),
            if (records.isEmpty)
              const EmptyState(message: AppStrings.historyEmpty)
            else
              InkSurface(
                child: Column(
                  children: [
                    const HistoryRow.header(),
                    for (final record in records) HistoryRow(record: record),
                  ],
                ),
              ),
            SizedBox(height: context.r.lg),
            if (records.isNotEmpty) ...[
              KeyButton(
                label: AppStrings.clearHistory,
                secondary: true,
                onPressed: () => _clear(context),
              ),
              SizedBox(height: context.r.sm),
            ],
            KeyButton(
              label: AppStrings.back,
              secondary: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
