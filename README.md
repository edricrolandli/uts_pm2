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

### Status Day 4 — 18 Oktober 2026
Result, Review, dan History sudah menggantikan placeholder Day 3. Result menampilkan nilai, grade, segmen hasil, tabel, serta durasi sesi. Review menampilkan jawaban sesuai urutan opsi sesi, kunci, SQL, penjelasan buka/tutup, dan filter Semua/Salah. History memuat maksimal 20 skor terbaru dan konfirmasi hapus semua.

`QuizProvider.finish()` tetap dipanggil sebelum navigasi Result, sesuai persetujuan pemilik. Flag `_historyRecorded` mencegah simpan ulang saat retry; rebuild Result tidak melakukan write. Durasi memakai selisih `finishedAt` dan `startedAt`, diformat `intl` sebagai total menit:detik (64:12 tidak berubah menjadi 04:12). Token baru yang disetujui: count-up 700 ms dan stagger 40 ms, keduanya nol ketika reduced motion aktif. Tidak ada pekerjaan Day 5 atau perubahan palet/font.

Verifikasi Day 4: `flutter analyze` tanpa issue; 62 test lulus. Widget test mencakup 360x640, 412x915, 640x360, 1280x800 dengan teks besar, idempotensi finish/rebuild, batas grade/durasi, reduced motion, filter termasuk nol salah, penjelasan, navigasi, empty state, batal/hapus, dan persistensi. Test provider mencakup batas 20 entri dan reload penyimpanan. Uji browser melalui `flutter run -d web-server` mencakup kuis sampai Result, Review/filter/penjelasan/back, serta History terisi setelah restart, batal hapus dan hapus sampai kosong. Perangkat/emulator Android belum diuji.

Audit enam pola desain visual: tidak ada pelanggaran. Pola mentah `Colors\.` juga mencocokkan properti `quizColors` (false positive pada Home, KeyButton, ResultGrid); penggunaan `Colors.*` sebenarnya tidak ada. Lima pola lainnya kosong.

### Status Day 5

- [x] Dark Mode: toggle tersimpan, ikon mengikuti mode tujuan, kontras error diperbaiki memakai palet yang ada, dan transisi mengikuti reduced motion.
- [x] Expressive Motion: tekan/morph/getar opsi dan count-up skor tersedia. Radius badge kini berubah sepanjang animasi; getaran di-reset ketika reduced motion aktif. Transisi rute menggunakan AppMotion.
- [x] Responsive Layout: implementasi dua kolom dan maxWidth yang sudah ada diverifikasi pada batas 599/600 dan 1023/1024, layar 320 sampai 1920 piksel, keyboard terbuka, serta scroll kolom independen. Tidak perlu membuat ulang layout.
- [x] Splash Screen: logo, query diketik 28 ms per karakter, kursor 500 ms, durasi 1,6 detik, lalu mengganti rute ke Home. Reduced motion melewati animasi.
- [x] Question Timer (opsional): 30 detik per soal di QuizProvider, lima detik terakhir diberi penanda, waktu habis menyimpan jawaban kosong dan otomatis maju/selesai. Timer berhenti saat jawaban terkunci, dialog keluar, aplikasi tidak aktif, layar ditutup, kuis selesai, atau provider di-dispose. Resume dari Home mengulang waktu soal aktif; kembali dari background meneruskan sisa waktu.

Timeout mengikuti antrean penyimpanan yang sama dengan jawaban. Jawaban terlambat tidak dapat masuk ke soal berikutnya; kegagalan penyimpanan menyediakan retry tanpa melompati soal atau menggandakan riwayat. Soal kosong yang sudah lewat ditampilkan sebagai salah pada progres dan Result.

Verifikasi akhir Day 5: `flutter analyze --no-pub` tanpa issue, 82 test lulus, audit token dan `git diff --check` bersih. Uji browser melalui `flutter run -d web-server` memverifikasi Splash menuju Home, resume, countdown, perpindahan otomatis setelah timeout, dan timer berhenti setelah memilih jawaban. Emulator Android sempat digunakan pada branch motion, tetapi tidak terhubung pada pemeriksaan akhir; uji interaksi Android untuk timer terakhir belum dilakukan.

Seluruh fitur dikerjakan lewat branch masing-masing dan merge `--no-ff`, tanpa mengubah tanggal commit. Dokumen perencanaan tetap di luar repository. Pekerjaan Day 6 belum dimulai.

Catatan lingkungan Android: build APK debug semua arsitektur pada pemeriksaan akhir terhalang unduhan engine ARM karena trust store Java/Gradle melaporkan `PKIX path building failed`. Build ARM dan uji perangkat fisik perlu diulang setelah konfigurasi sertifikat lingkungan diperbaiki; verifikasi TLS tidak dinonaktifkan.
