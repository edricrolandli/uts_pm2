import 'package:intl/intl.dart';

abstract final class AppStrings {
  static const identityEyebrow = 'IDENTITAS';
  static const identityTitle = 'Isi dulu nama dan NIM-⁠mu.';
  static const nimLabel = 'NIM';
  static const nimHint = 'mis. 241401079';
  static const nimDigits = 'NIM cuma angka.';
  static const nimLength = 'NIM harus 9 digit.';
  static const submitAnswer = 'Kirim jawaban';
  static const selectedPending = 'dipilih, belum dikirim';
  static const attemptDetail = 'Detail pengerjaan';
  static String nimIdentity(String nim) => 'NIM $nim';

  static const splashTagline = '#SemangatIKLC\n#SemangatMengajar';
  static const cursor = '_';
  static const timerReady = 'Waktu menjawab 30 detik';
  static const timerWarning = 'Waktu tersisa 5 detik';
  static const timerExpired = 'Waktu habis';
  static const timerOut = 'Habis';
  static const retrySave = 'Coba simpan lagi';
  static String timerValue(int seconds) =>
      '00:${seconds.toString().padLeft(2, '0')}';
  static const resultEyebrow = 'HASIL';
  static const outOfHundred = 'DARI 100';
  static const correctHeader = 'BENAR';
  static const scoreHeader = 'NILAI';
  static const clearHistory = 'Hapus semua';
  static const clearHistoryTitle = 'Hapus riwayat NIM ini?';
  static const clearHistoryMessage = 'Tidak bisa dibatalkan.';
  static const delete = 'Hapus';
  static const historyEmpty = 'Belum ada skor. Selesaikan satu kuis dulu.';
  static const dateHeader = 'TANGGAL';
  static String historyDate(DateTime date) =>
      DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal());
  static const allAnswers = 'Semua';
  static const noWrongAnswers = 'Semua jawabanmu benar.';
  static String wrongAnswers(int count) => 'Salah ($count)';
  static const yourAnswer = 'Jawabanmu';
  static const keyAnswer = 'Kunci';
  static const unanswered = 'Belum dijawab';
  static const back = 'Kembali';
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
  static const durationHeader = 'DURASI';
  static String elapsedTime(Duration elapsed) {
    final seconds = elapsed.inSeconds < 0 ? 0 : elapsed.inSeconds;
    final twoDigits = NumberFormat('00');
    return '${twoDigits.format(seconds ~/ 60)}:${twoDigits.format(seconds % 60)}';
  }

  static const appName = 'laby_rinth';
  static const homeEyebrow = 'LAB BASIS DATA';
  static const homeHeadline = 'Seberapa kenal kamu sama SQL?';
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
  static const review = 'Review';
  static const historyTitle = 'Riwayat skor';
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
