class ScoreRecord {
  const ScoreRecord({
    required this.playerName,
    required this.correct,
    required this.total,
    required this.finishedAt,
  }) : assert(total > 0),
       assert(correct >= 0 && correct <= total);

  factory ScoreRecord.fromJson(Map<String, dynamic> json) {
    final name = json['playerName'] as String;
    final correct = json['correct'] as int;
    final total = json['total'] as int;
    if (name.trim().isEmpty || total <= 0 || correct < 0 || correct > total) {
      throw const FormatException('Data skor tidak valid.');
    }
    return ScoreRecord(
      playerName: name,
      correct: correct,
      total: total,
      finishedAt: DateTime.parse(json['finishedAt'] as String),
    );
  }

  final String playerName;
  final int correct;
  final int total;
  final DateTime finishedAt;

  double get percent => correct / total * 100;

  Map<String, dynamic> toJson() => {
    'playerName': playerName,
    'correct': correct,
    'total': total,
    'finishedAt': finishedAt.toIso8601String(),
  };
}
