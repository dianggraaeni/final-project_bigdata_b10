    #!/bin/bash

# Warna untuk output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${GREEN}Memulai API Service dan Aplikasi Streamlit (Orang 4)...${NC}"
echo "Pastikan service Docker (MinIO, Kafka, Zookeeper) sudah berjalan."
echo "Pastikan virtual environment (venv) sudah diaktifkan di terminal tempat script ini dijalankan."
echo "--------------------------------------------------------------------"

# --- Variabel Port (bisa diubah jika perlu) ---
API_HOST="0.0.0.0"
API_PORT="8000"
STREAMLIT_PORT="8501"

# --- Fungsi untuk membersihkan proses saat script dihentikan (Ctrl+C) ---
cleanup() {
    echo -e "\n${YELLOW}Menghentikan API dan Streamlit...${NC}"
    # Hentikan proses Uvicorn (API) jika ada PID-nya
    if [ ! -z "$UVICORN_PID" ]; then
        echo "Menghentikan Uvicorn (PID: $UVICORN_PID)..."
        kill $UVICORN_PID
    fi
    # Hentikan proses Streamlit jika ada PID-nya
    if [ ! -z "$STREAMLIT_PID" ]; then
        echo "Menghentikan Streamlit (PID: $STREAMLIT_PID)..."
        kill $STREAMLIT_PID
    fi
    echo -e "${GREEN}Semua proses telah dihentikan.${NC}"
    exit 0
}   

# Trap sinyal SIGINT (Ctrl+C) dan panggil fungsi cleanup
trap cleanup SIGINT

# --- Langkah 1: Menjalankan API Service (FastAPI dengan Uvicorn) ---
echo -e "${YELLOW}[LANGKAH 1] Menjalankan API Service (Uvicorn untuk FastAPI)...${NC}"
echo -e "API akan berjalan di ${CYAN}http://${API_HOST}:${API_PORT}${NC}"
echo -e "Dokumentasi API (Swagger UI) akan tersedia di ${CYAN}http://${API_HOST}:${API_PORT}/docs${NC}"

# Jalankan Uvicorn di background dan simpan PID-nya
uvicorn src.api.main:app --host ${API_HOST} --port ${API_PORT} --reload &
UVICORN_PID=$!
echo -e "${GREEN}API Service berjalan di background (PID: $UVICORN_PID).${NC}"

# Beri sedikit waktu agar API benar-benar siap
sleep 5 

# --- Langkah 2: Menjalankan Aplikasi Streamlit ---
echo -e "\n${YELLOW}[LANGKAH 2] Menjalankan Aplikasi Streamlit...${NC}"
echo -e "Streamlit akan mencoba membuka browser secara otomatis."
echo -e "Akses Streamlit di ${CYAN}http://localhost:${STREAMLIT_PORT}${NC}" # Streamlit biasanya listen di localhost

# Jalankan Streamlit di background dan simpan PID-nya
streamlit run src/streamlit_app/app.py --server.port ${STREAMLIT_PORT} --server.headless true &
STREAMLIT_PID=$!
# --server.headless true mencegah Streamlit mencoba membuka tab browser baru jika sudah ada yang terbuka
# atau jika dijalankan di environment tanpa GUI.
echo -e "${GREEN}Aplikasi Streamlit berjalan di background (PID: $STREAMLIT_PID).${NC}"


echo "--------------------------------------------------------------------"
echo -e "${GREEN}API dan Streamlit sedang berjalan.${NC}"
echo -e "${YELLOW}Tekan Ctrl+C untuk menghentikan kedua proses.${NC}"
echo "--------------------------------------------------------------------"

# Jaga agar script bash tetap berjalan agar proses background tidak langsung mati
# dan agar trap Ctrl+C bisa berfungsi.
# Loop ini akan menunggu sampai ada interupsi.
wait $UVICORN_PID
wait $STREAMLIT_PID
# Jika salah satu proses (Uvicorn atau Streamlit) dihentikan manual (bukan via Ctrl+C di script ini),
# script ini mungkin akan keluar. Fungsi cleanup akan tetap mencoba mematikan yang lain.