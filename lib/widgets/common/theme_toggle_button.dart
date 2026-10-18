import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/theme/app_tokens.dart';
import '../../providers/theme_provider.dart';
import 'app_icon.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});
  @override
  Widget build(BuildContext context) {
    final mode = context.select<ThemeProvider, ThemeMode>(
      (value) => value.mode,
    );
    // Use the destination mode, not the brightness mid-theme-transition.
    final isDark =
        mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    final g = AppGeometry.of(context);
    return IconButton(
      tooltip: isDark ? AppStrings.lightMode : AppStrings.darkMode,
      constraints: BoxConstraints(minWidth: g.touch, minHeight: g.touch),
      onPressed: () async {
        try {
          await context.read<ThemeProvider>().toggle();
        } catch (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppStrings.saveFailed)),
            );
          }
        }
      },
      icon: AnimatedRotation(
        turns: isDark ? AppTokens.themeTurn : 0,
        duration: AppMotion.of(context).medium,
        curve: AppTokens.curveStandard,
        child: AppIcon(isDark ? AssetPaths.sun : AssetPaths.moon),
      ),
    );
  }
}
