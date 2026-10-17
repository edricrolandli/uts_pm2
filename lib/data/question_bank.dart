import '../models/question.dart';

const List<Question> kQuestionBank = [
  // ERD/key: q01–q03.
  Question(
    id: 'q01',
    text:
        'Dalam ERD perpustakaan, setiap peminjaman dimiliki tepat satu anggota. '
        'Seorang anggota dapat memiliki banyak peminjaman. Apa kardinalitas '
        'dari Anggota ke Peminjaman?',
    options: [
      'Satu ke banyak',
      'Satu ke satu',
      'Banyak ke banyak',
      'Tidak ada relasi',
    ],
    correctIndex: 0,
    explanation:
        'Satu anggota dapat berelasi dengan banyak peminjaman, '
        'sedangkan setiap peminjaman hanya merujuk satu anggota.',
  ),
  Question(
    id: 'q02',
    text:
        'Tabel Peserta memakai nomor_peserta sebagai primary key. '
        'Aturan mana yang wajib dipenuhi kolom tersebut?',
    options: [
      'Boleh NULL asal unik',
      'Harus unik dan tidak boleh NULL',
      'Harus bertipe teks',
      'Harus selalu berurutan tanpa celah',
    ],
    correctIndex: 1,
    explanation:
        'Primary key mengidentifikasi setiap baris secara unik '
        'dan tidak mengizinkan NULL. Nilainya tidak harus berurutan.',
  ),
  Question(
    id: 'q03',
    text:
        'Tabel Pendaftaran memiliki pasangan (id_mahasiswa, id_kelas). '
        'Mahasiswa boleh mengikuti banyak kelas, tetapi tidak boleh terdaftar '
        'dua kali pada kelas yang sama. Primary key mana yang sesuai?',
    options: [
      'id_mahasiswa saja',
      'id_kelas saja',
      'Gabungan id_mahasiswa dan id_kelas',
      'nama_mahasiswa saja',
    ],
    correctIndex: 2,
    explanation:
        'Kunci gabungan membuat setiap pasangan mahasiswa dan kelas '
        'unik tanpa membatasi mahasiswa atau kelas menjadi satu pendaftaran.',
  ),
  // Normalisasi: q04–q06.
  Question(
    id: 'q04',
    text:
        'Satu kolom nomor_telepon berisi beberapa nomor yang dipisahkan koma. '
        'Perubahan mana yang paling sesuai dengan 1NF untuk kebutuhan '
        'menyimpan beberapa nomor per pelanggan?',
    options: [
      'Mengurutkan nomor di dalam sel',
      'Mengganti koma dengan titik koma',
      'Menggabungkan nomor dengan nama pelanggan',
      'Menyimpan tiap nomor pada baris tersendiri di tabel TeleponPelanggan',
    ],
    correctIndex: 3,
    explanation:
        'Untuk kebutuhan ini, tiap nomor diperlakukan sebagai nilai '
        'tunggal. Tabel terpisah menyimpan satu nomor per baris beserta ID pelanggan.',
  ),
  Question(
    id: 'q05',
    text:
        'DetailPesanan berkunci gabungan (id_pesanan, id_produk). '
        'Kolom nama_produk hanya bergantung pada id_produk. '
        'Ketergantungan ini merupakan pelanggaran terhadap bentuk normal apa '
        'jika tabel sudah memenuhi 1NF?',
    options: [
      '2NF, karena ada ketergantungan parsial pada kunci',
      '1NF, karena semua primary key gabungan dilarang',
      'Tidak melanggar 2NF karena nama_produk bukan kunci',
      '2NF, karena semua kolom harus berupa angka',
    ],
    correctIndex: 0,
    explanation:
        'Atribut nonkunci harus bergantung pada seluruh kunci kandidat '
        'untuk memenuhi 2NF. Nama produk hanya bergantung pada sebagian kunci.',
  ),
  Question(
    id: 'q06',
    text:
        'Tabel Pegawai memiliki id_pegawai sebagai satu-satunya kunci kandidat. '
        'Berlaku id_pegawai → id_departemen dan id_departemen → nama_departemen. '
        'Bagaimana menghilangkan ketergantungan transitif tersebut?',
    options: [
      'Menggandakan nama_departemen di setiap baris',
      'Memindahkan id_departemen dan nama_departemen ke tabel Departemen, '
          'lalu menyimpan id_departemen sebagai foreign key di Pegawai',
      'Menghapus semua id_pegawai',
      'Mengubah nama_departemen menjadi huruf besar',
    ],
    correctIndex: 1,
    explanation:
        'Nama departemen bergantung pada ID departemen, bukan langsung '
        'pada identitas pegawai. Pemisahan tabel menghindari pengulangan fakta departemen.',
  ),
  // DDL: q07–q08.
  Question(
    id: 'q07',
    text:
        'Setelah perintah berikut berhasil dijalankan pada database kosong, '
        'apa hasil utamanya?',
    codeSnippet: '''CREATE TABLE kandang (
  id_kandang INTEGER PRIMARY KEY,
  nama VARCHAR(40) NOT NULL
);''',
    options: [
      'Menambahkan satu baris kandang',
      'Menghapus tabel kandang',
      'Membuat tabel kandang dengan primary key id_kandang',
      'Mengganti semua nilai nama menjadi NULL',
    ],
    correctIndex: 2,
    explanation:
        'CREATE TABLE mendefinisikan struktur tabel. Perintah ini '
        'tidak menambahkan baris data.',
  ),
  Question(
    id: 'q08',
    text:
        'Tabel kandang sudah ada. Apa perubahan struktur yang dilakukan '
        'perintah berikut?',
    codeSnippet: 'ALTER TABLE kandang ADD COLUMN kapasitas INTEGER;',
    options: [
      'Menghapus kolom nama',
      'Mengubah nama tabel menjadi kapasitas',
      'Menambah satu baris bernilai INTEGER',
      'Menambahkan kolom kapasitas bertipe INTEGER',
    ],
    correctIndex: 3,
    explanation:
        'ALTER TABLE dengan ADD COLUMN menambahkan kolom ke tabel '
        'yang sudah ada. Baris lama mendapatkan NULL karena tidak ada DEFAULT.',
  ),
  // DML dasar: q09–q11. Setiap soal menggunakan data awalnya sendiri.
  Question(
    id: 'q09',
    text:
        'Tabel satwa berisi 4 baris dengan id_satwa 1–4. Kandang 2 tersedia '
        'dan tidak ada constraint lain yang menghalangi. Berapa jumlah baris '
        'satwa setelah perintah ini berhasil?',
    codeSnippet: '''INSERT INTO satwa (id_satwa, nama, id_kandang, berat)
VALUES (5, 'Suri', 2, 60);''',
    options: ['5 baris', '4 baris', '1 baris', '0 baris'],
    correctIndex: 0,
    explanation:
        'INSERT menambahkan satu baris baru. Empat baris awal tetap '
        'ada sehingga jumlahnya menjadi lima.',
  ),
  Question(
    id: 'q10',
    text:
        'Berat empat satwa adalah 120, 80, 200, dan 50. '
        'Berapa baris yang diubah oleh perintah berikut?',
    codeSnippet: 'UPDATE satwa SET berat = berat + 10 WHERE berat < 100;',
    options: ['1 baris', '2 baris', '3 baris', '4 baris'],
    correctIndex: 1,
    explanation:
        'Hanya berat 80 dan 50 memenuhi WHERE berat < 100. '
        'Keduanya berubah menjadi 90 dan 60.',
  ),
  Question(
    id: 'q11',
    text:
        'Empat baris satwa memiliki id_satwa 1, 2, 3, dan 4. '
        'Tidak ada foreign key dari tabel lain yang menghalangi penghapusan. '
        'Baris mana yang tersisa setelah perintah berikut?',
    codeSnippet: 'DELETE FROM satwa WHERE id_satwa = 4;',
    options: [
      'Hanya id_satwa 4',
      'Tidak ada baris',
      'id_satwa 1, 2, dan 3',
      'Semua id_satwa 1–4',
    ],
    correctIndex: 2,
    explanation:
        'DELETE menghapus baris yang memenuhi kondisi WHERE. '
        'Baris dengan ID selain 4 tetap tersimpan.',
  ),
  // JOIN: q12–q14.
  Question(
    id: 'q12',
    text:
        'Satwa Raka dan Nala berada di kandang 1, Bimo di kandang 2, '
        'sedangkan Lilo memiliki id_kandang NULL. Tabel kandang memiliki '
        'primary key id_kandang dengan nilai 1 dan 2. Berapa baris hasil query ini?',
    codeSnippet: '''SELECT s.nama, k.nama AS nama_kandang
FROM satwa s
INNER JOIN kandang k ON s.id_kandang = k.id_kandang
ORDER BY s.id_satwa;''',
    options: ['0 baris', '2 baris', '4 baris', '3 baris'],
    correctIndex: 3,
    explanation:
        'INNER JOIN hanya menyertakan pasangan yang cocok. '
        'Lilo tidak memiliki pasangan karena id_kandang bernilai NULL.',
  ),
  Question(
    id: 'q13',
    text:
        'Raka dan Nala berada di kandang 1, Bimo di kandang 2, '
        'dan Lilo memiliki id_kandang NULL. Kandang 1 dan 2 masing-masing '
        'hanya memiliki satu baris. Bagaimana hasil untuk Lilo pada query ini?',
    codeSnippet: '''SELECT s.nama, k.nama AS nama_kandang
FROM satwa s
LEFT JOIN kandang k ON s.id_kandang = k.id_kandang
ORDER BY s.id_satwa;''',
    options: [
      'Lilo tetap tampil dengan nama_kandang NULL',
      'Lilo dihapus dari tabel satwa',
      'Lilo tidak tampil dalam hasil',
      'Lilo otomatis dipasangkan dengan kandang 1',
    ],
    correctIndex: 0,
    explanation:
        'LEFT JOIN mempertahankan semua baris tabel kiri. '
        'Kolom dari tabel kanan bernilai NULL jika tidak ada pasangan.',
  ),
  Question(
    id: 'q14',
    text:
        'Divisi 1 bernama Perawatan dan divisi 2 bernama Edukasi. '
        'Dina dan Eko memiliki id_divisi 1, Fani memiliki id_divisi 2. '
        'Nama siapa yang dihasilkan query berikut?',
    codeSnippet: '''SELECT p.nama
FROM petugas_tetap p
JOIN divisi_suaka d ON p.id_divisi = d.id_divisi
WHERE d.nama = 'Perawatan'
ORDER BY p.nama;''',
    options: [
      'Fani saja',
      'Dina dan Eko',
      'Dina, Eko, dan Fani',
      'Eko dan Fani',
    ],
    correctIndex: 1,
    explanation:
        'JOIN menghubungkan petugas dengan divisinya. WHERE kemudian '
        'memilih petugas pada divisi Perawatan, yaitu Dina dan Eko.',
  ),
  // Agregasi: q15–q17.
  Question(
    id: 'q15',
    text:
        'Tabel satwa memiliki empat baris. Tiga baris memiliki id_kandang '
        'dan satu baris bernilai NULL pada kolom tersebut. '
        'Apa pasangan nilai total dan ditempatkan dari query ini?',
    codeSnippet: '''SELECT COUNT(*) AS total, COUNT(id_kandang) AS ditempatkan
FROM satwa;''',
    options: ['3 dan 3', '4 dan 4', '4 dan 3', '3 dan 4'],
    correctIndex: 2,
    explanation:
        'COUNT(*) menghitung semua baris, sedangkan COUNT(kolom) '
        'hanya menghitung nilai kolom yang bukan NULL.',
  ),
  Question(
    id: 'q16',
    text:
        'Kolom berat bertipe DECIMAL berisi 120, 80, 200, dan 50, '
        'tanpa NULL. Berapa hasil query berikut?',
    codeSnippet: 'SELECT AVG(berat) AS rata_rata FROM satwa;',
    options: ['450', '100', '150', '112.5'],
    correctIndex: 3,
    explanation:
        'AVG menghitung rata-rata nilai bukan NULL. '
        'Jumlah 450 dibagi empat baris menghasilkan 112.5.',
  ),
  Question(
    id: 'q17',
    text:
        'Nilai id_kandang pada empat baris satwa adalah 1, 1, 2, dan NULL. '
        'Pasangan (id_kandang, jumlah) mana yang dihasilkan query berikut?',
    codeSnippet: '''SELECT id_kandang, COUNT(*) AS jumlah
FROM satwa
GROUP BY id_kandang
HAVING COUNT(*) >= 2;''',
    options: [
      'Hanya (1, 2)',
      'Hanya (2, 1)',
      '(1, 2) dan (2, 1)',
      'Hanya (NULL, 1)',
    ],
    correctIndex: 0,
    explanation:
        'GROUP BY membentuk kelompok per id_kandang. HAVING '
        'mempertahankan hanya kelompok dengan minimal dua baris, yaitu kandang 1.',
  ),
  // Index/constraint: q18.
  Question(
    id: 'q18',
    text:
        'Kolom email sudah diberi NOT NULL. Aturan apa yang secara eksplisit '
        'menjamin bahwa dua akun tidak dapat menyimpan email yang sama?',
    options: [
      'Index biasa yang tidak UNIQUE',
      'Constraint UNIQUE pada email',
      'DEFAULT pada email',
      'Mengurutkan hasil SELECT berdasarkan email',
    ],
    correctIndex: 1,
    explanation:
        'UNIQUE menolak nilai email yang duplikat. Index biasa '
        'dapat membantu pencarian tetapi tidak menjamin keunikan.',
  ),
  // Transaksi/ACID: q19–q20.
  Question(
    id: 'q19',
    text:
        'Transfer saldo terdiri dari pengurangan saldo A dan penambahan '
        'saldo B dalam satu transaksi. Jika langkah kedua gagal, kedua '
        'perubahan harus dibatalkan. Sifat ACID apa yang menjamin prinsip ini?',
    options: ['Durability', 'Isolation', 'Atomicity', 'Consistency saja'],
    correctIndex: 2,
    explanation:
        'Atomicity berarti seluruh operasi dalam transaksi berhasil '
        'sebagai satu kesatuan atau tidak diterapkan sama sekali.',
  ),
  Question(
    id: 'q20',
    text:
        'Database telah mengonfirmasi COMMIT berhasil. Setelah server '
        'restart, perubahan yang sudah di-commit tetap tersedia. '
        'Sifat ACID mana yang dijelaskan?',
    options: ['Atomicity', 'Consistency', 'Isolation', 'Durability'],
    correctIndex: 3,
    explanation:
        'Durability menjamin perubahan yang telah di-commit '
        'bertahan sesuai jaminan penyimpanan database, termasuk setelah restart.',
  ),
];
