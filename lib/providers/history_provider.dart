import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../models/score_record.dart';
import '../services/storage_service.dart';

class HistoryProvider extends ChangeNotifier {
  HistoryProvider(this._storage);

  final StorageService _storage;
  List<ScoreRecord> _records = [];
  Future<void> _pending = Future.value();

  String? _nim;
  String? get nim => _nim;
  List<ScoreRecord> get records =>
      List.unmodifiable(_records.where((r) => r.nim == _nim));
  void selectNim(String nim) {
    _nim = nim;
    notifyListeners();
  }

  Future<void> _enqueue(Future<void> Function() operation) {
    final result = _pending.then((_) => operation());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<void> load() => _enqueue(() async {
    _nim = await _storage.getLastNim();
    _records = (await _storage.getHistory())
      ..sort((a, b) => b.finishedAt.compareTo(a.finishedAt));
    final counts = <String, int>{};
    _records = _records
        .where(
          (r) =>
              (counts.update(r.nim, (n) => n + 1, ifAbsent: () => 1)) <=
              kMaxHistoryLength,
        )
        .toList();
    notifyListeners();
  });

  Future<void> add(ScoreRecord record) => _enqueue(() async {
    final updated = [
      ..._records.where((r) => r.nim != record.nim),
      ...[
        record,
        ..._records.where((r) => r.nim == record.nim),
      ].take(kMaxHistoryLength),
    ]..sort((a, b) => b.finishedAt.compareTo(a.finishedAt));
    _nim = record.nim;
    await _storage.setHistory(updated);
    _records = updated;
    notifyListeners();
  });

  Future<void> clear() => _enqueue(() async {
    final updated = _records.where((r) => r.nim != _nim).toList();
    await _storage.setHistory(updated);
    _records = updated;
    notifyListeners();
  });
}
