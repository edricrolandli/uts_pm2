import 'dart:async';
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
  String _lastNim = '';
  int? _pendingAnswer;
  int? get pendingAnswer => _pendingAnswer;
  String get lastName => _lastName;
  String get lastNim => _lastNim;
  bool get isCurrentResolved =>
      isCurrentAnswered || (_session?.expired[currentIndex] ?? false);
  void chooseAnswer(int index) {
    if (index < 0 || index > 3) throw RangeError.range(index, 0, 3);
    if (_status != QuizStatus.inProgress ||
        isCurrentResolved ||
        _remainingSeconds == 0) {
      return;
    }
    _pendingAnswer = index;
    _notify();
  }

  ScoreRecord? _result;
  bool _historyRecorded = false;
  Timer? _timer;
  int _timerGeneration = 0;
  int _remainingSeconds = kQuestionSeconds;
  bool _timerActive = false;
  bool _timerFailed = false;
  bool _disposed = false;

  int get remainingSeconds => _remainingSeconds;
  bool get timerFailed => _timerFailed;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
    _timerGeneration++;
  }

  void pauseTimer() {
    _timerActive = false;
    _cancelTimer();
  }

  void resumeTimer() {
    if (_disposed) return;
    _timerActive = true;
    if (_remainingSeconds == 0) {
      unawaited(_expire(_timerGeneration));
      return;
    }
    _scheduleTimer();
  }

  void _resetTimer() {
    _cancelTimer();
    _remainingSeconds = (_session?.expired[currentIndex] ?? false)
        ? 0
        : kQuestionSeconds;
    _timerFailed = false;
    _scheduleTimer();
  }

  void _scheduleTimer() {
    if (_disposed ||
        !_timerActive ||
        _timer != null ||
        _status != QuizStatus.inProgress ||
        isCurrentResolved ||
        _result != null ||
        _remainingSeconds == 0) {
      return;
    }
    final generation = _timerGeneration;
    _timer = Timer.periodic(kTimerTick, (_) {
      _remainingSeconds--;
      if (_remainingSeconds == 0) {
        _timer?.cancel();
        _timer = null;
        unawaited(_expire(generation));
      }
      _notify();
    });
  }

  Future<void> retryTimeout() => _expire(_timerGeneration);

  Future<void> _expire(int generation) => _enqueue(() async {
    if (_disposed ||
        !_timerActive ||
        generation != _timerGeneration ||
        _status != QuizStatus.inProgress ||
        isCurrentResolved ||
        _remainingSeconds != 0) {
      return;
    }
    _cancelTimer();
    try {
      final updated = List<int?>.of(answers);
      final expired = List<bool>.of(_session!.expired)..[currentIndex] = true;
      updated[currentIndex] = _pendingAnswer;
      await _persist(_session!.copyWith(answers: updated, expired: expired));
      _pendingAnswer = null;
      _timerFailed = false;
    } catch (_) {
      _timerFailed = true;
    }
    _notify();
  });

  @override
  void dispose() {
    _disposed = true;
    pauseTimer();
    super.dispose();
  }

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
    final result = _pending.then((_) => operation());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<void> load() => _enqueue(() async {
    _lastName = await storage.getLastName() ?? '';
    _lastNim = await storage.getLastNim() ?? '';
    _savedSession = await storage.getSession(_bank);
    _notify();
  });

  Future<void> startNew(String name, String nim) => _enqueue(() async {
    final trimmed = name.trim();
    if (!RegExp(r'^\d{9}$').hasMatch(nim)) {
      throw ArgumentError.value(nim, 'nim');
    }
    if (trimmed.runes.length < kMinPlayerNameLength ||
        trimmed.runes.length > kMaxPlayerNameLength) {
      throw ArgumentError.value(name, 'name', 'Nama harus 2–20 karakter.');
    }
    if (_bank.length < kQuestionsPerSession ||
        _bank.map((question) => question.id).toSet().length != _bank.length) {
      throw StateError('Bank soal harus cukup dan ID harus unik.');
    }
    final candidates = List<Question>.of(_bank)..shuffle(_random);
    final items = candidates
        .take(kQuestionsPerSession)
        .map((question) => SessionQuestion.shuffled(question, _random))
        .toList();
    final next = QuizSession(
      playerName: trimmed,
      nim: nim,
      items: items,
      answers: List.filled(items.length, null),
      currentIndex: 0,
      startedAt: _now(),
    );
    await storage.setLastName(trimmed);
    await storage.setLastNim(nim);
    await _persist(next);
    _lastName = trimmed;
    _lastNim = nim;
    _pendingAnswer = null;
    _status = QuizStatus.inProgress;
    _result = null;
    _historyRecorded = false;
    _resetTimer();
    _notify();
  });

  Future<void> _persist(QuizSession next) async {
    await storage.setSession(next);
    _session = next;
    _savedSession = next;
  }

  Future<void> selectAnswer(int displayedIndex) {
    final expected = _session;
    return _enqueue(() async {
      if (_status != QuizStatus.inProgress ||
          _result != null ||
          !identical(expected, _session) ||
          _remainingSeconds == 0 ||
          isCurrentResolved) {
        return;
      }
      if (displayedIndex < 0 || displayedIndex > 3) {
        throw RangeError.range(displayedIndex, 0, 3, 'displayedIndex');
      }
      final updated = List<int?>.of(answers)..[currentIndex] = displayedIndex;
      _cancelTimer();
      try {
        await _persist(_session!.copyWith(answers: updated));
        _pendingAnswer = null;
      } finally {
        _scheduleTimer();
      }
      _notify();
    });
  }

  Future<void> next() => _enqueue(() async {
    if (_status != QuizStatus.inProgress ||
        _result != null ||
        isLastQuestion ||
        !isCurrentResolved) {
      return;
    }
    await _persist(_session!.copyWith(currentIndex: currentIndex + 1));
    _pendingAnswer = null;
    _resetTimer();
    _notify();
  });

  Future<void> resume() => _enqueue(() async {
    if (_status == QuizStatus.inProgress) {
      if (_result == null) _scheduleTimer();
      _notify();
      return;
    }
    final saved = await storage.getSession(_bank);
    _savedSession = saved;
    if (saved != null) {
      _session = saved;
      _status = QuizStatus.inProgress;
      _result = null;
      _historyRecorded = false;
    }
    _resetTimer();
    _notify();
  });

  Future<void> finish() => _enqueue(_finish);

  Future<void> _finish() async {
    if (_status != QuizStatus.inProgress ||
        !isLastQuestion ||
        !isCurrentResolved) {
      return;
    }
    _cancelTimer();
    final record = _result ??= ScoreRecord(
      session: _session!,
      finishedAt: _now(),
    );
    if (!_historyRecorded) {
      await onFinished(record);
      _historyRecorded = true;
    }
    await storage.clearSession();
    _savedSession = null;
    _status = QuizStatus.finished;
    _notify();
  }

  Future<void> discard() => _enqueue(() async {
    await storage.clearSession();
    _session = null;
    _pendingAnswer = null;
    _savedSession = null;
    _result = null;
    _historyRecorded = false;
    _status = QuizStatus.idle;
    pauseTimer();
    _timerFailed = false;
    _notify();
  });
}
