# FINAL PROJECT BIG DATA

kelompok : B10

**1. Latar Belakang & Permasalahan Nyata di Dunia**
   
Di era digital saat ini, jumlah buku yang tersedia bagi pembaca, baik melalui platform e-commerce, perpustakaan digital, maupun toko buku online, sangatlah melimpah. Meskipun ini memberikan banyak pilihan, pembaca seringkali dihadapkan pada beberapa permasalahan nyata:
- **Information Overload**: Terlalu banyak pilihan membuat pembaca kesulitan menemukan buku yang benar-benar sesuai dengan minat dan kebutuhan mereka. Proses pencarian bisa memakan waktu dan melelahkan.
- **Rekomendasi Generik**: Banyak platform masih memberikan rekomendasi yang bersifat umum (misalnya, "buku terlaris" atau "buku baru rilis") yang belum tentu relevan untuk preferensi individual setiap pembaca.
- **Kesulitan Menemukan "Hidden Gems"**: Buku-buku berkualitas dari penulis yang kurang terkenal atau genre yang lebih spesifik seringkali tenggelam dan sulit ditemukan oleh pembaca yang mungkin akan menyukainya.
- **Rendahnya Engagement dan Konversi**: Bagi penyedia platform, rekomendasi yang tidak personal dapat menyebabkan rendahnya keterlibatan pengguna (user engagement) dan tingkat konversi penjualan atau peminjaman buku yang lebih rendah.
  
Permasalahan ini tidak hanya merugikan pembaca yang kehilangan kesempatan menemukan bacaan berkualitas, tetapi juga merugikan penulis, penerbit, dan platform penyedia buku karena potensi pasar yang tidak tergali maksimal.

**2. Solusi yang Ditawarkan: Sistem Rekomendasi Buku Personal**

Untuk mengatasi permasalahan di atas, proyek ini mengusulkan pengembangan sebuah prototipe **sistem rekomendasi buku yang lebih personal dan cerdas**. Solusi ini bertujuan untuk:
- Menganalisis preferensi individual pengguna berdasarkan histori interaksi mereka (misalnya, rating yang diberikan, buku yang pernah dibaca/dilihat).
- Memanfaatkan informasi detail mengenai buku (metadata seperti genre, penulis, sinopsis).
- Menggabungkan berbagai teknik rekomendasi (seperti collaborative filtering dan content-based filtering) untuk menghasilkan saran buku yang lebih relevan.
- Menyajikan rekomendasi melalui antarmuka pengguna yang sederhana dan intuitif.

Proyek ini akan mengimplementasikan alur data dari ingesti, pemrosesan, feature engineering, pelatihan model, hingga penyajian rekomendasi, dengan mensimulasikan pendekatan Data Lakehouse sederhana menggunakan teknologi yang mudah diakses dan diimplementasikan.

**3. Arsitektur Sistem yang Digunakan**

Arsitektur yang akan kita gunakan adalah versi sederhana yang fokus pada kemudahan implementasi, dengan MinIO sebagai pusat penyimpanan data dan Python beserta library-nya sebagai alat utama pemrosesan dan pengembangan model.

Berikut adalah penjelasan alur kerja arsitektur kita:

**1. Dataset Buku & Interaksi (File CSV/JSON Lokal):**
  - Penjelasan: Ini adalah titik awal kita. Kita akan menggunakan file data (misalnya, books.csv berisi info buku, dan ratings.csv berisi rating pengguna terhadap buku) yang disimpan di komputer lokal. Ini adalah bahan baku utama untuk sistem rekomendasi kita.
    
**2. Skrip Python (Batch Ingest)**
  - Penjelasan: Sebuah skrip Python akan membaca file-file data lokal tersebut dan mengunggahnya apa adanya (mentah) ke MinIO. Ini adalah tahap "ingesti" atau memasukkan data ke dalam "danau data" kita. MinIO di sini berperan sebagai penyimpanan awal

**3. MinIO - Bronze Layer (Data Mentah: CSV/JSON):**
  - Penjelasan: Ini adalah "folder" atau bucket di MinIO tempat data mentah dari langkah 2 disimpan. Data di sini belum diapa-apakan, persis seperti aslinya. Menyimpan data mentah penting agar jika ada kesalahan di tahap selanjutnya, kita bisa kembali ke data asli.

**4. Skrip Python/Pandas (ETL & Transformasi) --> Pembersihan, Penggabungan**
  - Penjelasan: Skrip Python lain (menggunakan library Pandas) akan mengambil data dari MinIO Bronze. Skrip ini akan melakukan:
    - **Extract**: Mengambil data.
    - **Transform**: Membersihkan data (misalnya, mengisi nilai yang hilang, menghapus duplikasi, memperbaiki format), dan mungkin menggabungkan data dari beberapa file (misalnya, data rating dengan data buku).
    - **Load**: Hasilnya akan disimpan ke tahap berikutnya.

**5. MinIO - Silver Layer (Data Bersih: Parquet/CSV):**
  - Penjelasan: Data yang sudah bersih dan terstruktur dari langkah 4 disimpan kembali ke MinIO, tetapi di "folder" atau bucket yang berbeda, yaitu Silver Layer. Data di sini sudah siap untuk dianalisis lebih lanjut atau untuk dibuatkan fitur. Formatnya bisa Parquet (lebih efisien) atau tetap CSV.

**6. Skrip Python/Pandas/Scikit-learn (Feature Engineering):**
  - Penjelasan: Dari data bersih di MinIO Silver, skrip Python ini akan membuat fitur-fitur yang dibutuhkan oleh model machine learning. Contoh:
    - Membuat matriks interaksi pengguna-buku (siapa me-rating buku apa).
    - Mengubah teks sinopsis menjadi vektor angka (menggunakan TF-IDF dari Scikit-learn).
    - Fitur-fitur ini akan membantu model "belajar".

**7. MinIO - Gold Layer (Fitur Siap Model: .pkl / Parquet):**
  - Penjelasan: Fitur-fitur yang sudah jadi dari langkah 6 disimpan lagi ke MinIO di "folder" Gold. Ini adalah data yang benar-benar siap dimasukkan ke dalam model machine learning.

**8. Skrip Python/Scikit-learn (Training Model) --> Collaborative, Content-Based**
  - Penjelasan: Skrip Python ini (menggunakan library Scikit-learn atau library rekomendasi lain yang sederhana) akan mengambil data fitur dari MinIO Gold. Kemudian, model machine learning akan dilatih. Kita bisa melatih dua jenis model:
    - Collaborative Filtering: Merekomendasikan berdasarkan kesamaan pola antar pengguna.
    - Content-Based Filtering: Merekomendasikan berdasarkan kemiripan konten buku.

**9. MinIO - Gold Layer (Model Tersimpan: .pkl):**
  - Penjelasan: Setelah model selesai dilatih dan "pintar", file model tersebut (biasanya berekstensi .pkl jika menggunakan Scikit-learn) disimpan ke MinIO Gold. Ini penting agar model bisa digunakan kapan saja tanpa perlu dilatih ulang dari awal.

**10. API Backend (Python Flask/FastAPI) --> Juga mengambil Metadata Buku dari MinIO - Silver Layer**
  - Penjelasan: Ini adalah program server kecil yang ditulis dengan Python (menggunakan Flask atau FastAPI). Tugasnya adalah:
    - Menerima permintaan (misalnya, dari UI yang meminta rekomendasi untuk user tertentu).
    - Memuat model yang sudah terlatih dari MinIO Gold (langkah 9).
    - Menggunakan model tersebut untuk menghasilkan daftar buku rekomendasi.
    - Mengambil detail buku (seperti judul, penulis) dari MinIO Silver agar rekomendasi lebih informatif.
    - Mengirimkan daftar rekomendasi kembali ke peminta (misalnya, UI).

**11. Tampilan UI Sederhana (Streamlit):**
  - Penjelasan: Ini adalah antarmuka pengguna (web sederhana) yang dibuat dengan Streamlit. Pengguna bisa berinteraksi dengan UI ini. UI akan "berbicara" dengan API Backend (langkah 10) untuk meminta dan menampilkan rekomendasi buku.

Kenapa Arsitektur Ini?

Struktur ini dipilih karena kesederhanaannya untuk implementasi proyek mahasiswa. Ia menggunakan Python dan library yang umum, dengan MinIO sebagai pusat penyimpanan yang mudah di-setup. Meskipun sederhana, ia tetap mengenalkan konsep penting seperti layering data (Bronze, Silver, Gold) yang merupakan dasar dari Data Lakehouse, serta alur kerja Machine Learning dari data hingga penyajian.

