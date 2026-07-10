import json
import firebase_admin
from firebase_admin import credentials, firestore
import os

# Dapatkan folder tempat script ini berada
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Path file yang sudah dipindahkan (Menggunakan os.path.join agar aman)
CREDENTIALS_PATH = os.path.join(BASE_DIR, '..', 'config', 'credentials.json')
DATA_PATH = os.path.join(BASE_DIR, '..', 'datasets', 'odcb_2025_tersebar_v2_final.json')

print("=" * 50)
print("UPLOAD DATA ODCB 2025 KE FIRESTORE")
print("=" * 50)

# 1. Koneksi Firebase dengan path baru
try:
    cred = credentials.Certificate(CREDENTIALS_PATH)
    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred)
    db = firestore.client()
    print("[OK] Terhubung ke Firebase Firestore.")
except Exception as e:
    print(f"[ERROR] Gagal terhubung ke Firebase: {e}")
    exit()

# 2. Baca JSON dengan path baru
collection_name = "odcb_data_2025"
try:
    with open(DATA_PATH, 'r', encoding='utf-8') as f:
        data_list = json.load(f)
    print(f"[OK] Berhasil membaca {len(data_list)} data dari JSON.")
except Exception as e:
    print(f"[ERROR] Gagal membaca file JSON: {e}")
    exit()

# ... (Sisa kode upload batch di bawahnya tetap sama) ...