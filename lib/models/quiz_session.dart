import '../core/constants/app_constants.dart';
import 'question.dart';
import 'session_question.dart';

class QuizSession {
  QuizSession({
    required this.playerName,
    required this.nim,
    List<bool>? expired,
    required List<SessionQuestion> items,
    required List<int?> answers,
    required this.currentIndex,
    required this.startedAt,
  }) : items = List.unmodifiable(items),
       answers = List.unmodifiable(answers),
       expired = List.unmodifiable(
         expired ?? List.filled(items.length, false),
       ) {
    if (!RegExp(r'^\d{9}$').hasMatch(nim) ||
        this.expired.length != items.length) {
      throw const FormatException('NIM atau status waktu tidak valid.');
    }
    if (playerName.trim() != playerName ||
        playerName.runes.length < kMinPlayerNameLength ||
        playerName.runes.length > kMaxPlayerNameLength ||
        items.isEmpty ||
        items.map((item) => item.question.id).toSet().length != items.length ||
        answers.length != items.length ||
        answers.any((answer) => answer != null && (answer < 0 || answer > 3)) ||
        currentIndex < 0 ||
        currentIndex >= items.length) {
      throw const FormatException('Data sesi tidak valid.');
    }
  }

  factory QuizSession.fromJson(
    Map<String, dynamic> json,
    Iterable<Question> questionBank,
  ) {
    final byId = {for (final question in questionBank) question.id: question};
    return QuizSession(
      playerName: json['playerName'] as String,
      nim: json['nim'] as String,
      expired: (json['expired'] as List).cast<bool>(),
      items: (json['items'] as List)
          .map(
            (item) => SessionQuestion.fromJson(
              Map<String, dynamic>.from(item as Map),
              byId,
            ),
          )
          .toList(),
      answers: (json['answers'] as List).cast<int?>(),
      currentIndex: json['currentIndex'] as int,
      startedAt: DateTime.parse(json['startedAt'] as String),
    );
  }

  final String playerName;
  final String nim;
  final List<bool> expired;
  final List<SessionQuestion> items;
  final List<int?> answers;
  final int currentIndex;
  final DateTime startedAt;

  QuizSession copyWith({
    List<int?>? answers,
    List<bool>? expired,
    int? currentIndex,
  }) => QuizSession(
    playerName: playerName,
    nim: nim,
    expired: expired ?? this.expired,
    items: items,
    answers: answers ?? this.answers,
    currentIndex: currentIndex ?? this.currentIndex,
    startedAt: startedAt,
  );

  Map<String, dynamic> toJson() => {
    'playerName': playerName,
    'nim': nim,
    'expired': expired,
    'items': items.map((item) => item.toJson()).toList(),
    'answers': answers,
    'currentIndex': currentIndex,
    'startedAt': startedAt.toIso8601String(),
  };
}
