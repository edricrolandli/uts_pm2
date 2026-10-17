import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../models/score_record.dart';
import '../services/storage_service.dart';

class HistoryProvider extends ChangeNotifier {
  HistoryProvider(this._storage);

  final StorageService _storage;
  List<ScoreRecord> _records = [];
  Future<void> _pending = Future.value();

  List<ScoreRecord> get records => List.unmodifiable(_records);

  Future<void> _enqueue(Future<void> Function() operation) {
    final result = _pending.then((_) => operation());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<void> load() => _enqueue(() async {
    _records = (await _storage.getHistory())
      ..sort((a, b) => b.finishedAt.compareTo(a.finishedAt));
    _records = _records.take(kMaxHistoryLength).toList();
    notifyListeners();
  });

  Future<void> add(ScoreRecord record) => _enqueue(() async {
    final updated = [record, ..._records].take(kMaxHistoryLength).toList();
    await _storage.setHistory(updated);
    _records = updated;
    notifyListeners();
  });

  Future<void> clear() => _enqueue(() async {
    await _storage.setHistory([]);
    _records = [];
    notifyListeners();
  });
}
