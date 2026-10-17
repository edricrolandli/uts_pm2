import 'package:intl/intl.dart';

abstract final class AppStrings {
  static const resultEyebrow = 'HASIL';
  static const outOfHundred = 'DARI 100';
  static const correctHeader = 'BENAR';
  static const scoreHeader = 'NILAI';
  static const seeReview = 'Lihat review';
  static String grade(double score) => score >= 90
      ? 'Nyaris sempurna.'
      : score >= 70
      ? 'Udah kuat.'
      : score >= 50
      ? 'Hampir. Cek lagi yang salah.'
      : 'Pelan-pelan, mulai dari review.';
  static String scoreValue(double score) => NumberFormat('0').format(score);
  static String correctTotal(int correct, int total) => '$correct/$total';
  static String resultFooter(Duration elapsed) {
    final seconds = elapsed.inSeconds < 0 ? 0 : elapsed.inSeconds;
    final twoDigits = NumberFormat('00');
    return '1 BARIS · ${twoDigits.format(seconds ~/ 60)}:${twoDigits.format(seconds % 60)}';
  }

  static const appName = 'QueryQuest';
  static const homeEyebrow = 'LAB BASIS DATA';
  static const homeHeadline = 'Seberapa kenal kamu sama tabel dan query?';
  static const nameLabel = 'NAMA';
  static const nameHint = 'mis. Budi';
  static const nameMin = 'Nama minimal 2 karakter.';
  static const nameMax = 'Maksimal 20 karakter.';
  static const start = 'Mulai kuis';
  static const resumeTitle = 'Ada kuis yang belum selesai';
  static const resume = 'Lanjutkan';
  static const discard = 'Buang';
  static const discardTitle = 'Buang kuis ini?';
  static const discardMessage = 'Progres kuis ini akan dihapus.';
  static const cancel = 'Batal';
  static const newTitle = 'Mulai kuis baru?';
  static const newMessage = 'Progres kuis sebelumnya akan dihapus.';
  static const startNew = 'Mulai baru';
  static const correct = 'Benar.';
  static const wrong = 'Belum tepat.';
  static const why = 'KENAPA';
  static const next = 'Lanjut';
  static const finish = 'Lihat hasil';
  static const exitTitle = 'Keluar dari kuis?';
  static const exitMessage =
      'Progresmu disimpan, bisa dilanjutkan dari halaman awal.';
  static const stay = 'Tetap main';
  static const exit = 'Keluar';
  static const returnHome = 'Kembali ke awal';
  static const result = 'Hasil';
  static const review = 'Review';
  static const historyTitle = 'Riwayat skor';
  static const upcoming = 'Halaman ini belum tersedia.';
  static const quizUpcoming =
      'Kuis sedang disiapkan. Progres awalmu sudah tersimpan.';
  static const saveFailed = 'Belum berhasil menyimpan. Coba lagi.';
  static const noSession = 'Belum ada kuis aktif. Mulai dari halaman awal.';
  static const darkMode = 'Gunakan tema gelap';
  static const lightMode = 'Gunakan tema terang';
  static const locked = 'Jawaban terkunci';
  static const answerKey = 'Kunci jawaban';
  static const selectedCorrect = 'Jawabanmu benar';
  static const selectedWrong = 'Jawabanmu salah';
  static String historyCount(int count) => 'Riwayat skor ($count)';
  static String resumeDetail(String name, int index, int total) =>
      '$name, soal ${index + 1} dari $total';
  static String questionNumber(int index) =>
      'SOAL ${(index + 1).toString().padLeft(2, '0')}';
  static String questionProgress(int index, int total) =>
      '${questionNumber(index)}/${total.toString().padLeft(2, '0')}';
  static String progressSemantics(
    int index,
    int total,
    int correct,
    int wrong,
  ) => 'Soal ${index + 1} dari $total, $correct benar, $wrong salah';
  static const optionLetters = ['A', 'B', 'C', 'D'];
  static String optionSemantics(int index, String text, String state) =>
      '${optionLetters[index]}, $text. $state';
}
