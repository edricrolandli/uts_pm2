import 'dart:convert';
import 'dart:io';

import 'package:uts_pm2/data/question_bank.dart';

// Jalankan: dart run tool/validate_question_bank.dart <path-ke-psql.exe>
// Autentikasi memakai konfigurasi lokal psql. -w melarang prompt password.
Future<void> main(List<String> args) async {
  final psql = args.isEmpty ? 'psql' : args.single;
  const database = 'queryquest_scratch';
  final rows = <String>[];
  var created = false;

  Future<String> sql(String db, String query) async {
    final result = await Process.run(
      psql,
      [
        '-X',
        '-w',
        '-q',
        '-A',
        '-t',
        '-F',
        '|',
        '-v',
        'ON_ERROR_STOP=1',
        '-d',
        db,
        '-c',
        query,
      ],
      environment: {'PGCLIENTENCODING': 'UTF8'},
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    if (result.exitCode != 0) {
      throw StateError(
        'psql gagal (kode ${result.exitCode}): ${result.stderr}',
      );
    }
    return (result.stdout as String).trim().replaceAll('\r\n', '\n');
  }

  String cell(String value) => value
      .replaceAll('|', '&#124;')
      .replaceAll('\r', '')
      .replaceAll('\n', '<br>');

  Future<void> validate(
    String id,
    String expected, {
    String? verify,
    bool rollback = false,
  }) async {
    final question = kQuestionBank.singleWhere((q) => q.id == id);
    final snippet = question.codeSnippet!;
    final commands = [
      if (rollback) 'BEGIN;',
      snippet,
      ?verify,
      if (rollback) 'ROLLBACK;',
    ].join('\n');
    final actual = await sql(database, commands);
    if (actual != expected) {
      throw StateError('$id: diharapkan [$expected], didapat [$actual]');
    }
    final key =
        '${String.fromCharCode(65 + question.correctIndex)}. '
        '${question.options[question.correctIndex]}';
    rows.add(
      '| $id | `${cell(snippet)}`${verify == null ? '' : '<br>Verifikasi: `${cell(verify)}`'} '
      '| ${cell(actual)} | ${cell(key)} |',
    );
    stdout.writeln('$id: cocok');
  }

  try {
    final version = await sql('postgres', 'SELECT version();');
    // CREATE gagal jika nama ini sudah ada: jangan pernah menimpa database lama.
    await sql('postgres', 'CREATE DATABASE $database;');
    created = true;
    await validate(
      'q07',
      'id_kandang|PRIMARY KEY',
      verify: '''SELECT kcu.column_name, tc.constraint_type
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
  AND tc.table_name = kcu.table_name
WHERE tc.table_schema = 'public' AND tc.table_name = 'kandang'
  AND tc.constraint_type = 'PRIMARY KEY';''',
    );
    await validate(
      'q08',
      'kapasitas|integer',
      verify: '''SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'kandang'
  AND column_name = 'kapasitas';''',
    );
    await sql(
      database,
      '''INSERT INTO kandang VALUES (1, 'Hutan', 4), (2, 'Savana', 3);
CREATE TABLE satwa (
  id_satwa INTEGER PRIMARY KEY,
  nama VARCHAR(40) NOT NULL,
  id_kandang INTEGER REFERENCES kandang(id_kandang),
  berat DECIMAL(8,2) NOT NULL
);
INSERT INTO satwa VALUES
  (1, 'Raka', 1, 120), (2, 'Nala', 1, 80),
  (3, 'Bimo', 2, 200), (4, 'Lilo', NULL, 50);
CREATE TABLE divisi_suaka (id_divisi INTEGER PRIMARY KEY, nama VARCHAR(40) NOT NULL);
INSERT INTO divisi_suaka VALUES (1, 'Perawatan'), (2, 'Edukasi');
CREATE TABLE petugas_tetap (
  id_petugas INTEGER PRIMARY KEY,
  nama VARCHAR(40) NOT NULL,
  id_divisi INTEGER REFERENCES divisi_suaka(id_divisi)
);
INSERT INTO petugas_tetap VALUES (1, 'Dina', 1), (2, 'Eko', 1), (3, 'Fani', 2);''',
    );
    await validate(
      'q09',
      '5',
      verify: 'SELECT COUNT(*) FROM satwa;',
      rollback: true,
    );
    await validate(
      'q10',
      'Raka|120.00\nNala|90.00\nBimo|200.00\nLilo|60.00',
      verify: 'SELECT nama, berat FROM satwa ORDER BY id_satwa;',
      rollback: true,
    );
    await validate(
      'q11',
      '1\n2\n3',
      verify: 'SELECT id_satwa FROM satwa ORDER BY id_satwa;',
      rollback: true,
    );
    await validate('q12', 'Raka|Hutan\nNala|Hutan\nBimo|Savana');
    await validate('q13', 'Raka|Hutan\nNala|Hutan\nBimo|Savana\nLilo|');
    await validate('q14', 'Dina\nEko');
    await validate('q15', '4|3');
    // PostgreSQL mempertahankan skala tambahan untuk AVG(numeric).
    final q16 = kQuestionBank.singleWhere((q) => q.id == 'q16');
    final average = await sql(database, q16.codeSnippet!);
    if (double.parse(average) != 112.5) throw StateError('q16: hasil $average');
    rows.add('| q16 | `${q16.codeSnippet}` | $average | D. 112.5 |');
    stdout.writeln('q16: cocok');
    await validate('q17', '1|2');
    final report = StringBuffer('# Validasi bank soal\n\n')
      ..writeln('Dijalankan pada ${DateTime.now().toUtc().toIso8601String()}.')
      ..writeln('Server: $version\n')
      ..writeln(
        'Snippet diambil langsung dari `kQuestionBank`. Setiap soal DML '
        'diuji pada data awal yang sama dan di-rollback. Kolom kosong pada '
        'hasil q13 adalah NULL.\n',
      )
      ..writeln('| ID | Query yang dijalankan | Hasil nyata | Kunci |')
      ..writeln('| --- | --- | --- | --- |')
      ..writeln(rows.join('\n'))
      ..writeln(
        '\nSembilan soal konseptual tidak memiliki snippet SQL. '
        'Audit manual: q01 A (1:N), q02 B (unik dan NOT NULL), '
        'q03 C (kunci gabungan), q04 D (satu nomor per baris), '
        'q05 A (ketergantungan parsial), q06 B (pisahkan departemen), '
        'q18 B (UNIQUE), q19 C (Atomicity), q20 D (Durability). '
        'Masing-masing memiliki satu jawaban benar berdasarkan premis soal.\n',
      )
      ..writeln(
        'Distribusi: ERD/key 3; normalisasi 3; DDL 2; DML 3; JOIN 3; '
        'agregasi 3; index/constraint 1; transaksi/ACID 2.',
      );
    await Directory('docs').create(recursive: true);
    await File('docs/QUESTION_VALIDATION.md').writeAsString(report.toString());
  } finally {
    if (created) {
      await sql('postgres', 'DROP DATABASE $database;');
      stdout.writeln('$database dihapus.');
    }
  }
}
