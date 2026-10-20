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
import '../widgets/common/bottom_action_bar.dart';
import '../widgets/common/mono_label.dart';
import '../core/routes/app_routes.dart';
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
        bottomBar: BottomActionBar(
          primary: KeyButton(
            label: AppStrings.back,
            onPressed: () => Navigator.pop(context),
          ),
          secondary: records.isEmpty
              ? null
              : KeyButton(
                  label: AppStrings.clearHistory,
                  destructive: true,
                  secondary: true,
                  onPressed: () => _clear(context),
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.historyTitle,
              style: AppTextStyles.of(context).headline,
            ),
            if (context.watch<HistoryProvider>().nim != null)
              MonoLabel(
                AppStrings.nimIdentity(context.watch<HistoryProvider>().nim!),
              ),
            SizedBox(height: context.r.lg),
            if (records.isEmpty)
              const EmptyState(message: AppStrings.historyEmpty)
            else
              InkSurface(
                child: Column(
                  children: [
                    const HistoryRow.header(),
                    for (final record in records)
                      HistoryRow(
                        record: record,
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.detail,
                          arguments: record,
                        ),
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
