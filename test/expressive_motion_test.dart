import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uts_pm2/core/theme/app_theme.dart';
import 'package:uts_pm2/core/theme/app_tokens.dart';
import 'package:uts_pm2/widgets/quiz/option_tile.dart';
import 'package:uts_pm2/widgets/result/score_display.dart';

void main() {
  testWidgets(
    'badge morphs throughout reveal and shake resets on reduce motion',
    (tester) async {
      var state = OptionState.idle;
      var reduced = false;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(disableAnimations: reduced),
                child: Scaffold(
                  body: OptionTile(
                    index: 0,
                    text: 'SELECT',
                    state: state,
                    onPressed: state == OptionState.idle ? () {} : null,
                  ),
                ),
              );
            },
          ),
        ),
      );
      final containers = find.descendant(
        of: find.byType(OptionTile),
        matching: find.byType(AnimatedContainer),
      );
      final badge = containers.last;
      final context = tester.element(badge);
      final geometry = AppGeometry.of(context);
      BoxDecoration decoration() =>
          tester
                  .widget<Container>(
                    find
                        .descendant(of: badge, matching: find.byType(Container))
                        .first,
                  )
                  .decoration!
              as BoxDecoration;
      expect(decoration().borderRadius, geometry.badgeCircle);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(OptionTile)),
      );
      await tester.pump();
      expect(
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
        AppTokens.pressedScale,
      );
      await gesture.up();
      update(() => state = OptionState.wrong);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      final radius = (decoration().borderRadius! as BorderRadius).topLeft.x;
      expect(radius, lessThan(geometry.badge / 2));
      expect(radius, greaterThan(geometry.radiusSm.topLeft.x));
      update(() => reduced = true);
      await tester.pump();
      update(() => reduced = false);
      await tester.pumpAndSettle();
      final translation = tester
          .widgetList<Transform>(
            find.descendant(
              of: find.byType(OptionTile),
              matching: find.byType(Transform),
            ),
          )
          .first;
      expect(translation.transform.storage[12], 0);
      expect(decoration().borderRadius, geometry.radiusSm);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('score counts up once and reduced motion shows final value', (
    tester,
  ) async {
    Future<void> pump(bool reduced) => tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: const Scaffold(body: ScoreDisplay(percent: 80)),
        ),
      ),
    );
    await pump(false);
    expect(find.text('0'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('0'), findsNothing);
    expect(find.text('80'), findsNothing);
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('80'), findsOneWidget);
    await pump(false);
    expect(find.text('80'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await pump(true);
    expect(find.text('80'), findsOneWidget);
  });
}
