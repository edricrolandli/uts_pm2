import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uts_pm2/core/constants/app_strings.dart';
import 'package:uts_pm2/core/routes/app_routes.dart';
import 'package:uts_pm2/core/theme/app_theme.dart';
import 'package:uts_pm2/screens/splash_screen.dart';

void main() {
  for (final reduced in [false, true]) {
    testWidgets('splash types then replaces itself, reduced=$reduced', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          FakeAccessibilityFeatures(disableAnimations: reduced);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: const SplashScreen(),
          routes: {
            AppRoutes.home: (_) => const Scaffold(body: Text('Home test')),
          },
        ),
      );
      final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
      expect(tester.getCenter(find.byType(SvgPicture)).dx, screen.width / 2);
      if (!reduced) {
        await tester.pump(const Duration(milliseconds: 280));
        expect(find.text('#SemangatI_'), findsOneWidget);
        expect(find.text('Home test'), findsNothing);
      }
      await tester.pumpAndSettle();
      expect(find.text('Home test'), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
      expect(
        Navigator.of(tester.element(find.text('Home test'))).canPop(),
        isFalse,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('disposing splash early does not navigate later', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const SplashScreen()),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
    expect(find.text(AppStrings.splashTagline), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
