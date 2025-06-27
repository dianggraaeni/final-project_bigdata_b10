# FINAL PROJECT BIG DATA

KELOMPOK : B10

|           Nama               |     NRP    |
|            --                |     --     |
| Riakiyatul Nur Oktarani      | 5027231013 |
| Dian Anggraeni Putri         | 5027231016 |
| Acintya Edria Sudarsono      | 5027231020 |
|Tsaldia Hukma Cita            | 5027231036 |
| Calista Meyra Azizah         | 5027231060 |

![WhatsApp Image 2025-06-24 at 18 13 52_2675b7f9](https://github.com/user-attachments/assets/1537ea8b-0868-455c-99e6-380b165d9a99)


## 1. Pendahuluan: Permasalahan Nyata di Dunia Literasi Digital
Era digital telah membuka akses tak terbatas terhadap jutaan judul buku. Namun, kelimpahan ini justru menghadirkan tantangan baru: pembaca seringkali kesulitan menemukan buku yang benar-benar sesuai minat di tengah lautan pilihan (information overload). Rekomendasi yang ada cenderung generik, membatasi penemuan karya baru atau "permata tersembunyi", dan kurang personal. Hal ini tidak hanya mempengaruhi kepuasan pembaca tetapi juga visibilitas penulis dan penerbit independen, serta mengurangi keterlibatan pengguna pada platform buku.

## 2. Solusi yang Ditawarkan: Sistem Rekomendasi Buku Cerdas
Untuk menjawab tantangan dalam menemukan bacaan yang relevan di era digital, proyek mengembangkan prototipe sistem rekomendasi buku yang lebih personal dan cerdas. Solusi kami berfokus pada pemahaman mendalam terhadap preferensi pengguna dan esensi konten buku. Dengan menganalisis histori interaksi pengguna (seperti rating) serta memanfaatkan metadata buku (judul, penulis, deskripsi, dan genre), kami mengimplementasikan model rekomendasi yang efektif, menggabungkan pendekatan Collaborative Filtering (berdasarkan kemiripan pola rating antar buku) dan Content-Based Filtering (berdasarkan kemiripan konten buku).

Seluruh proses ini didukung oleh arsitektur Data Lakehouse sederhana menggunakan MinIO sebagai object storage, yang mengelola data secara fleksibel mulai dari ingesti data sampel secara batch, pemrosesan, hingga penyimpanan fitur dan model siap pakai. Hasil rekomendasi dari sistem ini kemudian akan disajikan melalui sebuah API backend, yang memungkinkan integrasi mudah dengan antarmuka pengguna dan aplikasi lainnya. Fokus utama proyek ini adalah membangun pipeline data dan model rekomendasi inti yang fungsional sebagai dasar pengembangan lebih lanjut.

## 3. Dataset yang Digunakan

*   **Nama Dataset:** Amazon Books Reviews
*   **Sumber (Kaggle):** [https://www.kaggle.com/datasets/mohamedbakhet/amazon-books-reviews](https://www.kaggle.com/datasets/mohamedbakhet/amazon-books-reviews)
*   **File yang Digunakan:**
    1.  `Books_rating.csv`: Mengandung data rating, User ID, ID Buku (ASIN), timestamp, dan teks review.
    2.  `books_data.csv`: Mengandung metadata buku seperti judul, penulis, deskripsi, kategori, dll.
*   **Pengolahan Awal (Sampling & Penggabungan):**
    *   Kami mengambil sampel acak **50.000 baris rating** dari `Books_rating.csv`.
    *   Sampel ini digabungkan dengan `books_data.csv` berdasarkan normalisasi judul buku. Hasilnya adalah file `final_book_data_sample_50k.csv` yang menjadi input awal untuk pipeline kami.

## 4. Struktur Direktori Proyek
```
final-project-data-lakehouse/
├── .git/
├── .gitignore
├── docker-compose.yml
├── start_project.sh # (Contoh script utama untuk orkestrasi semua)
├── start_infra_ingestion.sh # Script untuk Orang 1
├── process_data_pipeline.sh # Script untuk Orang 2
├── train_model_pipeline.sh # Script untuk Orang 3
├── start_api_streamlit.sh # Script untuk Orang 4 (dev lokal)
│
├── data/
│ └── raw/
│ ├── books_dataset.csv
│ └── unstructured/
│ |  ├── images/
│ |  ├── videos/
│ |  └── audios/
│
├── src/
│ ├── init.py
│ ├── ingestion/
│ │ ├── init.py
│ │ ├── kafka_producer_csv.py
│ │ ├── kafka_producer_unstructured.py
│ │ ├── kafka_consumer_csv_to_minio.py
│ │ └── kafka_consumer_unstructured_metadata.py
│ ├── processing/
│ │ ├── init.py
│ │ ├── run_data_processing.py
│ │ ├── data_preprocessor.py
│ │ ├── feature_engineering_price.py
│ │ └── feature_engineering_recsys.py
│ ├── training/
│ │ ├── init.py
│ │ └── train_price_predictor.py
│ ├── api/
│ │ ├── init.py
│ │ ├── main.py
│ │ ├── schemas.py
│ │ └── services/
│ │ ├── init.py
│ │ ├── prediction_service.py
│ │ └── recommendation_service.py
│ ├── streamlit_app/
│ │ └── app.py
│ └── utils/
│ ├── init.py
│ ├── config.py
│ └── minio_helpers.py
│
├── frontend_web/
│ ├── index.html
│ ├── css/
│ └── js/
│
├── models_local_backup/ # Backup model lokal dari training
│
├── Dockerfile.api # Dockerfile untuk API service (Orang 4/5)
├── Dockerfile.streamlit # Dockerfile untuk Streamlit app (Orang 4/5)
│
├── requirements.txt
└── README.md
```

---

## 2. Penjelasan File & Folder Utama

*   **`docker-compose.yml`**: Mendefinisikan dan menjalankan service infrastruktur (Kafka, Zookeeper, MinIO) dan nantinya aplikasi (API, Streamlit) menggunakan Docker.
*   **`start_*.sh`**: Kumpulan script Bash untuk menjalankan pipeline per tahap atau keseluruhan.
*   **`data/raw/`**: Menyimpan dataset mentah lokal sebelum di-stream.
    *   `books_dataset.csv`: Dataset utama buku.
    *   `unstructured/`: Sampel file gambar, video, audio.
*   **`src/`**: Berisi semua kode sumber Python aplikasi.
    *   **`ingestion/`**: Modul untuk data ingestion (Kafka producers & consumers).
    *   **`processing/`**: Modul untuk pemrosesan data, pembersihan, dan feature engineering. `run_data_processing.py` adalah entry point untuk tahap ini.
    *   **`training/`**: Modul untuk melatih model machine learning. `train_price_predictor.py` adalah entry point.
    *   **`api/`**: Kode untuk REST API service menggunakan FastAPI.
        *   `main.py`: Aplikasi FastAPI utama, event startup, dan pendaftaran router (jika digunakan).
        *   `schemas.py`: Model data Pydantic untuk validasi dan dokumentasi API.
        *   `services/`: Logika bisnis inti (prediksi, rekomendasi) yang dipisahkan dari endpoint.
    *   **`streamlit_app/`**: Kode untuk aplikasi UI sederhana menggunakan Streamlit. `app.py` adalah script utama.
    *   **`utils/`**: Modul utilitas umum.
        *   `config.py`: Menyimpan konfigurasi (nama bucket, file, dll.).
        *   `minio_helpers.py`: Fungsi bantu untuk interaksi dengan MinIO.
*   **`frontend_web/`**: (Untuk Orang 5) Kode sumber untuk antarmuka pengguna web yang lebih canggih.
*   **`models_local_backup/`**: Tempat menyimpan salinan lokal dari model machine learning yang sudah dilatih.
*   **`Dockerfile.api`, `Dockerfile.streamlit`**: (Untuk Orang 4/5) Instruksi untuk membangun image Docker untuk API dan aplikasi Streamlit.
*   **`requirements.txt`**: Daftar semua library Python yang dibutuhkan oleh proyek.
*   **`README.md`**: File ini. Dokumentasi utama proyek.

---

## 3. Teknologi yang Digunakan

*   **Bahasa Pemrograman Utama:** Python
*   **Containerization:** Docker, Docker Compose
*   **Streaming Data:** Apache Kafka
*   **Data Lake Storage:** MinIO
*   **Data Processing & ML:** Pandas, NumPy, Scikit-learn, Randomforest, NLTK
*   **API Framework:** FastAPI
*   **ASGI Server (untuk FastAPI):** Uvicorn
*   **Simple Web UI:** Streamlit

---

## 4. Alur Kerja & Pembagian Tugas Tim

### Orang 1: Infrastruktur Dasar & Ingestion Data Awal
*   **Tugas:**
    1.  Setup `docker-compose.yml` untuk Kafka, Zookeeper, MinIO.
    2.  Membuat Kafka Producer (`kafka_producer_csv.py`) untuk membaca data CSV lokal dan mengirimkannya ke topic Kafka.
    3.  Membuat Kafka Producer (`kafka_producer_unstructured.py`) untuk mengunggah file unstructured ke MinIO dan mengirim metadatanya ke topic Kafka.
    4.  Membuat Kafka Consumer (`kafka_consumer_csv_to_minio.py`) untuk membaca data CSV dari Kafka dan menyimpannya ke bucket "raw data" di MinIO.
    5.  Membuat Kafka Consumer (`kafka_consumer_unstructured_metadata.py`) untuk membaca metadata unstructured dari Kafka (misalnya, untuk logging).
*   **Output:**
    *   Infrastruktur Docker berjalan.
    *   Data CSV mentah tersimpan di MinIO.
    *   File unstructured tersimpan di MinIO dan metadatanya ter-log.
*   **Script Utama:** `start_infra_ingestion.sh`
*   **Dokumentasi**  
![image](https://github.com/user-attachments/assets/410b9af7-e5cf-4141-aae0-949da70b25ba)
![WhatsApp Image 2025-06-27 at 16 14 42_766d6481](https://github.com/user-attachments/assets/6d2684b5-8481-4ba3-b82d-bc4cd3e6a1c0)




### Orang 2: Data Processing & Feature Engineering
*   **Tugas:**
    1.  Memuat data CSV mentah dari MinIO (output Orang 1).
    2.  Melakukan Exploratory Data Analysis (EDA).
    3.  Melakukan preprocessing data (`data_preprocessor.py`): pembersihan, handling missing values dengan menghapus baris data yang memiliki nilai null, parsing tipe data (termasuk `authors_list`, `categories_list` menjadi list Python, `Id_rating` menjadi string), text cleaning (`description_cleaned`).
    4.  Melakukan feature engineering (`feature_engineering_price.py`): membuat fitur baru (misal, `publish_year`, `num_authors`, `num_categories`), melakukan One-Hot Encoding untuk kategori.
    5.  Membuat dan menyimpan model TF-IDF (`feature_engineering_recsys.py`) dari `description_cleaned` ke MinIO.
    6.  Menyimpan DataFrame akhir yang komprehensif (berisi semua kolom asli yang relevan + fitur baru + fitur OHE) sebagai file Parquet (`price_prediction_features.parquet`) ke bucket "processed data" di MinIO.
*   **Output:**
    *   `processed-book-data/price_prediction_features.parquet` di MinIO.
    *   `ml-models/tfidf_vectorizer.joblib` di MinIO.
*   **Script Utama:** `process_data_pipeline.sh` (memanggil `src/processing/run_data_processing.py`)
*   **Dokumentasi**   
![image](https://github.com/user-attachments/assets/bb7294da-fdd6-4769-967f-99f63d2f4038)
![image](https://github.com/user-attachments/assets/e78822e8-6cd4-485b-a9ba-9f3f7ce27d21)



### Orang 3: Model Training (Prediksi Harga)
*   **Tugas:**
    1.  Memuat `price_prediction_features.parquet` (output Orang 2) dari MinIO.
    2.  Memilih fitur (X) yang relevan (numerik dan OHE) dan target (y=`Price_rating`).
    3.  Melatih model prediksi harga (dipilih Random Forest setelah eksperimen dengan XGBoost).
    4.  Melakukan hyperparameter tuning (menggunakan `GridSearchCV`).
    5.  Mengevaluasi performa model terbaik.
    6.  Menyimpan model terlatih (`price_predictor_rf_focused_tuned.joblib`) dan metadatanya (termasuk `feature_names_ordered`, parameter, metrik evaluasi) ke bucket "ml-models" di MinIO dan ke `models_local_backup/`.
*   **Output:**
    *   `ml-models/price_predictor_rf_focused_tuned.joblib` di MinIO.
    *   `ml-models/price_predictor_rf_focused_tuned_metadata.json` di MinIO.
    *   Salinan di `models_local_backup/`.
    *   Notebook eksperimen model.
*   **Script Utama:** `train_model_pipeline.sh` (memanggil `src/training/train_price_predictor.py`)
*   **Dokumentasi**  
![image](https://github.com/user-attachments/assets/463ca35b-4d16-4e1f-9641-ae5aaf7e55fb)
![WhatsApp Image 2025-06-27 at 16 14 43_c7ba115a](https://github.com/user-attachments/assets/bb649346-2c1a-46fa-9176-0373eb0837e2)



### Orang 4: Pengembangan API Endpoint (Backend)
*   **Tugas Utama:** Membangun backend API service yang akan melayani request dari frontend.
*   **Detail Pekerjaan:**
    1.  Mengembangkan API Service menggunakan FastAPI di `src/api/`.
    2.  Mengimplementasikan logika startup API (`@app.on_event("startup")` di `main.py`) untuk memuat semua artefak yang dibutuhkan dari MinIO:
        *   Model prediksi harga dan metadatanya.
        *   Model TF-IDF vectorizer.
        *   Data buku komprehensif (`price_prediction_features.parquet`) untuk layanan rekomendasi.
    3.  Menginisialisasi service layer (`prediction_service.py`, `recommendation_service.py`) dengan artefak yang sudah dimuat.
    4.  Mendefinisikan skema data Pydantic (`schemas.py`) untuk validasi request dan response API.
    5.  Membuat endpoint-endpoint RESTful berikut (di `main.py`):
        *   `GET /health`: Cek status API.
        *   `POST /predict/price`: Menerima fitur buku, mengembalikan prediksi harga.
        *   `GET /books`: Mengembalikan daftar buku umum (dengan paginasi dan pencarian).
        *   `GET /books/{book_id}`: Mengembalikan detail lengkap satu buku (termasuk prediksi harga internal, deskripsi asli, URL gambar, genre, dll.).
        *   `GET /books/{book_id}/recommendations/initial`: Mengembalikan teaser rekomendasi yang dikategorikan (by author, genre, content, year range).
        *   `GET /recommendations/by_author`, `/recommendations/by_genre`, `/recommendations/similar_to/{book_id}`, `/recommendations/by_year_range`: Mengembalikan daftar lengkap rekomendasi dengan paginasi.
    6.  Mengimplementasikan error handling dan logging dasar di API.
*   **Output Utama:**
    *   API service yang berjalan dan dapat diuji (misalnya dengan Postman dan Swagger UI).
    *   Dokumentasi API otomatis dari FastAPI.  
![image](https://github.com/user-attachments/assets/75c444e3-9b39-481b-8135-4d1a4d42fb43)  

*   **Script Pendukung (Development Lokal):** Sebagian dari `start_api_streamlit.sh` atau perintah `uvicorn src.api.main:app --reload`.

### Orang 5: Pengembangan Antarmuka Pengguna (Frontend Streamlit & Web Lanjutan)
*   **Tugas Utama:** Membangun antarmuka pengguna (UI) yang interaktif untuk pengguna akhir.
*   **Detail Pekerjaan:**
    1.  **Pengembangan UI Streamlit Sederhana (`src/streamlit_app/app.py`):**
        *   Membuat aplikasi web interaktif dasar menggunakan Streamlit.
        *   Halaman Home: Menampilkan daftar buku (dari `GET /books`), fitur pencarian, dan informasi total buku (dari `GET /statistics/overview` atau `/books`).
        *   Halaman Detail Buku: Menampilkan informasi lengkap buku (dari `GET /books/{book_id}`), termasuk gambar, deskripsi asli, genre (sebagai tag), prediksi harga, dan teaser rekomendasi (dari `GET /books/{book_id}/recommendations/initial`).
        *   Halaman Daftar Rekomendasi Detail: Menampilkan daftar buku yang lebih panjang saat pengguna mengklik "Lihat Semua" dari teaser (memanggil endpoint `/recommendations/by_...` yang sesuai), lengkap dengan paginasi.
        *   Halaman Prediktor Harga: Form untuk input manual fitur buku dan menampilkan prediksi harga (memanggil `POST /predict/price`).
        *   Halaman Visualisasi Data: Menampilkan grafik-grafik (distribusi genre, tahun terbit, performa model) dengan data dari endpoint statistik API atau data evaluasi yang dimuat dari MinIO.
        *   Semua interaksi UI melakukan panggilan ke endpoint API yang dibuat oleh Orang 4.
    2.  **(Stretch Goal/Pengembangan Lanjutan) Frontend Web Interaktif (`frontend_web/`):**
        *   Merancang dan mengembangkan antarmuka pengguna web yang lebih canggih menggunakan HTML, CSS, JavaScript, dan mungkin framework frontend (React, Vue, Angular) jika ada keahlian dan waktu.
        *   Mengintegrasikan frontend ini dengan API.
*   **Output Utama:**
    *   Aplikasi Streamlit yang fungsional dan interaktif.
    *   (Jika dikerjakan) Aplikasi frontend web yang lebih canggih.  
 ![Screenshot 2025-06-19 083429](https://github.com/user-attachments/assets/f7f3d40d-007d-4e61-8117-57c10d745eab)
![WhatsApp Image 2025-06-27 at 16 14 43_bfe97d7b](https://github.com/user-attachments/assets/26c287ed-4f8b-44cc-b314-db2c8f8490e8)
![WhatsApp Image 2025-06-27 at 16 14 43_a605b7e6](https://github.com/user-attachments/assets/e015321f-ca36-4479-9106-af51d036192c)  


---

## 5. Cara Menjalankan Proyek

### Prasyarat
*   Docker Desktop terinstal dan **sedang berjalan**.
*   Python 3 (misalnya, 3.9+) terinstal.
*   Git terinstal.
*   Postman atau alat serupa untuk menguji API

### Langkah-Langkah Setup Awal (Hanya Dilakukan Sekali)
1.  **Clone Repository (jika dari GitHub):**
    ```bash
    git clone <url_repository_github>
    cd final-project-data-lakehouse 
    ```
    Atau jika sudah punya folder proyek, cukup `cd` ke sana:
    ```bash
    cd path/to/your/final-project-data-lakehouse
    ```
2.  **Buat dan Aktifkan Virtual Environment (gunakan Git Bash atau terminal serupa):**
    ```bash
    python -m venv venv
    source venv/Scripts/activate  # Untuk Windows Git Bash
    # source venv/bin/activate    # Untuk Linux/macOS
    ```
    Pastikan prompt terminal berubah menjadi `(venv) ...`.
3.  **Install Dependensi Python:**
    ```bash
    pip install -r requirements.txt
    ```
4.  **Beri Izin Eksekusi pada Script Bash (jika di Linux/macOS atau Git Bash):**
    ```bash
    chmod +x run_all_pipelines.sh
    ```

### Menjalankan Komponen Proyek

**Opsi 1: Menjalankan Semua Secara Otomatis dengan Script Utama (Jika `start_project.sh` sudah dibuat untuk orkestrasi penuh)**

1.  Pastikan Docker Desktop berjalan.
2.  Aktifkan venv: `source venv/Scripts/activate`
3.  Jalankan script utama:
    ```bash
    ./run_all_pipelines.sh
    ```
    Script ini akan mencoba menjalankan `docker-compose up`, lalu pipeline Orang 1, 2, 3, dan akhirnya API serta Streamlit.
---
