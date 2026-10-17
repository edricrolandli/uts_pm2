import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../core/responsive/responsive.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/common/responsive_body.dart';
import '../widgets/common/key_button.dart';

// Route target only. Result/Review/History are implemented on Day 4.
class PendingScreen extends StatelessWidget {
  const PendingScreen({
    super.key,
    required this.title,
    this.message = AppStrings.upcoming,
    required this.onReturn,
  });
  final String title;
  final String message;
  final VoidCallback onReturn;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: ResponsiveBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTextStyles.of(context).headline),
          SizedBox(height: context.r.md),
          Text(message, style: AppTextStyles.of(context).body),
          SizedBox(height: context.r.lg),
          KeyButton(label: AppStrings.returnHome, onPressed: onReturn),
        ],
      ),
    ),
  );
}
