import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/constants/app_strings.dart';
import '../core/constants/asset_paths.dart';
import '../core/responsive/responsive.dart';
import '../core/routes/app_routes.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_tokens.dart';
import '../core/theme/quiz_colors.dart';
import '../widgets/common/app_icon.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _leaving = false;

  void _openHome() {
    if (_leaving) return;
    _leaving = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final geometry = AppGeometry.of(context);
    final motion = AppMotion.of(context);
    final style = AppTextStyles.of(context).code;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.r.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  AssetPaths.logo,
                  width: geometry.logo,
                  height: geometry.logo,
                  semanticsLabel: AppStrings.appName,
                  colorMapper: AssetPaletteMapper(context.quizColors.palette),
                ),
                SizedBox(height: context.r.lg),
                Semantics(
                  label: AppStrings.splashTagline,
                  child: ExcludeSemantics(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: motion.splash,
                      onEnd: _openHome,
                      builder: (context, value, child) {
                        final elapsed =
                            value * AppTokens.durSplash.inMilliseconds;
                        final count =
                            (elapsed ~/ AppTokens.durType.inMilliseconds).clamp(
                              0,
                              AppStrings.splashTagline.length,
                            );
                        final cursorVisible =
                            !motion.disabled &&
                            (elapsed ~/ AppTokens.durCursor.inMilliseconds)
                                .isEven;
                        return Stack(
                          children: [
                            Opacity(
                              opacity: 0,
                              child: Text(
                                '${AppStrings.splashTagline}${AppStrings.cursor}',
                                textAlign: TextAlign.center,
                                style: style,
                              ),
                            ),
                            Positioned.fill(
                              child: Text(
                                '${AppStrings.splashTagline.substring(0, count)}'
                                '${cursorVisible ? AppStrings.cursor : ''}',
                                textAlign: TextAlign.center,
                                style: style,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
