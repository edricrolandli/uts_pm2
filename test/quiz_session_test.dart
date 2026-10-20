import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:uts_pm2/core/constants/app_constants.dart';
import 'package:uts_pm2/data/question_bank.dart';
import 'package:uts_pm2/models/quiz_session.dart';
import 'package:uts_pm2/models/score_record.dart';
import 'package:uts_pm2/models/session_question.dart';

void main() {
  QuizSession sample() => QuizSession(
    nim: '241401079',
    playerName: 'Dina',
    items: kQuestionBank.reversed
        .take(10)
        .map((q) => SessionQuestion.shuffled(q, Random(42)))
        .toList(),
    answers: [0, 2, 1, null, null, null, null, null, null, null],
    currentIndex: 3,
    startedAt: DateTime.utc(2026, 10, 16),
  );

  test('bank memiliki 20 ID stabil, empat opsi unik, dan kunci valid', () {
    expect(
      kQuestionBank.map((q) => q.id).toList(),
      List.generate(20, (i) => 'q${(i + 1).toString().padLeft(2, '0')}'),
    );
    for (final q in kQuestionBank) {
      expect(q.options.length, 4, reason: q.id);
      expect(q.options.toSet().length, 4, reason: q.id);
      expect(q.correctIndex, inInclusiveRange(0, 3), reason: q.id);
      expect(q.text, isNotEmpty);
      expect(q.explanation, isNotEmpty);
    }
    expect(kQuestionBank.where((q) => q.codeSnippet != null).length, 11);
  });

  test('round-trip mempertahankan urutan soal, opsi, jawaban, dan posisi', () {
    final original = sample();
    final restored = QuizSession.fromJson(
      jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>,
      kQuestionBank,
    );
    expect(restored.toJson(), original.toJson());
    expect(restored.items.first.question.text, kQuestionBank.last.text);
    expect(
      restored.items.first.toJson().keys,
      unorderedEquals(['questionId', 'optionOrder', 'question']),
    );
  });

  test('shuffle selalu permutasi dan kunci tampil menunjuk jawaban benar', () {
    for (var seed = 0; seed < 100; seed++) {
      for (final question in kQuestionBank) {
        final item = SessionQuestion.shuffled(question, Random(seed));
        expect(item.optionOrder, unorderedEquals([0, 1, 2, 3]));
        expect(
          item.displayedOptions[item.displayedCorrectIndex],
          question.options[question.correctIndex],
        );
        expect(
          item.optionOrder,
          SessionQuestion.shuffled(question, Random(seed)).optionOrder,
        );
      }
    }
  });

  test('ID soal hilang ditolak', () {
    expect(
      () => QuizSession.fromJson(sample().toJson(), []),
      throwsFormatException,
    );
  });

  test('permutasi rusak ditolak', () {
    for (final order in [
      [0, 0, 2, 3],
      [0, 1, 2],
      [-1, 1, 2, 3],
      [0, 1, 2, 4],
    ]) {
      expect(
        () =>
            SessionQuestion(question: kQuestionBank.first, optionOrder: order),
        throwsFormatException,
      );
    }
  });

  test('snapshot tidak dapat diubah melalui referensi list', () {
    final session = sample();
    expect(() => session.answers[0] = 3, throwsUnsupportedError);
    expect(() => session.items.clear(), throwsUnsupportedError);
    expect(
      () => session.items.first.optionOrder[0] = 2,
      throwsUnsupportedError,
    );
  });

  for (final entry in <String, Object>{
    'currentIndex': 10,
    'answers': [4, null, null, null, null, null, null, null, null, null],
    'playerName': 'A',
  }.entries) {
    test('sesi menolak ${entry.key} tidak valid', () {
      final json = sample().toJson()..[entry.key] = entry.value;
      expect(
        () => QuizSession.fromJson(json, kQuestionBank),
        throwsFormatException,
      );
    });
  }

  test('ScoreRecord JSON dan batas grade', () {
    final score = ScoreRecord(
      session: sample().copyWith(
        answers: List.generate(
          10,
          (i) => i < 7 ? sample().items[i].displayedCorrectIndex : null,
        ),
        expired: List.generate(10, (i) => i >= 7),
      ),
      finishedAt: DateTime.utc(2026, 10, 16),
    );
    expect(ScoreRecord.fromJson(score.toJson()).toJson(), score.toJson());
    expect(score.percent, 70);
    expect(gradeLabel(90), 'Database Wizard');
    expect(gradeLabel(89), 'Query Pro');
    expect(gradeLabel(70), 'Query Pro');
    expect(gradeLabel(69), 'Lumayan, lanjut belajar');
    expect(gradeLabel(50), 'Lumayan, lanjut belajar');
    expect(gradeLabel(49), 'Perlu latihan JOIN lagi');
  });
}
