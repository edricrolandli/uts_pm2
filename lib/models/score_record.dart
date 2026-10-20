import '../data/question_bank.dart';
import 'quiz_session.dart';

class ScoreRecord {
  const ScoreRecord({required this.session, required this.finishedAt});
  final QuizSession session;
  final DateTime finishedAt;
  String get playerName => session.playerName;
  String get nim => session.nim;
  int get total => session.items.length;
  int get correct => List.generate(total, (i) => i)
      .where(
        (i) => session.answers[i] == session.items[i].displayedCorrectIndex,
      )
      .length;
  double get percent => correct / total * 100;
  factory ScoreRecord.fromJson(Map<String, dynamic> json) {
    final session = QuizSession.fromJson(
      Map<String, dynamic>.from(json['session'] as Map),
      kQuestionBank,
    );
    final finishedAt = DateTime.parse(json['finishedAt'] as String);
    if (finishedAt.isBefore(session.startedAt) ||
        List.generate(
          session.items.length,
          (i) => i,
        ).any((i) => session.answers[i] == null && !session.expired[i])) {
      throw const FormatException('Pengerjaan belum selesai.');
    }
    return ScoreRecord(session: session, finishedAt: finishedAt);
  }
  Map<String, dynamic> toJson() => {
    'session': session.toJson(),
    'finishedAt': finishedAt.toIso8601String(),
  };
}
