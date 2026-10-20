import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uts_pm2/app.dart';
import 'package:uts_pm2/core/constants/storage_keys.dart';
import 'package:uts_pm2/core/constants/app_strings.dart';
import 'package:uts_pm2/screens/home_screen.dart';
import 'package:uts_pm2/data/question_bank.dart';
import 'package:uts_pm2/models/score_record.dart';
import 'package:uts_pm2/providers/history_provider.dart';
import 'package:uts_pm2/providers/quiz_provider.dart';
import 'package:uts_pm2/providers/theme_provider.dart';
import 'package:uts_pm2/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences prefs;
  late StorageService storage;
  late HistoryProvider history;
  late QuizProvider quiz;
  final time = DateTime.utc(2026, 10, 16, 12);

  QuizProvider createQuiz() => QuizProvider(
    storage: storage,
    onFinished: history.add,
    random: Random(42),
    now: () => time,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    storage = StorageService(prefs);
    history = HistoryProvider(storage);
    quiz = createQuiz();
    await Future.wait([history.load(), quiz.load()]);
  });
  tearDown(() {
    quiz.dispose();
    history.dispose();
  });

  test('startNew memilih 10 soal unik dan menyimpan nama/sesi', () async {
    expect(quiz.status, QuizStatus.idle);
    expect(quiz.progress, 0);
    await quiz.startNew('  Dina  ', '241401079');
    expect(quiz.playerName, 'Dina');
    expect(quiz.session!.items.length, 10);
    expect(quiz.session!.items.map((q) => q.question.id).toSet().length, 10);
    expect(quiz.answers, List<int?>.filled(10, null));
    expect(quiz.hasSavedSession, isTrue);
    expect(await storage.getLastName(), 'Dina');
    expect(
      (await storage.getSession(kQuestionBank))!.toJson(),
      quiz.session!.toJson(),
    );
  });

  test('nama tidak valid ditolak tanpa membuat sesi', () async {
    for (final name in ['', 'A', 'x' * 21]) {
      await expectLater(quiz.startNew(name, '241401079'), throwsArgumentError);
    }
    expect(quiz.session, isNull);
    expect(prefs.containsKey(StorageKeys.session), isFalse);
    await quiz.startNew(
      'Dina',
      '241401079',
    ); // Kegagalan tidak memblokir antrean.
    expect(quiz.status, QuizStatus.inProgress);
  });

  test(
    'jawaban terkunci termasuk ketika dua pilihan datang bersamaan',
    () async {
      await quiz.startNew('Dina', '241401079');
      final correct = quiz.currentQuestion!.displayedCorrectIndex;
      await Future.wait([
        quiz.selectAnswer(correct),
        quiz.selectAnswer((correct + 1) % 4),
      ]);
      expect(quiz.answers[0], correct);
      expect(quiz.correctCount, 1);
      expect(quiz.score, 1);
      expect(quiz.percent, 10);
      expect(quiz.progress, .1);
      expect(quiz.isCurrentAnswered, isTrue);
      await quiz.next();
      expect(quiz.currentIndex, 1);
      expect(quiz.isCurrentAnswered, isFalse);
      expect((await storage.getSession(kQuestionBank))!.currentIndex, 1);
    },
  );

  test(
    'skor menggunakan indeks tampil dan soal kosong dihitung salah',
    () async {
      await quiz.startNew('Dina', '241401079');
      for (var i = 0; i < 10; i++) {
        final correct = quiz.currentQuestion!.displayedCorrectIndex;
        if (i < 7) await quiz.selectAnswer(correct);
        if (i >= 7) await quiz.selectAnswer((correct + 1) % 4);
        await quiz.next();
      }
      expect(quiz.correctCount, 7);
      expect(quiz.percent, 70);
      expect(quiz.progress, 1);
      expect(quiz.currentIndex, 9);
      expect(quiz.isLastQuestion, isTrue);
      await quiz.finish();
      expect(quiz.result!.correct, 7);
      expect(quiz.result!.total, 10);
      expect(quiz.result!.percent, 70);
    },
  );

  test(
    'finish menambah satu riwayat, menghapus sesi, dan bersifat idempoten',
    () async {
      await quiz.startNew('Dina', '241401079');
      await quiz.selectAnswer(quiz.currentQuestion!.displayedCorrectIndex);
      for (var i = 1; i < 10; i++) {
        await quiz.next();
        await quiz.selectAnswer(
          (quiz.currentQuestion!.displayedCorrectIndex + 1) % 4,
        );
      }
      await Future.wait([quiz.finish(), quiz.finish()]);
      expect(quiz.status, QuizStatus.finished);
      expect(quiz.hasSavedSession, isFalse);
      expect(prefs.containsKey(StorageKeys.session), isFalse);
      expect(history.records.length, 1);
      expect((await storage.getHistory()).single.correct, 1);
      expect(history.records.single.finishedAt, time);
      await quiz.next();
      await quiz.selectAnswer(0);
      expect(quiz.currentIndex, 9);
      expect(history.records.length, 1);
    },
  );

  test(
    'resume memulihkan snapshot persis dan mempertahankan kunci jawaban',
    () async {
      await quiz.startNew('Dina', '241401079');
      await quiz.selectAnswer(2);
      await quiz.next();
      await quiz.selectAnswer(1);
      final before = quiz.session!.toJson();
      final restored = createQuiz();
      addTearDown(restored.dispose);
      await restored.load();
      expect(restored.hasSavedSession, isTrue);
      expect(restored.status, QuizStatus.idle);
      await restored.resume();
      expect(restored.session!.toJson(), before);
      await restored.selectAnswer(3);
      expect(restored.answers[1], 1);
      expect(restored.currentIndex, 1);
    },
  );

  test('discard menghapus sesi; startNew mereset jawaban', () async {
    await quiz.startNew('Dina', '241401079');
    await quiz.selectAnswer(0);
    await quiz.next();
    await quiz.startNew('Eko', '241401079');
    expect(quiz.currentIndex, 0);
    expect(quiz.answers.every((answer) => answer == null), isTrue);
    await quiz.discard();
    expect(quiz.session, isNull);
    expect(quiz.status, QuizStatus.idle);
    expect(quiz.hasSavedSession, isFalse);
    expect(await storage.getSession(kQuestionBank), isNull);
    expect(history.records, isEmpty);
  });

  test('indeks jawaban di luar rentang ditolak', () async {
    await quiz.startNew('Dina', '241401079');
    await expectLater(quiz.selectAnswer(4), throwsRangeError);
    await expectLater(quiz.selectAnswer(-1), throwsRangeError);
    expect(quiz.isCurrentAnswered, isFalse);
  });

  test('JSON rusak dan tipe salah dibuang tanpa crash', () async {
    await prefs.setString(StorageKeys.session, '{broken');
    await prefs.setString(StorageKeys.history, '{broken');
    await prefs.setString(StorageKeys.themeMode, 'unknown');
    expect(await storage.getSession(kQuestionBank), isNull);
    expect(await storage.getHistory(), isEmpty);
    expect(await storage.getThemeMode(), ThemeMode.system);
    for (final key in [StorageKeys.session, StorageKeys.themeMode]) {
      expect(prefs.containsKey(key), isFalse);
    }
    await prefs.setInt(StorageKeys.session, 123);
    expect(await storage.getSession(kQuestionBank), isNull);
    expect(prefs.containsKey(StorageKeys.session), isFalse);
  });

  test('sesi dengan ID soal hilang dibuang', () async {
    await quiz.startNew('Dina', '241401079');
    final data = quiz.session!.toJson();
    (data['items'] as List).first['questionId'] = 'missing';
    await prefs.setString(StorageKeys.session, jsonEncode(data));
    final restored = createQuiz();
    addTearDown(restored.dispose);
    await restored.load();
    await restored.resume();
    expect(restored.status, QuizStatus.idle);
    expect(restored.hasSavedSession, isFalse);
    expect(prefs.containsKey(StorageKeys.session), isFalse);
  });

  test(
    'riwayat terbaru di depan, batas 20, dapat dimuat dan dihapus',
    () async {
      for (var i = 0; i < 22; i++) {
        await quiz.startNew('Pemain $i', '241401079');
        await history.add(
          ScoreRecord(
            session: quiz.session!.copyWith(expired: List.filled(10, true)),
            finishedAt: time.add(Duration(minutes: i)),
          ),
        );
      }
      expect(history.records.length, 20);
      expect(history.records.first.playerName, 'Pemain 21');
      expect(history.records.last.playerName, 'Pemain 2');
      final restored = HistoryProvider(storage);
      addTearDown(restored.dispose);
      await restored.load();
      expect(
        restored.records.map((r) => r.toJson()).toList(),
        history.records.map((r) => r.toJson()).toList(),
      );
      await restored.clear();
      expect(restored.records, isEmpty);
      expect(await storage.getHistory(), isEmpty);
    },
  );

  testWidgets('theme toggle persists and Home uses both palettes', (
    tester,
  ) async {
    final theme = ThemeProvider(storage);
    addTearDown(theme.dispose);
    await theme.load();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: theme),
          ChangeNotifierProvider.value(value: quiz),
          ChangeNotifierProvider.value(value: history),
        ],
        child: const QueryQuestApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.homeHeadline), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(HomeScreen))).brightness,
      Brightness.light,
    );
    await theme.toggle();
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(HomeScreen))).brightness,
      Brightness.dark,
    );
    expect(await storage.getThemeMode(), ThemeMode.dark);
    final restored = ThemeProvider(storage);
    addTearDown(restored.dispose);
    await restored.load();
    expect(restored.mode, ThemeMode.dark);
    await theme.toggle();
    await tester.pumpAndSettle();
    expect(theme.mode, ThemeMode.light);
    expect(tester.takeException(), isNull);
  });
}
