import json
import firebase_admin
from firebase_admin import credentials, firestore
import os

print("=" * 50)
print("MENGUPLOAD DATA ODCB 2025 KE FIRESTORE")
print("=" * 50)

# Konfigurasi path file
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CREDENTIALS_PATH = os.path.join(BASE_DIR, '..', 'config', 'credentials.json')
DATA_PATH = os.path.join(BASE_DIR, '..', 'datasets', 'odcb_2025_tersebar_v2_final.json')

# 1. Koneksi ke Firebase
try:
    cred = credentials.Certificate(CREDENTIALS_PATH)
    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred)
    db = firestore.client()
    print("[OK] Terhubung ke Firebase Firestore.")
except Exception as e:
    print(f"[ERROR] Gagal terhubung ke Firebase: {e}")
    exit()

# 2. Baca file JSON
try:
    with open(DATA_PATH, 'r', encoding='utf-8') as f:
        data_list = json.load(f)
    total_data = len(data_list)
    print(f"[OK] Berhasil membaca {total_data} data dari JSON.")
except Exception as e:
    print(f"[ERROR] Gagal membaca file JSON: {e}")
    exit()

# 3. Proses Upload (Batch Write)
collection_name = "odcb_data_2025"
print(f"\n⏳ Memasukkan {total_data} data ke dalam koleksi '{collection_name}'...")

batch = db.batch()
counter = 0
success = 0

for i, item in enumerate(data_list):
    doc_ref = db.collection(collection_name).document()
    batch.set(doc_ref, item)
    counter += 1
    success += 1

    # Print progres setiap 50 data agar tidak memenuhi layar
    if (i + 1) % 50 == 0:
        print(f"✅ Proses: {i + 1}/{total_data} data terkirim...")

    # Firebase membatasi 500 data per batch
    if counter >= 500:
        batch.commit()
        batch = db.batch()
        counter = 0

# Kirim sisa data
if counter > 0:
    batch.commit()

print("\n" + "=" * 50)
print("🎉 SUKSES! PROSES UPLOAD SELESAI!")
print("=" * 50)
print(f"✅ Total {success} data ODCB 2025 berhasil tersimpan di Firebase.")
print(f"📁 Koleksi: '{collection_name}'")
print("=" * 50)