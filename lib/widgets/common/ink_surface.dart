import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_tokens.dart';

class InkSurface extends StatelessWidget {
  const InkSurface({
    super.key,
    required this.child,
    this.emphasis = false,
    this.compact = false,
    this.color,
  });
  final Widget child;
  final bool emphasis;
  final bool compact;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final g = AppGeometry.of(context);
    return Container(
      padding: EdgeInsets.all(context.r.md),
      decoration: BoxDecoration(
        color: color ?? scheme.surface,
        borderRadius: compact ? g.radiusMd : g.radiusLg,
        border: Border.all(
          color: emphasis ? scheme.outline : scheme.outlineVariant,
          width: emphasis ? g.strokeThick : g.strokeThin,
        ),
      ),
      child: child,
    );
  }
}
