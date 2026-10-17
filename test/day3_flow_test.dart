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
import 'package:uts_pm2/widgets/home/name_input_field.dart';
import 'package:uts_pm2/widgets/home/resume_card.dart';

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

  testWidgets('Home validates trimmed names and starts exactly one session', (
    tester,
  ) async {
    await pumpApp(tester);
    await tapText(tester, AppStrings.start);
    expect(find.text(AppStrings.nameMin), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'x' * 21);
    await tapText(tester, AppStrings.start);
    expect(find.text(AppStrings.nameMax), findsOneWidget);
    expect(quiz.session, isNull);
    await tester.enterText(find.byType(TextFormField), '  Dina  ');
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
      await quiz.startNew('Dina');
      await quiz.selectAnswer(1);
      await quiz.next();
    });
    await pumpApp(tester);
    expect(
      tester
          .widget<NameInputField>(find.byType(NameInputField))
          .controller
          .text,
      'Dina',
    );
    expect(find.byType(ResumeCard), findsOneWidget);
    expect(find.text('Dina, soal 2 dari 10'), findsOneWidget);
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
      testWidgets('Home fits $size / $mode / large text with saved session', (
        tester,
      ) async {
        await tester.runAsync(() async {
          await storage.setThemeMode(mode);
          await theme.load();
          await quiz.startNew('Nama dua puluh huruf');
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
