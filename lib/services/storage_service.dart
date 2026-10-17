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
      // Data lama/rusak tidak boleh menghalangi aplikasi dibuka.
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

  Future<List<ScoreRecord>> getHistory() async =>
      await _read(StorageKeys.history, (value) {
        final list = jsonDecode(value) as List;
        return list
            .map(
              (item) =>
                  ScoreRecord.fromJson(Map<String, dynamic>.from(item as Map)),
            )
            .toList();
      }) ??
      <ScoreRecord>[];

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
