# [nama apps]

Aplikasi kuis pilihan ganda materi Lab Basis Data (Flutter).

## Identitas
- Nama: Edric Roland Li
- NIM: 241401079
- Lab: PM 2

## Info Aplikasi
- Deskripsi: [placeholder]
- Fitur: [placeholder]

## Dokumentasi
### Kredit Aset
| Aset | Sumber | Lisensi |
|---|---|---|

### Screenshot
[placeholder]

### Mockup / Prototype
Link: https://www.figma.com/design/DjSudGVr2XsTOGQyw1iZqn/uts_pm2

## Materi Presentasi
[placeholder]

### Aset Day 3
- Logo (`assets/images/logo.svg`) dan schema doodle (`assets/images/schema_doodle.svg`) adalah **placeholder SVG buatan proyek**, bukan hasil ekspor Figma final. Ganti dengan aset Figma pemilik sebelum penyerahan; pertahankan bentuk dan token desain.
- Ikon: [Phosphor Icons, bold](https://github.com/phosphor-icons/core), MIT. Salinan lisensi: `assets/licenses/Phosphor-MIT.txt`.
- Font: Nunito (SIL OFL) dan [JetBrains Mono](https://github.com/JetBrains/JetBrainsMono) (SIL OFL). Bobot Mono Bold dibundel untuk label 700.
- Nama aplikasi tetap **QueryQuest**, sesuai implementasi sebelumnya.

### Catatan implementasi visual
Palet v2 digunakan tanpa menambah warna. Untuk kontras, `onPrimary` di dark mode memakai tinta gelap dari palet light (sekitar 10,64:1 pada amber). Outline kontrol/fokus memakai `outlineStrong`; `line` tetap untuk pemisah dekoratif. Feedback benar memakai `onCorrectContainer`, bukan hijau sebagai teks kecil. Target sentuh minimal 48dp dan text scale maksimum 1,3.

### Status Day 3
Home memiliki input nama, resume/buang sesi, tema tersimpan, dan named routes. Quiz memiliki progress per soal, pilihan terkunci, feedback benar/salah, penjelasan, navigasi lanjut/selesai, serta konfirmasi keluar dengan sesi tersimpan. Layout compact memakai tombol bawah tetap; layout lebar memakai dua kolom yang dapat digulir terpisah.

Rute Result, Review, dan History sementara menampilkan halaman belum tersedia; isi fitur dijadwalkan Day 4. Tidak ada implementasi Day 4 pada perubahan Day 3.

Verifikasi Day 3 (17 Oktober 2026): `flutter analyze` tanpa issue dan 49 test lulus. Widget test mencakup 360x640, 412x915, 640x360, dan 1280x800 pada light/dark, text scale besar (dibatasi 1,3), reduced motion, kontras, alur selesai, dan resume. Uji browser melalui `flutter run -d web-server` memeriksa pilih/kunci jawaban, penjelasan, lanjut, dialog keluar, resume, serta tampilan desktop dan portrait 360x640. Pengujian perangkat Android/iOS belum dilakukan.

Day 2 di-merge setelah pemilik menyatakan soal dianggap valid pada 17 Oktober 2026. Query PostgreSQL belum dieksekusi oleh implementor; persetujuan pemilik bukan laporan hasil eksekusi SQL.
