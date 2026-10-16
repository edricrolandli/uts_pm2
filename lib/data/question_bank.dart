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
];
