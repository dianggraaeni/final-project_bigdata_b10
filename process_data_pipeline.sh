#!/bin/bash

# Warna untuk output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Memulai Data Processing Pipeline (Orang 2)...${NC}"
echo "Pastikan MinIO service sudah berjalan (dari docker-compose Orang 1)."
echo "Pastikan data mentah CSV sudah ada di MinIO bucket '${MINIO_RAW_CSV_BUCKET:-raw-book-csv-data}'."
echo "--------------------------------------------------------------------"

# --- Langkah 1: (Opsional) Memastikan bucket output ada ---
# Script Python utama juga akan melakukan ini, tapi bisa juga di sini
echo -e "${YELLOW}[LANGKAH 1] Memastikan bucket MinIO untuk data olahan dan model ada...${NC}"
# Jalankan script minio_helpers.py untuk membuat semua bucket jika belum ada
python src/utils/minio_helpers.py
if [ $? -ne 0 ]; then
    echo -e "${RED}Gagal melakukan setup MinIO. Cek output minio_helpers.py.${NC}"
    # Pertimbangkan untuk keluar jika ini kritis
    # exit 1
fi
echo -e "${GREEN}Pengecekan bucket MinIO selesai.${NC}"

# --- Langkah 2: Menjalankan script utama data processing ---
echo -e "${YELLOW}[LANGKAH 2] Menjalankan script data processing, feature engineering, dan TF-IDF...${NC}"
# Cara menjalankan agar import package bekerja dengan baik dari root proyek:
python -m src.processing.run_data_processing
# Atau jika kamu berada di dalam direktori src/processing/ : python run_data_processing.py
# Atau jika kamu sudah mengatur PYTHONPATH : python src/processing/run_data_processing.py

if [ $? -ne 0 ]; then
    echo -e "${RED}Gagal menjalankan data processing pipeline. Silakan cek error di atas.${NC}"
    exit 1
fi

echo "--------------------------------------------------------------------"
echo -e "${GREEN}Data Processing Pipeline (Orang 2) selesai.${NC}"
echo "Data olahan seharusnya sudah ada di MinIO bucket '${MINIO_PROCESSED_DATA_BUCKET:-processed-book-data}'."
echo "Model TF-IDF seharusnya sudah ada di MinIO bucket '${MINIO_MODELS_BUCKET:-ml-models}'."
echo "--------------------------------------------------------------------"