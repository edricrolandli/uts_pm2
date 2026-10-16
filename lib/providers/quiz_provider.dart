import 'dart:math';

import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../data/question_bank.dart';
import '../models/question.dart';
import '../models/quiz_session.dart';
import '../models/session_question.dart';

enum QuizStatus { idle, inProgress, finished }

class QuizProvider extends ChangeNotifier {
  QuizProvider({
    Random? random,
    DateTime Function()? now,
    List<Question> questionBank = kQuestionBank,
  }) : _random = random ?? Random(),
       _now = now ?? DateTime.now,
       _bank = List.unmodifiable(questionBank);

  final Random _random;
  final DateTime Function() _now;
  final List<Question> _bank;
  Future<void> _pending = Future.value();
  QuizSession? _session;
  QuizStatus _status = QuizStatus.idle;

  QuizSession? get session => _session;
  QuizStatus get status => _status;
  String get playerName => _session?.playerName ?? '';
  int get currentIndex => _session?.currentIndex ?? 0;
  List<int?> get answers => _session?.answers ?? const [];
  SessionQuestion? get currentQuestion => _session?.items[currentIndex];
  bool get isCurrentAnswered =>
      _session != null && answers[currentIndex] != null;
  bool get isLastQuestion =>
      _session != null && currentIndex == _session!.items.length - 1;
  int get correctCount {
    final active = _session;
    if (active == null) return 0;
    var correct = 0;
    for (var i = 0; i < active.items.length; i++) {
      if (active.answers[i] == active.items[i].displayedCorrectIndex) correct++;
    }
    return correct;
  }

  int get score => correctCount;
  double get percent =>
      _session == null ? 0 : correctCount / _session!.items.length * 100;
  double get progress => _session == null
      ? 0
      : answers.where((answer) => answer != null).length / answers.length;

  Future<void> _enqueue(Future<void> Function() operation) {
    // Urutkan perubahan state ketika aksi datang berdekatan.
    final result = _pending.then((_) => operation());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<void> startNew(String name) => _enqueue(() async {
    final trimmed = name.trim();
    if (trimmed.runes.length < kMinPlayerNameLength ||
        trimmed.runes.length > kMaxPlayerNameLength) {
      throw ArgumentError.value(name, 'name', 'Nama harus 2–20 karakter.');
    }
    if (_bank.length < kQuestionsPerSession ||
        _bank.map((question) => question.id).toSet().length != _bank.length) {
      throw StateError('Bank soal harus cukup dan ID harus unik.');
    }
    // Acak salinan bank, ambil 10 tanpa pengulangan, lalu acak opsi tiap soal.
    final candidates = List<Question>.of(_bank)..shuffle(_random);
    final items = candidates
        .take(kQuestionsPerSession)
        .map((question) => SessionQuestion.shuffled(question, _random))
        .toList();
    final next = QuizSession(
      playerName: trimmed,
      items: items,
      answers: List.filled(items.length, null),
      currentIndex: 0,
      startedAt: _now(),
    );

    _session = next;

    _status = QuizStatus.inProgress;

    notifyListeners();
  });

  Future<void> selectAnswer(int displayedIndex) => _enqueue(() async {
    if (_status != QuizStatus.inProgress || isCurrentAnswered) {
      return;
    }
    if (displayedIndex < 0 || displayedIndex > 3) {
      throw RangeError.range(displayedIndex, 0, 3, 'displayedIndex');
    }
    final updated = List<int?>.of(answers)..[currentIndex] = displayedIndex;
    _session = _session!.copyWith(answers: updated);
    notifyListeners();
  });

  Future<void> next() => _enqueue(() async {
    if (_status != QuizStatus.inProgress || isLastQuestion) {
      return;
    }
    _session = _session!.copyWith(currentIndex: currentIndex + 1);
    notifyListeners();
  });

  // Persistensi, resume, dan penyelesaian ditambahkan pada commit berikutnya.
  Future<void> finish() async {}

  Future<void> discard() async {}
}
