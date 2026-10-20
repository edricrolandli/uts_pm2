import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uts_pm2/app.dart';
import 'package:uts_pm2/core/constants/app_strings.dart';
import 'package:uts_pm2/core/routes/app_routes.dart';
import 'package:uts_pm2/providers/quiz_provider.dart';
import 'package:uts_pm2/providers/history_provider.dart';
import 'package:uts_pm2/providers/theme_provider.dart';
import 'package:uts_pm2/services/storage_service.dart';
import 'package:uts_pm2/screens/home_screen.dart';
import 'package:uts_pm2/screens/result_screen.dart';
import 'package:uts_pm2/screens/review_screen.dart';
import 'package:uts_pm2/widgets/history/history_row.dart';
import 'package:uts_pm2/core/theme/app_tokens.dart';
import 'package:uts_pm2/widgets/result/review_item_card.dart';

void main() {
  late QuizProvider quiz;
  late HistoryProvider history;
  late ThemeProvider theme;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService(await SharedPreferences.getInstance());
    history = HistoryProvider(storage);
    theme = ThemeProvider(storage);
    quiz = QuizProvider(
      storage: storage,
      onFinished: history.add,
      random: Random(7),
    );
    await Future.wait([history.load(), theme.load(), quiz.load()]);
  });
  tearDown(() {
    quiz.dispose();
    history.dispose();
    theme.dispose();
  });
  Future<void> finish(WidgetTester tester) => tester.runAsync(() async {
    await quiz.startNew('Nama dua puluh huruf', '241401079');
    for (var i = 0; i < 10; i++) {
      await quiz.selectAnswer(
        (quiz.currentQuestion!.displayedCorrectIndex + (i.isOdd ? 1 : 0)) % 4,
      );
      if (i < 9) await quiz.next();
    }
    await quiz.finish();
  });
  Future<void> pump(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: quiz),
          ChangeNotifierProvider.value(value: history),
          ChangeNotifierProvider.value(value: theme),
        ],
        child: const QueryQuestApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> open(WidgetTester tester, String route) async {
    Navigator.of(tester.element(find.byType(HomeScreen))).pushNamed(route);
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String label) async {
    final target = find.text(label).last;
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  testWidgets('Perfect score supports reduced motion and empty wrong filter', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.runAsync(() async {
      await quiz.startNew('Dina', '241401079');
      for (var i = 0; i < 10; i++) {
        await quiz.selectAnswer(quiz.currentQuestion!.displayedCorrectIndex);
        if (i < 9) await quiz.next();
      }
      await quiz.finish();
    });
    await pump(tester, const Size(360, 640));
    await open(tester, AppRoutes.result);
    final context = tester.element(find.byType(ResultScreen));
    expect(AppMotion.of(context).score, Duration.zero);
    expect(AppMotion.of(context).segmentStagger, Duration.zero);
    expect(find.text('100'), findsNWidgets(2));
    await tap(tester, AppStrings.seeReview);
    await tap(tester, AppStrings.wrongAnswers(0));
    expect(find.byType(ReviewItemCard), findsNothing);
    expect(find.text(AppStrings.noWrongAnswers), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final size in [
    const Size(360, 640),
    const Size(412, 915),
    const Size(640, 360),
    const Size(1280, 800),
  ]) {
    testWidgets('History empty, populated, cancel and clear at $size', (
      tester,
    ) async {
      await pump(tester, size);
      await open(tester, AppRoutes.history);
      expect(find.text(AppStrings.historyEmpty), findsOneWidget);
      expect(find.text(AppStrings.clearHistory), findsNothing);
      expect(tester.takeException(), isNull);
      await tap(tester, AppStrings.back);
      await finish(tester);
      await open(tester, AppRoutes.history);
      expect(find.byType(HistoryRow), findsNWidgets(2));
      expect(
        tester.getTopLeft(find.text(AppStrings.correctHeader)).dx,
        tester
            .getTopLeft(
              find.text(
                AppStrings.correctTotal(
                  quiz.result!.correct,
                  quiz.result!.total,
                ),
              ),
            )
            .dx,
      );
      expect(
        tester.getTopLeft(find.text(AppStrings.scoreHeader)).dx,
        tester
            .getTopLeft(find.text(AppStrings.scoreValue(quiz.result!.percent)))
            .dx,
      );
      await tap(tester, AppStrings.historyDate(quiz.result!.finishedAt));
      expect(find.text(AppStrings.attemptDetail), findsOneWidget);
      expect(find.byType(ReviewItemCard), findsNWidgets(10));
      expect(find.text('241401079'), findsNothing);
      expect(find.text(quiz.result!.playerName), findsNothing);
      await tap(tester, AppStrings.back);
      expect(tester.takeException(), isNull);
      await tap(tester, AppStrings.clearHistory);
      expect(find.text(AppStrings.clearHistoryTitle), findsOneWidget);
      await tap(tester, AppStrings.cancel);
      expect(history.records, hasLength(1));
      await tap(tester, AppStrings.clearHistory);
      await tap(tester, AppStrings.delete);
      expect(history.records, isEmpty);
      expect(find.text(AppStrings.historyEmpty), findsOneWidget);
      await tester.runAsync(history.load);
      expect(history.records, isEmpty);
      expect(tester.takeException(), isNull);
    });
    testWidgets(
      'Review filters shuffled answers and expands explanations at $size',
      (tester) async {
        await finish(tester);
        await pump(tester, size);
        await open(tester, AppRoutes.result);
        await tap(tester, AppStrings.seeReview);
        expect(find.byType(ReviewScreen), findsOneWidget);
        expect(find.byType(ReviewItemCard), findsNWidgets(10));
        expect(tester.takeException(), isNull);
        await tap(tester, AppStrings.wrongAnswers(5));
        expect(find.byType(ReviewItemCard), findsNWidgets(5));
        final card = tester.widget<ReviewItemCard>(
          find.byType(ReviewItemCard).first,
        );
        expect(card.index, 1);
        expect(card.answer, isNot(card.item.displayedCorrectIndex));
        final explanation = card.item.question.explanation;
        expect(find.text(explanation), findsNothing);
        await tester.ensureVisible(find.text(AppStrings.why).first);
        await tester.tap(find.text(AppStrings.why).first);
        await tester.pumpAndSettle();
        expect(find.text(explanation), findsOneWidget);
        await tester.tap(find.text(AppStrings.why).first);
        await tester.pumpAndSettle();
        expect(find.text(explanation), findsNothing);
        expect(tester.takeException(), isNull);
        await tap(tester, AppStrings.allAnswers);
        expect(find.byType(ReviewItemCard), findsNWidgets(10));
        await tap(tester, AppStrings.back);
        expect(find.byType(ResultScreen), findsOneWidget);
        expect(history.records, hasLength(1));
      },
    );
    testWidgets('Result fits $size with large text and records once', (
      tester,
    ) async {
      await finish(tester);
      await pump(tester, size);
      await open(tester, AppRoutes.result);
      expect(find.byType(ResultScreen), findsOneWidget);
      expect(find.text('50'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
      await tap(tester, AppStrings.returnHome);
      await open(tester, AppRoutes.result);
      expect(history.records, hasLength(1));
      expect(tester.takeException(), isNull);
    });
  }
}
