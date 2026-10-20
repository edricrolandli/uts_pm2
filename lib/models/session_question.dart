import 'dart:math';

import 'question.dart';

class SessionQuestion {
  SessionQuestion({required this.question, required List<int> optionOrder})
    : optionOrder = List.unmodifiable(optionOrder) {
    if (question.options.length != 4 ||
        question.correctIndex < 0 ||
        question.correctIndex > 3 ||
        optionOrder.length != 4 ||
        optionOrder.toSet().length != 4 ||
        optionOrder.any((index) => index < 0 || index > 3)) {
      throw const FormatException('Urutan opsi harus permutasi 0..3.');
    }
  }

  factory SessionQuestion.shuffled(Question question, Random random) {
    // Simpan permutasinya, bukan mengubah opsi pada bank soal bersama.
    final order = [0, 1, 2, 3]..shuffle(random);
    return SessionQuestion(question: question, optionOrder: order);
  }

  factory SessionQuestion.fromJson(
    Map<String, dynamic> json,
    Map<String, Question> questionBank,
  ) {
    final question = questionBank[json['questionId']];
    if (question == null) {
      throw FormatException('ID soal tidak ditemukan: ${json['questionId']}');
    }
    return SessionQuestion(
      question: json['question'] == null
          ? question
          : Question(
              id: question.id,
              text: (json['question'] as Map)['text'] as String,
              codeSnippet: (json['question'] as Map)['codeSnippet'] as String?,
              options: ((json['question'] as Map)['options'] as List)
                  .cast<String>(),
              correctIndex: (json['question'] as Map)['correctIndex'] as int,
              explanation: (json['question'] as Map)['explanation'] as String,
            ),
      optionOrder: (json['optionOrder'] as List).cast<int>(),
    );
  }

  final Question question;
  final List<int> optionOrder;

  List<String> get displayedOptions =>
      List.unmodifiable(optionOrder.map((index) => question.options[index]));
  int get displayedCorrectIndex => optionOrder.indexOf(question.correctIndex);

  Map<String, dynamic> toJson() => {
    'questionId': question.id,
    'question': {
      'text': question.text,
      'codeSnippet': question.codeSnippet,
      'options': question.options,
      'correctIndex': question.correctIndex,
      'explanation': question.explanation,
    },
    'optionOrder': optionOrder,
  };
}
