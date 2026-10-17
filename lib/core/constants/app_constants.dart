const int kQuestionsPerSession = 10;
const int kMinPlayerNameLength = 2;
const int kMaxPlayerNameLength = 20;
const int kMaxHistoryLength = 20;

String gradeLabel(double percent) {
  if (percent >= 90) return 'Database Wizard';
  if (percent >= 70) return 'Query Pro';
  if (percent >= 50) return 'Lumayan, lanjut belajar';
  return 'Perlu latihan JOIN lagi';
}
