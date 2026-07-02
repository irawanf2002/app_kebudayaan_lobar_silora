from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import joblib
import logging
import os

# Konfigurasi logging untuk kebutuhan skripsi
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

app = Flask(__name__)
CORS(app)

# Path ke file model
MODEL_PATH = "model_xgboost_kebudayaan.pkl"
ENCODER_PATH = "label_encoder_kondisi.pkl"

# Load model dan label encoder
def load_assets():
    if not os.path.exists(MODEL_PATH) or not os.path.exists(ENCODER_PATH):
        logging.error("File model atau encoder tidak ditemukan.")
        return None, None
    try:
        model = joblib.load(MODEL_PATH)
        le_y = joblib.load(ENCODER_PATH)
        logging.info("Model XGBoost dan Label Encoder berhasil dimuat! 🚀")
        return model, le_y
    except Exception as e:
        logging.error(f"Gagal memuat file model: {e}")
        return None, None

model, le_y = load_assets()

@app.route("/health", methods=["GET"])
def health_check():
    return jsonify({"status": "online", "model_loaded": model is not None})

@app.route("/predict", methods=["POST"])
def predict():
    if model is None:
        return jsonify({"status": "error", "message": "Model belum dimuat"}), 503

    try:
        data = request.get_json()
        logging.info(f"Menerima request prediksi: {data}")

        # Validasi input dasar
        required_fields = ["kategori", "nama", "lokasi"]
        if not all(field in data for field in required_fields):
            return jsonify({"status": "error", "message": "Field tidak lengkap"}), 400

        # Membangun DataFrame input sesuai skema training
        input_data = pd.DataFrame([{
            "kategori": str(data.get("kategori")),
            "nama_budaya": str(data.get("nama")),
            "lokasi_utama": str(data.get("lokasi"))
        }])

        # Prediksi
        prediction = model.predict(input_data)
        result_class_id = int(prediction[0])

        # Inverse transform untuk mendapatkan label teks
        label_asli = le_y.inverse_transform([result_class_id])[0]

        logging.info(f"Hasil prediksi: {label_asli} (ID: {result_class_id})")

        return jsonify({
            "status": "success",
            "prediction": result_class_id,
            "label": label_asli,
            "model_version": "1.0.0"
        })

    except Exception as e:
        logging.error(f"Error saat prediksi: {str(e)}")
        return jsonify({
            "status": "error", 
            "message": "Terjadi kesalahan internal pada sistem prediksi",
            "details": str(e)
        }), 500

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)