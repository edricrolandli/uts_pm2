import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/constants/app_strings.dart';
import '../core/constants/asset_paths.dart';
import '../core/responsive/responsive.dart';
import '../core/routes/app_routes.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_tokens.dart';
import '../core/theme/quiz_colors.dart';
import '../widgets/common/responsive_body.dart';
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
    return Scaffold(
      body: ResponsiveBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: context.r.hp(.4)),
            SvgPicture.asset(
              AssetPaths.logo,
              width: geometry.logo,
              height: geometry.logo,
              semanticsLabel: AppStrings.appName,
              colorMapper: AssetPaletteMapper(context.quizColors.palette),
            ),
            SizedBox(height: context.r.lg),
            Semantics(
              label: AppStrings.splashQuery,
              child: ExcludeSemantics(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: motion.splash,
                  onEnd: _openHome,
                  builder: (context, value, child) {
                    final elapsed = value * AppTokens.durSplash.inMilliseconds;
                    final count = (elapsed ~/ AppTokens.durType.inMilliseconds)
                        .clamp(0, AppStrings.splashQuery.length);
                    final cursorVisible =
                        !motion.disabled &&
                        (elapsed ~/ AppTokens.durCursor.inMilliseconds).isEven;
                    return Text(
                      '${AppStrings.splashQuery.substring(0, count)}'
                      '${cursorVisible ? AppStrings.cursor : ''}',
                      style: AppTextStyles.of(context).code,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
