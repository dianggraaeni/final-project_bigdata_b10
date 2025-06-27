import pandas as pd
import json
import io
from minio import Minio
from minio.error import S3Error # Import S3Error
import numpy as np

# --- Konfigurasi MinIO dan Nama File/Bucket ---
MINIO_ENDPOINT = 'localhost:9000'
MINIO_ACCESS_KEY = 'fpbigdata10'
MINIO_SECRET_KEY = 'fpbigdata10'

MINIO_PROCESSED_DATA_BUCKET = 'processed-book-data'
PROCESSED_FEATURES_PARQUET_FILE = 'price_prediction_features.parquet'

MINIO_MODELS_BUCKET = 'ml-models'
PRICE_MODEL_METADATA_FILE = 'price_predictor_rf_focused_tuned_metadata.json'

minio_client = None # Inisialisasi di luar try
try:
    minio_client = Minio(
        MINIO_ENDPOINT,
        access_key=MINIO_ACCESS_KEY,
        secret_key=MINIO_SECRET_KEY,
        secure=False
    )
    minio_client.list_buckets() 
    print("Berhasil terhubung ke MinIO.")
except Exception as e:
    print(f"Gagal terhubung ke MinIO: {e}")
    print("Pastikan MinIO service berjalan dan kredensial benar.")
    exit()

# --- 1. Cek File Parquet dari Orang 2 ---
print(f"\n--- Mengecek File Parquet: {MINIO_PROCESSED_DATA_BUCKET}/{PROCESSED_FEATURES_PARQUET_FILE} ---")
df_features = None
parquet_columns = []
try:
    response = minio_client.get_object(MINIO_PROCESSED_DATA_BUCKET, PROCESSED_FEATURES_PARQUET_FILE)
    parquet_content = response.read()
    df_features = pd.read_parquet(io.BytesIO(parquet_content))
    print(f"Berhasil memuat DataFrame fitur. Bentuk: {df_features.shape}")
    print("\nContoh 5 baris pertama dari DataFrame fitur (ringkasan):")
    print(df_features.head())
    print("\nInformasi DataFrame fitur (tipe data, null count per kolom):") # Diubah agar lebih informatif
    df_features.info(verbose=True, show_counts=True) # Menampilkan null count
    
    print("\nNama semua kolom di DataFrame fitur:")
    parquet_columns = df_features.columns.tolist()
    print(parquet_columns)
    
    print("\n--- Detail Pengecekan Kolom untuk Rekomendasi & Detail ---")
    cols_to_check_recsys = ['Id_rating', 'Title_norm', 'Title_bookdata', 
                            'authors_list', 'categories_list', 
                            'description_bookdata', 'description_cleaned', 'image_bookdata']
    for col_name in cols_to_check_recsys:
        if col_name in df_features.columns:
            print(f"\nKolom '{col_name}':")
            print(f"  Tipe Data Pandas: {df_features[col_name].dtype}")
            print(f"  Jumlah nilai null: {df_features[col_name].isnull().sum()}")
            print(f"  Contoh 5 nilai pertama: {df_features[col_name].head().tolist()}")
            if col_name in ['authors_list', 'categories_list']:
                print(f"  --- Detail untuk kolom list: {col_name} ---")
                for i in range(min(5, len(df_features))): # Loop 5 baris pertama
                    list_val = df_features[col_name].iloc[i]
                    print(f"    Baris {i}: Tipe: {type(list_val)}, Isi: {list_val}")
                    if isinstance(list_val, (list, np.ndarray)) and len(list_val) > 0:
                        print(f"      Tipe elemen pertama: {type(list_val[0])}")
                sample_list_items = df_features[col_name].dropna().head()
                if not sample_list_items.empty:
                    # Coba akses elemen pertama dari list pertama yang tidak kosong
                    first_valid_list = None
                    for item_list in sample_list_items:
                        if isinstance(item_list, list) and item_list: # Pastikan list dan tidak kosong
                            first_valid_list = item_list
                            break
                    
                    if first_valid_list:
                        print(f"  Tipe elemen list pertama (dari sampel valid pertama): {type(first_valid_list)}")
                        print(f"    Tipe item pertama di dalam list tersebut: {type(first_valid_list[0])}")
                    else:
                        # Cek apakah semua sampel adalah list kosong
                        all_empty_lists = all(isinstance(item_list, list) and not item_list for item_list in sample_list_items)
                        if all_empty_lists:
                             print(f"  Semua sampel untuk '{col_name}' adalah list kosong.")
                        else:
                             print(f"  Tidak ditemukan sampel list yang valid dan tidak kosong untuk dicek tipe elemen dalamnya di '{col_name}'. Mungkin berisi NaN atau bukan list.")
                else:
                    print(f"  Tidak ada sampel non-null untuk '{col_name}' atau semua sampel adalah list kosong.")
        else:
            print(f"❌ PENTING: Kolom '{col_name}' TIDAK DITEMUKAN di Parquet!")
            
except Exception as e:
    print(f"Gagal memuat atau memproses file Parquet: {e}")

# --- 2. Cek File Metadata Model dari Orang 3 ---
print(f"\n--- Mengecek File Metadata Model: {MINIO_MODELS_BUCKET}/{PRICE_MODEL_METADATA_FILE} ---")
model_metadata = None
model_feature_names = []
try:
    response_meta = minio_client.get_object(MINIO_MODELS_BUCKET, PRICE_MODEL_METADATA_FILE)
    metadata_bytes = response_meta.read()
    model_metadata = json.loads(metadata_bytes.decode('utf-8'))
    print("Berhasil memuat metadata model.")
    
    if "feature_names_ordered" in model_metadata:
        model_feature_names = model_metadata["feature_names_ordered"]
        print(f"\nNama fitur yang diharapkan oleh model (dari metadata, {len(model_feature_names)} fitur):")
        # --- PERBAIKAN PRINT ---
        print(f"{model_feature_names[:10]}{'...' if len(model_feature_names) > 10 else ''}")
        # -----------------------
    else:
        print("ERROR: 'feature_names_ordered' tidak ditemukan di metadata model!")
        
except Exception as e:
    print(f"Gagal memuat atau memproses file metadata model: {e}")

# --- 3. Verifikasi Kesesuaian Kolom ---
print("\n--- Verifikasi Kesesuaian Kolom ---")
# ... (sisa kode verifikasi sama seperti sebelumnya, sudah baik) ...
if df_features is not None and model_feature_names:
    recsys_core_cols = ['Id_rating', 'Title_norm', 'authors_list', 'categories_list', 'description_cleaned', 'description_bookdata', 'image_bookdata', 'Title_bookdata']
    missing_in_parquet_for_recsys = [col for col in recsys_core_cols if col not in parquet_columns]
    if not missing_in_parquet_for_recsys: print("✅ SEMUA kolom inti untuk rekomendasi ADA di file Parquet.")
    else: print(f"❌ ERROR: Kolom inti untuk rekomendasi berikut TIDAK ADA di Parquet: {missing_in_parquet_for_recsys}")
    missing_in_parquet_for_model = [col for col in model_feature_names if col not in parquet_columns]
    if not missing_in_parquet_for_model: print("✅ SEMUA fitur yang diharapkan oleh model (dari metadata) ADA di file Parquet.")
    else: print(f"❌ ERROR: Fitur model berikut TIDAK ADA di file Parquet: {missing_in_parquet_for_model}")
    non_numeric_model_features_in_parquet = []
    for col in model_feature_names:
        if col in df_features.columns: 
            if not pd.api.types.is_numeric_dtype(df_features[col]):
                if not (col.startswith('category_') and df_features[col].dtype in [np.int64, np.int32, np.uint8, bool, object]): # Kolom OHE bisa jadi object jika ada NaN jadi string '0'/'1'
                     non_numeric_model_features_in_parquet.append(f"{col} (tipe: {df_features[col].dtype})")
    if not non_numeric_model_features_in_parquet: print("✅ SEMUA fitur yang diharapkan model tampaknya memiliki tipe data numerik (atau boolean/objek untuk OHE) di Parquet.")
    else: print(f"❌ PERINGATAN: Fitur model berikut mungkin BUKAN numerik murni di Parquet: {non_numeric_model_features_in_parquet}")
    if 'Id_rating' in parquet_columns:
        if df_features['Id_rating'].dtype == 'object' or pd.api.types.is_string_dtype(df_features['Id_rating']): print("✅ Kolom 'Id_rating' bertipe string/object di Parquet (bagus untuk ID).")
        else: print(f"❌ PERINGATAN: Kolom 'Id_rating' di Parquet bertipe {df_features['Id_rating'].dtype}, sebaiknya string.")
else:
    print("Tidak bisa melakukan verifikasi kesesuaian kolom karena data Parquet atau metadata model gagal dimuat.")

print("\n--- Pengecekan Selesai ---")