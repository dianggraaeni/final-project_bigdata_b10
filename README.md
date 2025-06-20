# FINAL PROJECT BIG DATA

KELOMPOK : B10

|           Nama               |     NRP    |
|            --                |     --     |
| Riakiyatul Nur Oktarani      | 5027231013 |
| Dian Anggraeni Putri         | 5027231016 |
| Acintya Edria Sudarsono      | 5027231020 |
|Tsaldia Hukma Cita            | 5027231036 |
| Calista Meyra Azizah         | 5027231060 |

![image](https://github.com/user-attachments/assets/9a9f63ae-7e8d-458a-aadc-de3b591985e4)

## 1. Pendahuluan: Permasalahan Nyata di Dunia Literasi Digital
Era digital telah membuka akses tak terbatas terhadap jutaan judul buku. Namun, kelimpahan ini justru menghadirkan tantangan baru: pembaca seringkali kesulitan menemukan buku yang benar-benar sesuai minat di tengah lautan pilihan (information overload). Rekomendasi yang ada cenderung generik, membatasi penemuan karya baru atau "permata tersembunyi", dan kurang personal. Hal ini tidak hanya mempengaruhi kepuasan pembaca tetapi juga visibilitas penulis dan penerbit independen, serta mengurangi keterlibatan pengguna pada platform buku.

## 2. Solusi yang Ditawarkan: Sistem Rekomendasi Buku Cerdas
Untuk menjawab tantangan dalam menemukan bacaan yang relevan di era digital, proyek mengembangkan prototipe sistem rekomendasi buku yang lebih personal dan cerdas. Solusi kami berfokus pada pemahaman mendalam terhadap preferensi pengguna dan esensi konten buku. Dengan menganalisis histori interaksi pengguna (seperti rating) serta memanfaatkan metadata buku (judul, penulis, deskripsi, dan genre), kami mengimplementasikan model rekomendasi yang efektif, menggabungkan pendekatan Collaborative Filtering (berdasarkan kemiripan pola rating antar buku) dan Content-Based Filtering (berdasarkan kemiripan konten buku).

Seluruh proses ini didukung oleh arsitektur Data Lakehouse sederhana menggunakan MinIO sebagai object storage, yang mengelola data secara fleksibel mulai dari ingesti data sampel secara batch, pemrosesan melalui layer Bronze dan Silver, hingga penyimpanan fitur dan model siap pakai di layer Gold. Hasil rekomendasi dari sistem ini kemudian akan disajikan melalui sebuah API backend, yang memungkinkan integrasi mudah dengan antarmuka pengguna dan aplikasi lainnya. Fokus utama proyek ini adalah membangun pipeline data dan model rekomendasi inti yang fungsional sebagai dasar pengembangan lebih lanjut.

## 3. Dataset yang Digunakan

*   **Nama Dataset:** Amazon Books Reviews
*   **Sumber (Kaggle):** [https://www.kaggle.com/datasets/mohamedbakhet/amazon-books-reviews](https://www.kaggle.com/datasets/mohamedbakhet/amazon-books-reviews)
*   **File yang Digunakan:**
    1.  `Books_rating.csv`: Mengandung data rating, User ID, ID Buku (ASIN), timestamp, dan teks review.
    2.  `books_data.csv`: Mengandung metadata buku seperti judul, penulis, deskripsi, kategori, dll.
*   **Pengolahan Awal (Sampling & Penggabungan):**
    *   Kami mengambil sampel acak **20.000 baris rating** dari `Books_rating.csv`.
    *   Sampel ini digabungkan dengan `books_data.csv` berdasarkan normalisasi judul buku. Hasilnya adalah file `final_book_data_sample_20k.csv` yang menjadi input awal untuk pipeline kami.

## 4. Struktur Direktori Proyek
```
fp-bugdata/
├── .gitignore
├── README.md
├── docker-compose.yml
├── data/
│ ├── processed/ # Sampel data gabungan siap untuk MinIO
│ │ └── final_book_data_sample_20k.csv
│ └── minio_data/ # Volume mapping MinIO (Bronze, Silver, Gold)
├── src/
│ ├── ingest/
│ │ └── ingest_to_bronze_streaming_batch.py
│ ├── preprocess/
│ │ ├── etl_bronze_to_silver.py
│ │ └── feature_engineering.py
│ ├── training/
│ │ └── train_recommender_models.py
│ ├── api/
│ │ └── app.py
│ ├── ui/ # (Akan diisi oleh Orang 5)
│ │ └── app_ui.py
└── requirements.txt
```


## 5. Penjelasan Tahapan Proyek dan Pembagian Tugas

### Tahap 1: Ingesti Data & Persiapan Bronze Layer (Orang 1)
*   **Tujuan:** Memasukkan data sampel ke dalam sistem penyimpanan awal (MinIO Bronze Layer) dengan mensimulasikan data yang datang secara bertahap.
*   **Proses (Batch Data):**
    1.  **Setup MinIO Server:** MinIO dijalankan menggunakan Docker (dikendalikan via `docker-compose.yml`) untuk menyediakan object storage S3-compatible secara lokal. Bucket `bronze-layer`, `silver-layer`, dan `gold-layer` dibuat.
    2.  **Skrip Ingesti (`src/ingest/ingest_to_bronze_streaming_batch.py`):**
        *   Membaca file `data/processed/final_book_data_sample_20k.csv`.
        *   Memecah dataset 20.000 baris tersebut menjadi 10 batch file CSV, masing-masing berisi 2.000 baris.
        *   Setiap file batch diunggah secara terpisah ke `bronze-layer/streaming_batches/` di MinIO. Ini mensimulasikan data yang masuk secara berkala.
![Screenshot 2025-06-12 194905](https://github.com/user-attachments/assets/f07a2271-09a3-4f8f-899c-37059f116b39)  
![Screenshot 2025-06-12 194927](https://github.com/user-attachments/assets/76eba1ce-6563-408a-a02e-65a4f4fd9e41)  
*   **Output:** 10 file CSV batch di MinIO Bronze Layer.

### Tahap 2: ETL Bronze ke Silver & Feature Engineering ke Gold (Orang 2)
*   **Tujuan:** Membersihkan dan mentransformasi data dari Bronze, menyimpannya ke Silver, lalu membuat fitur yang siap digunakan model dan menyimpannya ke Gold.
*   **Proses Preprocessing (ETL Bronze ke Silver - `src/preprocess/etl_bronze_to_silver.py`):**
    1.  **Extract:** Membaca semua 10 file batch CSV dari `bronze-layer/streaming_batches/` di MinIO.
    2.  **Transform:**
        *   Menggabungkan data dari semua batch menjadi satu DataFrame Pandas.
        *   Melakukan pembersihan dasar: penyesuaian tipe data (numerik, datetime), penanganan nilai kosong (NaN) sederhana (mengisi string kosong), dan normalisasi teks dasar (lowercase, trim whitespace).
    3.  **Load:** Menyimpan DataFrame hasil transformasi ke `silver-layer/` di MinIO sebagai satu file Parquet (`processed_book_data.parquet`) untuk efisiensi.
![Screenshot 2025-06-12 213353](https://github.com/user-attachments/assets/cf5caab8-d6f8-4a79-8db6-97cbe673b041)  

*   **Proses Feature Engineering (Silver ke Gold - `src/preprocess/feature_engineering.py`):**
    1.  **Input:** Membaca `processed_book_data.parquet` dari MinIO Silver Layer.
    2.  **EDA Sederhana:** Melakukan analisis data eksploratif dasar untuk memahami karakteristik data.
    3.  **Fitur Collaborative Filtering (CF):**
        *   Membuat User-Item Interaction Matrix (sparse) dari `User_id`, `Id` (ASIN buku), dan `review/score`.
        *   Menyimpan matriks ini (`user_item_interaction_matrix.npz`) dan mapping ID (`user_id_map.pkl`, `book_id_map_asin.pkl`) ke MinIO Gold Layer (`features/` dan `fitted_objects/`).
    4.  **Fitur Content-Based Filtering (CBF):**
        *   Menggabungkan teks dari `Title_rating`, `description`, `authors`, `categories`.
        *   Membuat matriks TF-IDF dari gabungan teks tersebut.
        *   Menyimpan matriks TF-IDF (`book_content_tfidf_matrix.npz`), objek `TfidfVectorizer` yang sudah di-fit (`tfidf_vectorizer.pkl`), dan daftar ID buku yang sesuai (`book_ids_for_tfidf_matrix.pkl`) ke MinIO Gold Layer.
![Screenshot 2025-06-12 214333](https://github.com/user-attachments/assets/121a70e0-c076-48ce-82df-9bd67a2677ff)  
![Screenshot 2025-06-12 214351](https://github.com/user-attachments/assets/589f6c21-7dd5-4655-85be-bfd1c06afd3a)

*   **Output:** Data bersih di MinIO Silver Layer; fitur-fitur siap model dan objek pendukung di MinIO Gold Layer.

### Tahap 3: Pelatihan Model (Orang 3)
*   **Tujuan:** Menggunakan fitur dari Gold Layer untuk "melatih" atau membuat model/artefak rekomendasi.
*   **Proses Pembuatan Model (`src/training/train_recommender_models.py`):**
    1.  **Input:** Membaca fitur dan objek dari MinIO Gold Layer.
    2.  **Model Collaborative Filtering (Item-Item Similarity):**
        *   Menggunakan `user_item_interaction_matrix.npz`.
        *   Menghitung matriks kemiripan kosinus antar item (buku) berdasarkan pola rating pengguna bersama.
        *   Menyimpan matriks kemiripan item CF (`cf_item_item_similarity_matrix.npz`) dan daftar ID buku yang sesuai (`cf_book_id_map_for_similarity.pkl`) ke `gold-layer/models/`.
    3.  **Model Content-Based Filtering (Book-Book Similarity):**
        *   Menggunakan `book_content_tfidf_matrix.npz`. 
        *   Menghitung matriks kemiripan kosinus antar buku berdasarkan vektor TF-IDF konten mereka.
        *   Menyimpan matriks kemiripan konten CBF (`cbf_book_book_similarity_matrix.pkl`) dan daftar ID buku yang sesuai (`cbf_book_ids_for_similarity.pkl`) ke `gold-layer/models/`.
    4.  **Evaluasi Kualitatif Sederhana:** Melakukan pengecekan dengan mengambil contoh buku dan melihat top-N buku paling mirip yang dihasilkan oleh masing-masing model.
 ![Screenshot 2025-06-12 224951](https://github.com/user-attachments/assets/1c5c6ed6-3efb-437e-aae2-ebd03b000c1d)

*   **Output:** Matriks kemiripan untuk CF dan CBF beserta mapping ID buku yang relevan, tersimpan di MinIO Gold Layer (`models/`).
<!-- 
### Tahap 4: Pengembangan API Backend (Orang 4)
*   **(Sedang Berlangsung/Akan Dilakukan)**
*   **Tujuan:** Membuat layanan API yang dapat diakses untuk mendapatkan rekomendasi.
*   **Proses (`src/api/app.py`):**
    1.  Menggunakan Flask sebagai framework.
    2.  Saat startup, API akan memuat matriks kemiripan, mapping ID, dan data detail buku (dari Silver Layer) dari MinIO ke memori.
    3.  Menyediakan endpoint, misalnya:
        *   `GET /recommend/item-cf?book_asin=<ASIN>&top_n=<JUMLAH>`
        *   `GET /recommend/content-based?book_asin=<ASIN>&top_n=<JUMLAH>`
    4.  Mengembalikan hasil rekomendasi dalam format JSON.
*   **Output:** Server API yang berjalan dan bisa memberikan rekomendasi.

### Tahap 5: Pengembangan UI Frontend & Integrasi (Orang 5)
*   **(Akan Dilakukan)**
*   **Tujuan:** Membuat antarmuka pengguna sederhana agar pengguna bisa berinteraksi dan mendapatkan rekomendasi.
*   **Proses (`src/ui/app_ui.py`):**
    1.  Menggunakan Streamlit.
    2.  Membuat input field bagi pengguna untuk memasukkan ASIN buku referensi.
    3.  Mengirim request ke API backend yang dibuat Orang 4.
    4.  Menampilkan hasil rekomendasi (termasuk judul, penulis, gambar sampul) kepada pengguna.
    5.  Juga bertanggung jawab atas dokumentasi akhir dan integrasi keseluruhan.
*   **Output:** Aplikasi web sederhana yang menampilkan rekomendasi buku.
-->

## 🛠️ Kebutuhan (Requirements)

*   Python 3.9+
*   Docker & Docker Compose
*   Library Python (lihat `requirements.txt`):
    *   `pandas`
    *   `minio`
    *   `numpy`
    *   `scipy`
    *   `scikit-learn`
    *   `pyarrow` (untuk membaca/menulis Parquet)
    *   `Flask` (untuk API)
    *   `Flask-CORS` (untuk API)
    *   `streamlit` (untuk UI)
    *   (Tambahkan library lain jika ada)

## 🚀 Cara Menjalankan Proyek (Secara Keseluruhan)

1.  **Siapkan Dataset Awal:**
    Pastikan file `final_book_data_sample_20k.csv` ada di `data/processed/`. (Jika belum, jalankan skrip/notebook untuk membuatnya dari `data/raw/`).

2.  **Buat dan Aktifkan Virtual Environment:**
    ```bash
    python -m venv venv
    # Windows:
    venv\Scripts\activate
    # macOS/Linux:
    source venv/bin/activate
    ```

3.  **Instal Dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

4.  **Jalankan MinIO Server:**
    ```bash
    docker-compose up -d
    ```
    Verifikasi MinIO Console di `http://localhost:9001` (login: `bigdatafp`/`bigdatafp` atau sesuai `docker-compose.yml`). Pastikan bucket `bronze-layer`, `silver-layer`, `gold-layer` ada.

5.  **Jalankan Pipeline Data dan Pelatihan Model (Secara Berurutan):**
    ```bash
    python src/ingest/ingest_to_bronze_streaming_batch.py
    python src/preprocess/etl_bronze_to_silver.py
    python src/preprocess/feature_engineering.py
    python src/training/train_recommender_models.py
    ```
    Setelah setiap skrip, kamu bisa memeriksa hasilnya di MinIO Console.
<!-- 
7.  **Jalankan API Backend (Orang 4):**
    (Biarkan terminal MinIO tetap berjalan atau jalankan MinIO di background)
    ```bash
    python src/api/app.py
    ```
    API akan berjalan di `http://localhost:5000` (atau port yang dikonfigurasi).

8.  **Jalankan UI Frontend (Orang 5):**
    (Biarkan terminal MinIO dan API tetap berjalan)
    Buka terminal baru, aktifkan `venv`, lalu jalankan:
    ```bash
    streamlit run src/ui/app_ui.py
    ```
    UI akan terbuka di browser, biasanya di `http://localhost:8501`.

9.  **Menghentikan Layanan:**
    *   Untuk API dan UI, tekan `Ctrl+C` di terminal masing-masing.
    *   Untuk MinIO: `docker-compose down`

## 🤝 Kontributor
*   Orang 1 - [Nama Orang 1] - Data Ingest & ETL Awal
*   Orang 2 - [Nama Orang 2] - Feature Engineering & Data Analyst
*   Orang 3 - [Nama Orang 3] - Machine Learning Engineer
*   Orang 4 - [Nama Orang 4] - Backend Developer (API)
*   Orang 5 - [Nama Orang 5] - Frontend Developer (UI) & Project Integrator
-->
