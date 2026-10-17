import 'dart:math';

import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../data/question_bank.dart';
import '../models/question.dart';
import '../models/quiz_session.dart';
import '../models/score_record.dart';
import '../models/session_question.dart';
import '../services/storage_service.dart';

enum QuizStatus { idle, inProgress, finished }

class QuizProvider extends ChangeNotifier {
  QuizProvider({
    required this.storage,
    required this.onFinished,
    Random? random,
    DateTime Function()? now,
    List<Question> questionBank = kQuestionBank,
  }) : _random = random ?? Random(),
       _now = now ?? DateTime.now,
       _bank = List.unmodifiable(questionBank);

  final StorageService storage;
  final Future<void> Function(ScoreRecord) onFinished;
  final Random _random;
  final DateTime Function() _now;
  final List<Question> _bank;
  Future<void> _pending = Future.value();
  QuizSession? _session;
  QuizSession? _savedSession;
  QuizStatus _status = QuizStatus.idle;
  String _lastName = '';
  ScoreRecord? _result;
  bool _historyRecorded = false;

  QuizSession? get session => _session;
  QuizStatus get status => _status;
  String get playerName => _session?.playerName ?? _lastName;
  int get currentIndex => _session?.currentIndex ?? 0;
  List<int?> get answers => _session?.answers ?? const [];
  bool get hasSavedSession => _savedSession != null;
  QuizSession? get savedSession => _savedSession;
  ScoreRecord? get result => _result;
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
    // Urutkan write agar aksi cepat tidak menimpa snapshot yang lebih baru.
    final result = _pending.then((_) => operation());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<void> load() => _enqueue(() async {
    _lastName = await storage.getLastName() ?? '';
    _savedSession = await storage.getSession(_bank);
    notifyListeners();
  });

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
    await storage.setLastName(trimmed);
    await _persist(next);
    _lastName = trimmed;
    _status = QuizStatus.inProgress;
    _result = null;
    _historyRecorded = false;
    notifyListeners();
  });

  Future<void> _persist(QuizSession next) async {
    // Publikasikan state setelah snapshot berhasil tersimpan untuk resume.
    await storage.setSession(next);
    _session = next;
    _savedSession = next;
  }

  Future<void> selectAnswer(int displayedIndex) => _enqueue(() async {
    if (_status != QuizStatus.inProgress ||
        _result != null ||
        isCurrentAnswered) {
      return;
    }
    if (displayedIndex < 0 || displayedIndex > 3) {
      throw RangeError.range(displayedIndex, 0, 3, 'displayedIndex');
    }
    final updated = List<int?>.of(answers)..[currentIndex] = displayedIndex;
    await _persist(_session!.copyWith(answers: updated));
    notifyListeners();
  });

  Future<void> next() => _enqueue(() async {
    if (_status != QuizStatus.inProgress || _result != null || isLastQuestion) {
      return;
    }
    await _persist(_session!.copyWith(currentIndex: currentIndex + 1));
    notifyListeners();
  });

  Future<void> resume() => _enqueue(() async {
    if (_status == QuizStatus.inProgress) return;
    final saved = await storage.getSession(_bank);
    _savedSession = saved;
    if (saved != null) {
      _session = saved;
      _status = QuizStatus.inProgress;
      _result = null;
      _historyRecorded = false;
    }
    notifyListeners();
  });

  Future<void> finish() => _enqueue(() async {
    if (_status != QuizStatus.inProgress) return;
    final record = _result ??= ScoreRecord(
      playerName: playerName,
      correct: correctCount,
      total: _session!.items.length,
      finishedAt: _now(),
    );
    // Flag milik sesi: rebuild Result dan retry clearSession tidak menyimpan ulang.
    if (!_historyRecorded) {
      await onFinished(record);
      _historyRecorded = true;
    }
    await storage.clearSession();
    _savedSession = null;
    _status = QuizStatus.finished;
    notifyListeners();
  });

  Future<void> discard() => _enqueue(() async {
    await storage.clearSession();
    _session = null;
    _savedSession = null;
    _result = null;
    _historyRecorded = false;
    _status = QuizStatus.idle;
    notifyListeners();
  });
}
