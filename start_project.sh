#!/bin/bash

# Warna untuk output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Memulai Proyek Data Lakehouse - Tahap Infrastruktur & Ingestion...${NC}"
echo "Pastikan Docker sudah berjalan."
echo "--------------------------------------------------------------------"

# --- Langkah 1 & 2 (Docker & MinIO Setup) tetap sama ---
echo -e "${YELLOW}[LANGKAH 1] Membangun dan menjalankan service Docker (Kafka, MinIO)...${NC}"
docker-compose up -d --build
# ... (error check dan sleep tetap sama) ...
echo -e "${YELLOW}[LANGKAH 2] Melakukan setup awal di MinIO ...${NC}"
python src/utils/minio_helpers.py
# ... (error check tetap sama) ...

# --- Langkah 3: Menjalankan Kafka Producer untuk data CSV ---
echo -e "${YELLOW}[LANGKAH 3] Menjalankan Kafka Producer untuk data CSV...${NC}"
python src/ingestion/kafka_producer_csv.py
# ... (error check tetap sama) ...
echo -e "${GREEN}Kafka Producer CSV selesai mengirim data.${NC}"

# --- Langkah 4: Menjalankan Kafka Consumer CSV ke MinIO ---
echo -e "${YELLOW}[LANGKAH 4] Menjalankan Kafka Consumer CSV ke MinIO (DI FOREGROUND UNTUK DEBUG)...${NC}"
# HAPUS '&' agar berjalan di foreground dan kita lihat outputnya sampai selesai
python src/ingestion/kafka_consumer_csv_to_minio.py
# CONSUMER_CSV_PID=$! # Tidak perlu PID jika di foreground
if [ $? -ne 0 ]; then
    echo -e "${RED}Kafka Consumer CSV mengalami error. Cek outputnya.${NC}"
fi
echo -e "${GREEN}Kafka Consumer CSV SELESAI (atau timeout). Melanjutkan ke Unstructured Data...${NC}" # Pesan baru

# Beri jeda sedikit
sleep 2
echo "======================================================"
echo "MEMULAI PROSES DATA UNSTRUCTURED"
echo "======================================================"

# --- Langkah 5: Menjalankan Kafka Producer untuk data Unstructured ---
echo -e "${YELLOW}[LANGKAH 5] Menjalankan Kafka Producer untuk data Unstructured...${NC}"
python src/ingestion/kafka_producer_unstructured.py
if [ $? -ne 0 ]; then
    echo -e "${RED}Gagal menjalankan Kafka Producer Unstructured.${NC}"
fi
echo -e "${GREEN}Kafka Producer Unstructured selesai mengirim metadata (jika ada file).${NC}"

# --- Langkah 6: Menjalankan Kafka Consumer untuk Metadata Unstructured ---
echo -e "${YELLOW}[LANGKAH 6] Menjalankan Kafka Consumer untuk Metadata Unstructured (Logger)...${NC}"
python src/ingestion/kafka_consumer_unstructured_metadata.py
if [ $? -ne 0 ]; then
    echo -e "${RED}Kafka Consumer Metadata Unstructured mengalami error.${NC}"
fi
echo -e "${GREEN}Kafka Consumer Metadata Unstructured selesai atau timeout.${NC}"


echo "--------------------------------------------------------------------"
echo -e "${GREEN}Semua proses Ingestion (CSV & Unstructured) telah dijalankan.${NC}"
# ... (pesan akhir tetap sama, kecuali bagian PID) ...
echo -e "Untuk menghentikan semua service Docker, jalankan: ${YELLOW}docker-compose down${NC}"
echo "--------------------------------------------------------------------"