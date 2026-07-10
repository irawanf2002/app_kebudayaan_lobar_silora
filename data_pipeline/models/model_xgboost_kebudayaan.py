import xgboost as xgb
import pandas as pd
import os
import logging
import joblib  # ← Tambahkan joblib untuk memuat encoder

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, '..', 'models', 'model_xgboost_kebudayaan.json')
ENCODER_KATEGORI = os.path.join(BASE_DIR, '..', 'models', 'encoder_kategori.pkl')
ENCODER_ETNIS = os.path.join(BASE_DIR, '..', 'models', 'encoder_etnis.pkl')

# Label mapping (harus sama dengan train_model.py)
LABEL_MAP = {0: "Terawat", 1: "Kurang Terawat/Rusak Ringan", 2: "Tidak Terawat/Rusak Berat"}

def load_model():
    if not os.path.exists(MODEL_PATH):
        logging.warning(f"⚠️ File {MODEL_PATH} tidak ditemukan. AI akan menggunakan logika rule-based.")
        return None, None, None
    
    try:
        model = xgb.XGBClassifier()
        model.load_model(MODEL_PATH)
        # Muat encoder
        le_kategori = joblib.load(ENCODER_KATEGORI)
        le_etnis = joblib.load(ENCODER_ETNIS)
        logging.info("✅ Model XGBoost SILORA Berhasil Dimuat!")
        return model, le_kategori, le_etnis
    except Exception as e:
        logging.error(f"❌ Gagal memuat model: {e}")
        return None, None, None

def predict_single(model, le_kategori, le_etnis, kategori_odcb, etnis):
    """
    Menerima kategori_odcb (string) dan etnis (string), mengembalikan prediksi.
    """
    if model is None or le_kategori is None or le_etnis is None:
        logging.warning("⚠️ Model tidak tersedia, menggunakan fallback rule-based.")
        return 0, "Terawat"
    
    try:
        # Encode input menggunakan encoder yang sudah disimpan
        kategori_encoded = le_kategori.transform([kategori_odcb])[0]
        etnis_encoded = le_etnis.transform([etnis])[0]
        
        input_df = pd.DataFrame({
            "kategori_encoded": [kategori_encoded],
            "etnis_encoded": [etnis_encoded]
        })
        
        # Prediksi
        pred = model.predict(input_df)
        result_id = int(pred[0])
        label_asli = LABEL_MAP.get(result_id, "Tidak Diketahui")
        
        return result_id, label_asli
    except Exception as e:
        logging.error(f"Prediksi error: {e}")
        return 0, "Terawat"