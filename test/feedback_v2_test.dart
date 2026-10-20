import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uts_pm2/core/constants/storage_keys.dart';
import 'package:uts_pm2/data/question_bank.dart';
import 'package:uts_pm2/providers/quiz_provider.dart';
import 'package:uts_pm2/providers/history_provider.dart';
import 'package:uts_pm2/services/storage_service.dart';
import 'package:uts_pm2/widgets/home/nim_input_field.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late StorageService storage;
  late HistoryProvider history;
  late QuizProvider quiz;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = StorageService(await SharedPreferences.getInstance());
    history = HistoryProvider(storage);
    quiz = QuizProvider(storage: storage, onFinished: history.add);
  });
  tearDown(() {
    quiz.dispose();
    history.dispose();
  });

  test('NIM is exactly nine ASCII digits, including leading zero', () async {
    for (final nim in [
      '',
      '12345678',
      '1234567890',
      '12345678a',
      ' 123456789',
    ]) {
      expect(NimInputField.validate(nim), isNotNull);
      await expectLater(quiz.startNew('Dina', nim), throwsArgumentError);
    }
    expect(NimInputField.validate('012345678'), isNull);
    await quiz.startNew('Dina', '012345678');
    expect(await storage.getLastNim(), '012345678');
  });

  test(
    'pending choice is replaceable, survives resume, never persisted',
    () async {
      await quiz.startNew('Dina', '241401079');
      quiz.chooseAnswer(0);
      quiz.chooseAnswer(2);
      await quiz.resume();
      expect(quiz.pendingAnswer, 2);
      expect(quiz.answers.first, isNull);
      expect((await storage.getSession(kQuestionBank))!.answers.first, isNull);
      await quiz.next();
      await quiz.finish();
      expect(quiz.currentIndex, 0);
      expect(quiz.result, isNull);
      await quiz.selectAnswer(2);
      quiz.chooseAnswer(1);
      expect(quiz.answers.first, 2);
      expect(quiz.pendingAnswer, isNull);
    },
  );

  testWidgets(
    'timeout submits pending choice and restored timeout cannot be answered',
    (tester) async {
      await tester.runAsync(() => quiz.startNew('Dina', '241401079'));
      final correct = quiz.currentQuestion!.displayedCorrectIndex;
      quiz.chooseAnswer(correct);
      quiz.resumeTimer();
      await tester.pump(const Duration(seconds: 30));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();
      expect(quiz.currentIndex, 0);
      expect(quiz.answers.first, correct);
      quiz.pauseTimer();
      await tester.runAsync(quiz.next);
      quiz.resumeTimer();
      await tester.pump(const Duration(seconds: 30));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();
      expect(quiz.currentIndex, 1);
      expect(quiz.answers[1], isNull);
      expect(quiz.session!.expired[1], isTrue);
      final restored = QuizProvider(storage: storage, onFinished: history.add);
      addTearDown(restored.dispose);
      await tester.runAsync(restored.load);
      await tester.runAsync(restored.resume);
      restored.chooseAnswer(0);
      await tester.runAsync(() => restored.selectAnswer(0));
      expect(restored.answers[1], isNull);
      expect(restored.isCurrentResolved, isTrue);
      await tester.runAsync(restored.next);
      expect(restored.currentIndex, 2);
    },
  );

  Future<void> finish(String nim) async {
    await quiz.startNew('Dina', nim);
    for (var i = 0; i < 10; i++) {
      await quiz.selectAnswer(quiz.currentQuestion!.displayedCorrectIndex);
      if (i < 9) await quiz.next();
    }
    await quiz.finish();
  }

  test('history caps each NIM separately, isolates clear, and drops one corrupt entry', () async {
    await finish('111111111');
    final first = quiz.result!;
    for (var i = 0; i < 22; i++) {
      await history.add(first);
    }
    await finish('222222222');
    expect(history.records, hasLength(1));
    expect(await storage.getHistory(), hasLength(21));
    final valid = quiz.result!.toJson();
    final corrupt = jsonDecode(jsonEncode(valid)) as Map<String, dynamic>;
    corrupt['session']['items'][0]['questionId'] = 'missing';
    final badOptions = jsonDecode(jsonEncode(valid)) as Map<String, dynamic>;
    badOptions['session']['items'][0]['question']['options'][0] = 123;
    await storage.preferences.setString(
      StorageKeys.history,
      jsonEncode([
        first.toJson(),
        corrupt,
        badOptions,
        valid,
        {'bad': true},
      ]),
    );
    await history.load();
    expect(history.nim, '222222222');
    expect(history.records, hasLength(1));
    expect(await storage.getHistory(), hasLength(2));
    await history.clear();
    expect(history.records, isEmpty);
    expect((await storage.getHistory()).single.nim, '111111111');
  });

  test('legacy history and sessions without NIM are discarded', () async {
    await quiz.startNew('Dina', '241401079');
    final legacy = quiz.session!.toJson()..remove('nim');
    await storage.preferences.setString(
      StorageKeys.session,
      jsonEncode(legacy),
    );
    await storage.preferences.setString('history_v1', '[]');
    expect(await storage.getSession(kQuestionBank), isNull);
    await storage.getHistory();
    expect(storage.preferences.containsKey('history_v1'), isFalse);
  });
}
