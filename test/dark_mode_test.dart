import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uts_pm2/app.dart';
import 'package:uts_pm2/core/constants/app_strings.dart';
import 'package:uts_pm2/core/constants/storage_keys.dart';
import 'package:uts_pm2/core/theme/app_tokens.dart';
import 'package:uts_pm2/providers/history_provider.dart';
import 'package:uts_pm2/providers/quiz_provider.dart';
import 'package:uts_pm2/providers/theme_provider.dart';
import 'package:uts_pm2/services/storage_service.dart';
import 'package:uts_pm2/widgets/common/theme_toggle_button.dart';

class FailingThemeStorage extends StorageService {
  FailingThemeStorage(super.preferences);
  bool fail = true;

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    if (fail) throw StateError('Storage unavailable');
    await super.setThemeMode(mode);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late StorageService storage;
  late ThemeProvider theme;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = StorageService(await SharedPreferences.getInstance());
    theme = ThemeProvider(storage);
    await theme.load();
  });
  tearDown(() => theme.dispose());

  test(
    'rapid toggles persist in order and survive provider recreation',
    () async {
      await storage.setThemeMode(ThemeMode.light);
      await theme.load();
      await Future.wait([theme.toggle(), theme.toggle(), theme.toggle()]);
      expect(theme.mode, ThemeMode.dark);
      expect(storage.preferences.getString(StorageKeys.themeMode), 'dark');
      final restored = ThemeProvider(storage);
      addTearDown(restored.dispose);
      await restored.load();
      expect(restored.mode, ThemeMode.dark);
    },
  );

  test('failed write preserves mode and the next toggle can recover', () async {
    final failing = FailingThemeStorage(storage.preferences);
    await storage.setThemeMode(ThemeMode.light);
    final provider = ThemeProvider(failing);
    addTearDown(provider.dispose);
    await provider.load();
    await expectLater(provider.toggle(), throwsStateError);
    expect(provider.mode, ThemeMode.light);
    expect(await storage.getThemeMode(), ThemeMode.light);
    failing.fail = false;
    await provider.toggle();
    expect(provider.mode, ThemeMode.dark);
    expect(await storage.getThemeMode(), ThemeMode.dark);
  });

  test('invalid stored mode falls back to system', () async {
    await storage.preferences.setString(StorageKeys.themeMode, 'invalid');
    await theme.load();
    expect(theme.mode, ThemeMode.system);
    expect(storage.preferences.containsKey(StorageKeys.themeMode), isFalse);
  });

  testWidgets('Home toggle follows system and updates before transition ends', (
    tester,
  ) async {
    final history = HistoryProvider(storage);
    final quiz = QuizProvider(storage: storage, onFinished: history.add);
    addTearDown(history.dispose);
    addTearDown(quiz.dispose);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: theme),
          ChangeNotifierProvider.value(value: history),
          ChangeNotifierProvider.value(value: quiz),
        ],
        child: const QueryQuestApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip(AppStrings.lightMode), findsOneWidget);
    await tester.tap(find.byType(ThemeToggleButton));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    expect(theme.mode, ThemeMode.light);
    expect(find.byTooltip(AppStrings.darkMode), findsOneWidget);
    expect(await storage.getThemeMode(), ThemeMode.light);
    final rotation = tester.widget<AnimatedRotation>(
      find.descendant(
        of: find.byType(ThemeToggleButton),
        matching: find.byType(AnimatedRotation),
      ),
    );
    expect(rotation.turns, 0);
    expect(rotation.duration, AppTokens.durMedium);
    await tester.pumpAndSettle();

    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    await tester.pump();
    expect(
      tester
          .widget<MaterialApp>(find.byType(MaterialApp))
          .themeAnimationDuration,
      Duration.zero,
    );
    await tester.tap(find.byType(ThemeToggleButton));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    expect(theme.mode, ThemeMode.dark);
    final context = tester.element(find.byType(ThemeToggleButton));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(AppMotion.of(context).medium, Duration.zero);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
