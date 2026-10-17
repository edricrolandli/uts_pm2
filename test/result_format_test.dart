import 'package:flutter_test/flutter_test.dart';
import 'package:uts_pm2/core/constants/app_strings.dart';

void main() {
  test('grade boundaries and elapsed minutes do not wrap at one hour', () {
    expect(AppStrings.grade(90), 'Nyaris sempurna.');
    expect(AppStrings.grade(89), 'Udah kuat.');
    expect(AppStrings.grade(70), 'Udah kuat.');
    expect(AppStrings.grade(69), 'Hampir. Cek lagi yang salah.');
    expect(AppStrings.grade(50), 'Hampir. Cek lagi yang salah.');
    expect(AppStrings.grade(49), 'Pelan-pelan, mulai dari review.');
    expect(
      AppStrings.resultFooter(const Duration(minutes: 4, seconds: 12)),
      '1 BARIS · 04:12',
    );
    expect(
      AppStrings.resultFooter(
        const Duration(hours: 1, minutes: 4, seconds: 12),
      ),
      '1 BARIS · 64:12',
    );
  });
}
