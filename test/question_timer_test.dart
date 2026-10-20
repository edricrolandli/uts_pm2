import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uts_pm2/core/constants/app_strings.dart';
import 'package:uts_pm2/core/theme/app_theme.dart';
import 'package:uts_pm2/data/question_bank.dart';
import 'package:uts_pm2/models/quiz_session.dart';
import 'package:uts_pm2/models/question.dart';
import 'package:uts_pm2/models/score_record.dart';
import 'package:uts_pm2/providers/quiz_provider.dart';
import 'package:uts_pm2/services/storage_service.dart';
import 'package:uts_pm2/widgets/quiz/timer_chip.dart';
import 'package:uts_pm2/screens/quiz_screen.dart';
import 'package:uts_pm2/core/routes/app_routes.dart';

class TimerStorage extends StorageService {
  TimerStorage(super.preferences);
  bool fail = false;
  bool failClear = false;
  Completer<void>? gate;
  Map<String, dynamic>? snapshot;
  @override
  Future<void> setLastName(String name) async {}
  @override
  Future<void> clearSession() async {
    if (failClear) throw StateError('Clear failed');
    snapshot = null;
  }

  @override
  Future<QuizSession?> getSession(Iterable<Question> bank) async =>
      snapshot == null ? null : QuizSession.fromJson(snapshot!, bank);
  @override
  Future<void> setSession(QuizSession session) async {
    if (fail) throw StateError('Save failed');
    if (gate != null) await gate!.future;
    snapshot = session.toJson();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TimerStorage storage;

  late List<ScoreRecord> records;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = TimerStorage(await SharedPreferences.getInstance());
    records = [];
  });
  QuizProvider createQuiz() {
    final provider = QuizProvider(
      storage: storage,
      onFinished: (record) async => records.add(record),
    );
    addTearDown(provider.dispose);
    return provider;
  }

  testWidgets('timeout persists unanswered lock until explicit next', (
    tester,
  ) async {
    final quiz = createQuiz();
    await quiz.startNew('Dina', '241401079');
    quiz.resumeTimer();
    await tester.pump(const Duration(seconds: 29));
    expect(quiz.remainingSeconds, 1);
    await tester.pump(const Duration(seconds: 1));
    expect(quiz.currentIndex, 0);
    expect(quiz.session!.expired.first, isTrue);
    expect(quiz.answers.first, isNull);
    await quiz.next();
    expect(quiz.remainingSeconds, 30);
    expect((await storage.getSession(kQuestionBank))!.currentIndex, 1);
    await quiz.selectAnswer(quiz.currentQuestion!.displayedCorrectIndex);
    await tester.pump(const Duration(seconds: 35));
    expect(quiz.currentIndex, 1);
    expect(quiz.correctCount, 1);
    await quiz.next();
    await tester.pump(const Duration(seconds: 1));
    expect(quiz.remainingSeconds, 29);
    quiz.pauseTimer();
  });

  testWidgets(
    'pause and resume preserve remaining time from Home; discard cancels timer',
    (tester) async {
      final quiz = createQuiz();
      await quiz.startNew('Dina', '241401079');
      quiz.resumeTimer();
      await tester.pump(const Duration(seconds: 10));
      quiz.pauseTimer();
      await tester.pump(const Duration(seconds: 60));
      expect(quiz.remainingSeconds, 20);
      await quiz.resume();
      expect(quiz.remainingSeconds, 20);
      quiz.resumeTimer();
      await quiz.discard();
      await tester.pump(const Duration(seconds: 60));
      expect(quiz.session, isNull);
      expect(records, isEmpty);
    },
  );

  testWidgets('last timeout waits for explicit finish and records once', (
    tester,
  ) async {
    final quiz = createQuiz();
    await quiz.startNew('Dina', '241401079');
    for (var i = 0; i < 9; i++) {
      await quiz.selectAnswer(quiz.currentQuestion!.displayedCorrectIndex);
      await quiz.next();
    }
    quiz.resumeTimer();
    await tester.pump(const Duration(seconds: 30));
    expect(quiz.status, QuizStatus.inProgress);
    expect(records, isEmpty);
    await quiz.finish();
    expect(quiz.status, QuizStatus.finished);
    expect(records.single.correct, 9);
    expect(await storage.getSession(kQuestionBank), isNull);
    await tester.pump(const Duration(seconds: 60));
    await quiz.finish();
    expect(records, hasLength(1));
  });

  testWidgets('failed timeout stays locked and retry cannot skip twice', (
    tester,
  ) async {
    final quiz = createQuiz();
    await quiz.startNew('Dina', '241401079');
    storage.fail = true;
    quiz.resumeTimer();
    await tester.pump(const Duration(seconds: 30));
    expect(quiz.timerFailed, isTrue);
    expect(quiz.currentIndex, 0);
    await quiz.selectAnswer(0);
    expect(quiz.answers.first, isNull);
    storage.fail = false;
    await Future.wait([quiz.retryTimeout(), quiz.retryTimeout()]);
    expect(quiz.currentIndex, 0);
    expect(quiz.isCurrentResolved, isTrue);
    expect(quiz.timerFailed, isFalse);
    quiz.pauseTimer();
  });

  testWidgets('dispose cancels countdown and never emits again', (
    tester,
  ) async {
    final provider = QuizProvider(storage: storage, onFinished: (_) async {});
    await provider.startNew('Dina', '241401079');
    var notifications = 0;
    provider.addListener(() => notifications++);
    provider.resumeTimer();
    await tester.pump(const Duration(seconds: 1));
    expect(notifications, 1);
    provider.dispose();
    await tester.pump(const Duration(seconds: 60));
    expect(notifications, 1);
  });

  testWidgets(
    'late answer cannot attach to next question during timeout save',
    (tester) async {
      final quiz = createQuiz();
      await quiz.startNew('Dina', '241401079');
      storage.gate = Completer<void>();
      quiz.resumeTimer();
      await tester.pump(const Duration(seconds: 30));
      final lateAnswer = quiz.selectAnswer(0);
      storage.gate!.complete();
      await tester.pump();
      await lateAnswer;
      expect(quiz.currentIndex, 0);
      expect(quiz.answers.take(2), [null, null]);
      quiz.pauseTimer();
    },
  );

  testWidgets(
    'retry last timeout after failed clear does not duplicate history',
    (tester) async {
      final quiz = createQuiz();
      await quiz.startNew('Dina', '241401079');
      for (var i = 0; i < 9; i++) {
        await quiz.selectAnswer(0);
        await quiz.next();
      }
      storage.failClear = true;
      quiz.resumeTimer();
      await tester.pump(const Duration(seconds: 30));
      expect(quiz.isCurrentResolved, isTrue);
      await expectLater(quiz.finish(), throwsStateError);
      expect(records, hasLength(1));
      storage.failClear = false;
      await quiz.finish();
      expect(quiz.status, QuizStatus.finished);
      expect(records, hasLength(1));
    },
  );

  testWidgets('last timeout shows feedback then finish opens Result route', (
    tester,
  ) async {
    final quiz = createQuiz();
    await quiz.startNew('Dina', '241401079');
    for (var i = 0; i < 9; i++) {
      await quiz.selectAnswer(0);
      await quiz.next();
    }
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: quiz,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const QuizScreen(),
          routes: {
            AppRoutes.result: (_) => const Scaffold(body: Text('Result test')),
          },
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 30));
    await tester.pumpAndSettle();
    expect(find.byType(QuizScreen), findsOneWidget);
    expect(find.text(AppStrings.wrong), findsOneWidget);
    expect(records, isEmpty);
    await tester.tap(find.text(AppStrings.finish));
    await tester.pumpAndSettle();
    expect(find.text('Result test'), findsOneWidget);
    expect(find.byType(QuizScreen), findsNothing);
    expect(records, hasLength(1));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('timer semantics change only at warning and expiry thresholds', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    Future<void> pump(int seconds) => tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(body: TimerChip(seconds: seconds, answered: false)),
      ),
    );
    await pump(5);
    expect(find.bySemanticsLabel(AppStrings.timerWarning), findsOneWidget);
    await pump(4);
    expect(find.bySemanticsLabel(AppStrings.timerWarning), findsOneWidget);
    expect(find.text('00:04'), findsOneWidget);
    await pump(0);
    expect(find.bySemanticsLabel(AppStrings.timerExpired), findsOneWidget);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: TimerChip(seconds: 0, answered: true, expired: true),
        ),
      ),
    );
    expect(find.text(AppStrings.timerOut), findsOneWidget);
    expect(find.bySemanticsLabel(AppStrings.timerExpired), findsOneWidget);
    expect(find.bySemanticsLabel(AppStrings.locked), findsNothing);
    handle.dispose();
  });

  testWidgets('finishing during exit dialog still navigates after dismissal', (
    tester,
  ) async {
    final saving = Completer<void>();
    final quiz = QuizProvider(
      storage: storage,
      onFinished: (_) => saving.future,
    );
    addTearDown(quiz.dispose);
    await quiz.startNew('Dina', '241401079');
    for (var i = 0; i < 9; i++) {
      await quiz.selectAnswer(0);
      await quiz.next();
    }
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: quiz,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const QuizScreen(),
          routes: {
            AppRoutes.result: (_) => const Scaffold(body: Text('Result test')),
          },
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 30));
    final finishing = quiz.finish();
    await tester.pump();
    await tester.tap(find.byTooltip(AppStrings.exit));
    await tester.pumpAndSettle();
    saving.complete();
    await finishing;
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.exitTitle), findsOneWidget);
    await tester.tap(find.text(AppStrings.stay));
    await tester.pumpAndSettle();
    expect(find.text('Result test'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
