import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uts_pm2/app.dart';
import 'package:uts_pm2/core/constants/app_strings.dart';
import 'package:uts_pm2/providers/history_provider.dart';
import 'package:uts_pm2/providers/quiz_provider.dart';
import 'package:uts_pm2/providers/theme_provider.dart';
import 'package:uts_pm2/services/storage_service.dart';
import 'package:uts_pm2/widgets/home/resume_card.dart';
import 'package:uts_pm2/widgets/quiz/option_tile.dart';
import 'package:uts_pm2/widgets/common/key_button.dart';
import 'package:uts_pm2/screens/quiz_screen.dart';
import 'package:uts_pm2/screens/home_screen.dart';
import 'package:uts_pm2/core/theme/app_tokens.dart';

void main() {
  late StorageService storage;
  late HistoryProvider history;
  late ThemeProvider theme;
  late QuizProvider quiz;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = StorageService(await SharedPreferences.getInstance());
    history = HistoryProvider(storage);
    theme = ThemeProvider(storage);
    quiz = QuizProvider(
      storage: storage,
      onFinished: history.add,
      random: Random(3),
    );
    await Future.wait([history.load(), theme.load(), quiz.load()]);
  });
  tearDown(() {
    quiz.dispose();
    history.dispose();
    theme.dispose();
  });

  Future<void> pumpApp(
    WidgetTester tester, {
    Size size = const Size(412, 915),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
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

  Future<void> tapText(WidgetTester tester, String label) async {
    final finder = find.text(label).last;
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  Future<void> choose(WidgetTester tester, int index) async {
    final option = find.byType(OptionTile).at(index);
    await tester.ensureVisible(option);
    await tester.tap(option);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    if (!quiz.isCurrentResolved) await tapText(tester, AppStrings.submitAnswer);
  }

  testWidgets(
    'Quiz locks wrong answer, reveals key, advances and resumes after back',
    (tester) async {
      await tester.runAsync(() => quiz.startNew('Dina', '241401079'));
      await pumpApp(tester);
      await tapText(tester, AppStrings.resume);
      expect(find.byType(QuizScreen), findsOneWidget);
      final nextButton = find.widgetWithText(
        KeyButton,
        AppStrings.submitAnswer,
      );
      expect(tester.widget<KeyButton>(nextButton).onPressed, isNull);
      final key = quiz.currentQuestion!.displayedCorrectIndex;
      final wrong = (key + 1) % 4;
      await choose(tester, wrong);
      expect(find.text(AppStrings.why), findsOneWidget);
      expect(find.text(AppStrings.wrong), findsOneWidget);
      expect(
        tester.widget<OptionTile>(find.byType(OptionTile).at(wrong)).state,
        OptionState.wrong,
      );
      expect(
        tester.widget<OptionTile>(find.byType(OptionTile).at(key)).state,
        OptionState.revealed,
      );
      await choose(tester, key);
      expect(quiz.answers.first, wrong);
      await tapText(tester, AppStrings.next);
      expect(quiz.currentIndex, 1);
      expect(find.text(AppStrings.why), findsNothing);
      await choose(tester, quiz.currentQuestion!.displayedCorrectIndex);
      expect(find.text(AppStrings.correct), findsOneWidget);
      final before = quiz.session!.toJson();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.exitTitle), findsOneWidget);
      await tapText(tester, AppStrings.stay);
      expect(find.byType(QuizScreen), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tapText(tester, AppStrings.exit);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(quiz.session!.toJson(), before);
      await tapText(tester, AppStrings.resume);
      expect(quiz.session!.toJson(), before);
      expect(find.text(AppStrings.correct), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'finishing ten answers replaces Quiz and stores exactly one record',
    (tester) async {
      await tester.runAsync(() => quiz.startNew('Dina', '241401079'));
      await pumpApp(tester);
      await tapText(tester, AppStrings.resume);
      for (var i = 0; i < 10; i++) {
        await choose(tester, quiz.currentQuestion!.displayedCorrectIndex);
        await tapText(tester, i == 9 ? AppStrings.finish : AppStrings.next);
      }
      expect(quiz.status, QuizStatus.finished);
      expect(quiz.hasSavedSession, isFalse);
      expect(history.records.single.correct, 10);
      final saved = history.records.single;
      await tester.runAsync(() async {
        await Future.wait([quiz.finish(), quiz.finish()]);
        await history.load();
      });
      tester.view.physicalSize = const Size(640, 360);
      await tester.pumpAndSettle();
      expect(history.records, hasLength(1));
      expect(history.records.single.toJson(), saved.toJson());
      expect(tester.takeException(), isNull);
      expect(find.byType(QuizScreen), findsNothing);
      expect(find.text(AppStrings.resultEyebrow), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(QuizScreen), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'reduced motion skips option animation and still reveals feedback',
    (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.runAsync(() => quiz.startNew('Dina', '241401079'));
      await pumpApp(tester);
      await tapText(tester, AppStrings.resume);
      final optionContext = tester.element(find.byType(OptionTile).first);
      expect(AppMotion.of(optionContext).medium, Duration.zero);
      await choose(
        tester,
        (quiz.currentQuestion!.displayedCorrectIndex + 1) % 4,
      );
      expect(find.text(AppStrings.wrong), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Quiz progress survives orientation changes and semantics describe state',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.runAsync(() => quiz.startNew('Dina', '241401079'));
      await pumpApp(tester, size: const Size(360, 640));
      await tapText(tester, AppStrings.resume);
      await choose(tester, quiz.currentQuestion!.displayedCorrectIndex);
      expect(find.bySemanticsLabel(RegExp('Jawabanmu benar')), findsOneWidget);
      expect(
        find.bySemanticsLabel('Soal 1 dari 10, 1 benar, 0 salah'),
        findsOneWidget,
      );
      semantics.dispose();
      final snapshot = quiz.session!.toJson();
      tester.view.physicalSize = const Size(640, 360);
      await tester.pumpAndSettle();
      expect(quiz.session!.toJson(), snapshot);
      expect(tester.takeException(), isNull);
      tester.view.physicalSize = const Size(360, 640);
      await tester.pumpAndSettle();
      expect(quiz.session!.toJson(), snapshot);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Home validates trimmed names and starts exactly one session', (
    tester,
  ) async {
    await pumpApp(tester);
    await tapText(tester, AppStrings.start);
    expect(find.text(AppStrings.quizRules), findsOneWidget);
    await tapText(tester, AppStrings.start);
    expect(find.text(AppStrings.nameMin), findsOneWidget);
    // Input dibatasi sejak diketik: nama maksimal 20, NIM hanya 9 digit.
    await tester.enterText(find.byType(TextFormField).first, 'x' * 21);
    await tester.enterText(find.byType(TextFormField).last, 'a2414010791');
    await tester.pump();
    final fields = tester.widgetList<EditableText>(find.byType(EditableText));
    expect(fields.first.controller.text, 'x' * 20);
    expect(fields.last.controller.text, '241401079');
    expect(find.text(AppStrings.nameMax), findsNothing);
    expect(quiz.session, isNull);
    await tester.enterText(find.byType(TextFormField).first, '  Dina  ');
    await tester.enterText(find.byType(TextFormField).last, '241401079');
    await tapText(tester, AppStrings.start);
    expect(quiz.playerName, 'Dina');
    expect(quiz.session!.items.length, 10);
    expect(quiz.hasSavedSession, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home prefills name, confirms replacement and discard', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await quiz.startNew('Dina', '241401079');
      await quiz.selectAnswer(1);
      await quiz.next();
    });
    await pumpApp(tester);
    expect(find.byType(ResumeCard), findsOneWidget);
    expect(find.text('Dina (241401079), soal 2 dari 10'), findsOneWidget);
    await tapText(tester, AppStrings.start);
    expect(find.text(AppStrings.newTitle), findsOneWidget);
    await tapText(tester, AppStrings.cancel);
    expect(quiz.currentIndex, 1);
    expect(quiz.answers.first, 1);
    await tapText(tester, AppStrings.discard);
    expect(find.text(AppStrings.discardTitle), findsOneWidget);
    await tapText(tester, AppStrings.cancel);
    expect(quiz.hasSavedSession, isTrue);
    await tapText(tester, AppStrings.discard);
    await tapText(tester, AppStrings.discard);
    expect(quiz.hasSavedSession, isFalse);
    expect(find.byType(ResumeCard), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final size in [
    const Size(360, 640),
    const Size(412, 915),
    const Size(640, 360),
    const Size(1280, 800),
  ]) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets(
        'Quiz fits $size / $mode / large text before and after answering',
        (tester) async {
          await tester.runAsync(() async {
            await storage.setThemeMode(mode);
            await theme.load();
            await quiz.startNew('Dina', '241401079');
          });
          await pumpApp(tester, size: size, textScale: 2);
          await tapText(tester, AppStrings.resume);
          expect(tester.takeException(), isNull);
          final quizContext = tester.element(find.byType(QuizScreen));
          expect(MediaQuery.textScalerOf(quizContext).scale(20), 26);
          await choose(
            tester,
            (quiz.currentQuestion!.displayedCorrectIndex + 1) % 4,
          );
          await tester.ensureVisible(find.text(AppStrings.why));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tapText(tester, AppStrings.next);
          expect(quiz.currentIndex, 1);
          expect(tester.takeException(), isNull);
        },
      );
      testWidgets('Home fits $size / $mode / large text with saved session', (
        tester,
      ) async {
        await tester.runAsync(() async {
          await storage.setThemeMode(mode);
          await theme.load();
          await quiz.startNew('Nama dua puluh huruf', '241401079');
        });
        await pumpApp(tester, size: size, textScale: 2);
        expect(find.text(AppStrings.homeHeadline), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.byType(ResumeCard));
        expect(tester.takeException(), isNull);
      });
    }
  }
}
