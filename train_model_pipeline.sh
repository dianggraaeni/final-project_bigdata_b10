#!/bin/bash

# Warna untuk output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Memulai Model Training Pipeline (RandomForest - Focused Tuning)...${NC}"
echo "Pastikan MinIO service sudah berjalan."
echo "Pastikan data olahan ('${PROCESSED_PRICE_FEATURES_FILE:-price_prediction_features.parquet}') sudah ada di MinIO bucket '${MINIO_PROCESSED_DATA_BUCKET:-processed-book-data}'."
echo "--------------------------------------------------------------------"

# --- Langkah 1: Memastikan bucket MinIO untuk model ada ---
echo -e "${YELLOW}[LANGKAH 1] Memastikan bucket MinIO untuk model ada...${NC}"
python src/utils/minio_helpers.py # Ini akan memastikan semua bucket, termasuk ml-models, dibuat
if [ $? -ne 0 ]; then
    echo -e "${RED}Gagal melakukan setup MinIO. Cek output minio_helpers.py.${NC}"
    # Pertimbangkan untuk keluar jika ini kritis
    # exit 1
fi
echo -e "${GREEN}Pengecekan bucket MinIO selesai.${NC}"


# --- Langkah 2: Menjalankan script utama training model ---
echo -e "${YELLOW}[LANGKAH 2] Menjalankan script training model prediksi harga (RandomForest - Focused Tuning)...${NC}"
# Menjalankan script Python yang berisi logika Random Forest Focused Tuning
# Asumsi logika tersebut ada di src/training/train_price_predictor.py
python -m src.training.train_price_predictor

if [ $? -ne 0 ]; then
    echo -e "${RED}Gagal menjalankan model training pipeline. Silakan cek error di atas.${NC}"
    exit 1
fi

echo "--------------------------------------------------------------------"
echo -e "${GREEN}Model Training Pipeline (RandomForest - Focused Tuning) selesai.${NC}"
echo "Model prediksi harga dan metadatanya seharusnya sudah ada di MinIO bucket '${MINIO_MODELS_BUCKET:-ml-models}'."
# Sesuaikan pesan ini dengan nama file yang benar dari config atau definisi di script Python
echo "Periksa file model (misal, 'price_predictor_rf_focused_tuned.joblib') dan metadatanya."
echo "--------------------------------------------------------------------"