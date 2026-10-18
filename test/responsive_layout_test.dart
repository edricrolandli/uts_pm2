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
import 'package:uts_pm2/widgets/quiz/question_card.dart';
import 'package:uts_pm2/widgets/quiz/option_tile.dart';

void main() {
  testWidgets(
    'keyboard and breakpoint changes preserve quiz with independent columns',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService(await SharedPreferences.getInstance());
      final history = HistoryProvider(storage);
      final quiz = QuizProvider(storage: storage, onFinished: history.add);
      final theme = ThemeProvider(storage);
      addTearDown(quiz.dispose);
      addTearDown(history.dispose);
      addTearDown(theme.dispose);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
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
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.enterText(find.byType(TextFormField), 'Dina');
      await tester.ensureVisible(find.text(AppStrings.start));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.start));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      final option = find.byType(OptionTile).first;
      await tester.ensureVisible(option);
      await tester.tap(option);
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      final snapshot = quiz.session!.toJson();
      for (final size in [
        const Size(599, 320),
        const Size(600, 320),
        const Size(1023, 768),
        const Size(1024, 768),
        const Size(1920, 1080),
        const Size(320, 568),
      ]) {
        tester.view.physicalSize = size;
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$size');
        expect(quiz.session!.toJson(), snapshot);
        if (size.width >= 600) {
          await tester.ensureVisible(option);
          await tester.pumpAndSettle();
          final questionRect = tester.getRect(find.byType(QuestionCard));
          final optionRect = tester.getRect(option);
          expect(questionRect.right, lessThanOrEqualTo(optionRect.left));
          final before = tester.getTopLeft(find.byType(QuestionCard));
          await tester.drag(option, const Offset(0, -250));
          await tester.pumpAndSettle();
          expect(tester.getTopLeft(find.byType(QuestionCard)), before);
          if (size.height == 320) {
            expect(tester.getTopLeft(option).dy, lessThan(optionRect.top));
          }
          if (size.width >= 1024) {
            expect(
              optionRect.right - questionRect.left,
              lessThanOrEqualTo(960),
            );
          }
        }
      }
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
