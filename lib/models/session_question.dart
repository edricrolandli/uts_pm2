import 'dart:math';

import 'question.dart';

class SessionQuestion {
  SessionQuestion({required this.question, required List<int> optionOrder})
    : optionOrder = List.unmodifiable(optionOrder) {
    if (optionOrder.length != 4 ||
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
      question: question,
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
    'optionOrder': optionOrder,
  };
}
