import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/quiz_colors.dart';
import 'app_icon.dart';

class KeyButton extends StatelessWidget {
  const KeyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.secondary = false,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool secondary;
  final String? icon;
  @override
  Widget build(BuildContext context) {
    final g = AppGeometry.of(context);
    final scheme = Theme.of(context).colorScheme;
    final active = onPressed != null;
    final foreground = !active
        ? scheme.onSurfaceVariant
        : secondary
        ? scheme.onSurface
        : scheme.onPrimary;
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        minimumSize: WidgetStatePropertyAll(
          Size(0, g.buttonHeight + g.keyEdge),
        ),
        foregroundColor: WidgetStatePropertyAll(foreground),
        shape: const WidgetStatePropertyAll(StadiumBorder()),
        overlayColor: const WidgetStatePropertyAll(AppTokens.transparent),
        backgroundBuilder: (context, states, child) {
          final pressed = states.contains(WidgetState.pressed);
          final focused = states.contains(WidgetState.focused);
          final edge = secondary || !active ? AppTokens.zero : g.keyEdge;
          return DecoratedBox(
            decoration: BoxDecoration(
              color: secondary
                  ? AppTokens.transparent
                  : context.quizColors.keyEdge,
              borderRadius: AppTokens.fullRadius,
            ),
            child: AnimatedPadding(
              duration: AppMotion.of(context).short,
              curve: AppTokens.curveStandard,
              padding: EdgeInsets.only(
                top: pressed ? edge : 0,
                bottom: pressed ? 0 : edge,
              ),
              child: Container(
                constraints: BoxConstraints(minHeight: g.buttonHeight),
                padding: EdgeInsets.symmetric(
                  horizontal: context.r.md,
                  vertical: context.r.sm,
                ),
                decoration: BoxDecoration(
                  color: !active
                      ? scheme.outlineVariant
                      : secondary
                      ? scheme.surface
                      : scheme.primary,
                  borderRadius: AppTokens.fullRadius,
                  border: Border.all(
                    color: focused ? scheme.onSurface : scheme.outline,
                    width: focused ? g.strokeThick : g.strokeThin,
                  ),
                ),
                child: child,
              ),
            ),
          );
        },
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.of(context).button
                  .copyWith(color: foreground),
            ),
          ),
          if (icon != null) ...[
            SizedBox(width: context.r.sm),
            AppIcon(icon!, color: foreground),
          ],
        ],
      ),
    );
  }
}
