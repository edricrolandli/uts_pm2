import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';

class MonoLabel extends StatelessWidget {
  const MonoLabel(this.text, {super.key, this.color});
  final String text;
  final Color? color;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTextStyles.of(context).monoLabel.copyWith(
      color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}
