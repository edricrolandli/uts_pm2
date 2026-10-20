import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_tokens.dart';

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.primary, this.secondary});
  final Widget primary;
  final Widget? secondary;
  @override
  Widget build(BuildContext context) {
    final r = context.r;
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.all(r.md),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: AppGeometry.of(context).strokeThin,
            ),
          ),
        ),
        child: r.actionsHorizontal
            ? Row(
                children: [
                  if (secondary != null) ...[
                    Expanded(child: secondary!),
                    SizedBox(width: r.sm),
                  ],
                  Expanded(child: primary),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  primary,
                  if (secondary != null) ...[
                    SizedBox(height: r.sm),
                    secondary!,
                  ],
                ],
              ),
      ),
    );
  }
}
