import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_tokens.dart';
import 'ink_surface.dart';
import 'key_button.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.confirmLabel,
    this.destructive = false,
  });
  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;
  final bool destructive;
  static Future<bool> ask(
    BuildContext context, {
    required String title,
    required String message,
    required String cancelLabel,
    required String confirmLabel,
    bool destructive = false,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (_) => ConfirmDialog(
          title: title,
          message: message,
          cancelLabel: cancelLabel,
          confirmLabel: confirmLabel,
          destructive: destructive,
        ),
      ) ??
      false;
  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: EdgeInsets.all(context.r.md),
    shape: RoundedRectangleBorder(
      borderRadius: AppGeometry.of(context).radiusLg,
    ),
    child: SingleChildScrollView(
      child: InkSurface(
        emphasis: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.of(context).headline),
            SizedBox(height: context.r.sm),
            Text(message, style: AppTextStyles.of(context).body),
            SizedBox(height: context.r.lg),
            KeyButton(
              label: confirmLabel,
              destructive: destructive,
              secondary: destructive,
              onPressed: () => Navigator.pop(context, true),
            ),
            SizedBox(height: context.r.sm),
            KeyButton(
              label: cancelLabel,
              secondary: true,
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        ),
      ),
    ),
  );
}
