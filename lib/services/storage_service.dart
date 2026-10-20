import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/storage_keys.dart';
import '../models/question.dart';
import '../models/quiz_session.dart';
import '../models/score_record.dart';

class StorageService {
  StorageService(this.preferences);

  final SharedPreferences preferences;

  Future<void> _write(String key, String value) async {
    if (!await preferences.setString(key, value)) {
      throw StateError('Gagal menyimpan $key.');
    }
  }

  Future<void> _remove(String key) async {
    if (!await preferences.remove(key)) {
      throw StateError('Gagal menghapus $key.');
    }
  }

  Future<T?> _read<T>(String key, T Function(String) decode) async {
    try {
      final value = preferences.getString(key);
      return value == null ? null : decode(value);
    } catch (_) {
      await _remove(key);
      return null;
    }
  }

  Future<ThemeMode> getThemeMode() async =>
      await _read(
        StorageKeys.themeMode,
        (value) => ThemeMode.values.byName(value),
      ) ??
      ThemeMode.system;

  Future<void> setThemeMode(ThemeMode mode) =>
      _write(StorageKeys.themeMode, mode.name);

  Future<String?> getLastName() =>
      _read(StorageKeys.lastName, (value) => value);
  Future<void> setLastName(String name) => _write(StorageKeys.lastName, name);

  Future<String?> getLastNim() => _read(
    StorageKeys.lastNim,
    (value) => RegExp(r'^\d{9}$').hasMatch(value)
        ? value
        : throw const FormatException(),
  );
  Future<void> setLastNim(String nim) => _write(StorageKeys.lastNim, nim);

  Future<List<ScoreRecord>> getHistory() async {
    await _remove('history_v1');
    final records =
        await _read(StorageKeys.history, (value) {
          final records = <ScoreRecord>[];
          for (final entry in jsonDecode(value) as List) {
            try {
              records.add(
                ScoreRecord.fromJson(Map<String, dynamic>.from(entry as Map)),
              );
            } catch (_) {
              continue;
            }
          }
          return records;
        }) ??
        <ScoreRecord>[];
    await setHistory(records);
    return records;
  }

  Future<void> setHistory(List<ScoreRecord> records) => _write(
    StorageKeys.history,
    jsonEncode(records.map((record) => record.toJson()).toList()),
  );

  Future<QuizSession?> getSession(Iterable<Question> bank) => _read(
    StorageKeys.session,
    (value) =>
        QuizSession.fromJson(jsonDecode(value) as Map<String, dynamic>, bank),
  );

  Future<void> setSession(QuizSession session) =>
      _write(StorageKeys.session, jsonEncode(session.toJson()));

  Future<void> clearSession() => _remove(StorageKeys.session);
}
