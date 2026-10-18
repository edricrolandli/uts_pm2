import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_strings.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_tokens.dart';
import 'providers/theme_provider.dart';

class QueryQuestApp extends StatelessWidget {
  const QueryQuestApp({super.key});
  @override
  Widget build(BuildContext context) => MediaQuery.fromView(
    view: View.of(context),
    child: Builder(builder: _buildApp),
  );

  Widget _buildApp(BuildContext context) => MaterialApp(
    title: AppStrings.appName,
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    themeMode: context.watch<ThemeProvider>().mode,
    themeAnimationDuration: AppMotion.of(context).medium,
    themeAnimationCurve: AppTokens.curveStandard,
    initialRoute: AppRoutes.initial,
    onGenerateInitialRoutes: (_) => [
      AppRoutes.onGenerateRoute(const RouteSettings(name: AppRoutes.initial)),
    ],
    onGenerateRoute: AppRoutes.onGenerateRoute,
    builder: (context, child) {
      final media = MediaQuery.of(context);
      return MediaQuery(
        data: media.copyWith(
          textScaler: media.textScaler.clamp(
            maxScaleFactor: AppTokens.textScaleMax,
          ),
        ),
        child: child!,
      );
    },
  );
}
