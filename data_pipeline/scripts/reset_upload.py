import json
import firebase_admin
from firebase_admin import credentials, firestore
import os

print("=" * 50)
print("RESET & UPLOAD DATA ODCB 2025 (TERSEBAR V2)")
print("=" * 50)

# Konfigurasi path file
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CREDENTIALS_PATH = os.path.join(BASE_DIR, '..', 'config', 'credentials.json')

# ✅ PERBAIKAN: Menggunakan file yang sudah diseimbangkan (50 Terawat, 25 Ringan, 17 Berat)
DATA_PATH = os.path.join(BASE_DIR, '..', 'datasets', 'odcb_2025_tersebar_v2_seimbang.json')

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

collection_name = "odcb_data_2025"

# ==========================================================
# 2. HAPUS DATA LAMA (Batch Delete)
# ==========================================================
print(f"\n[INFO] Menghapus data lama di koleksi '{collection_name}'...")
docs = db.collection(collection_name).stream()
batch = db.batch()
hapus_count = 0

for doc in docs:
    batch.delete(doc.reference)
    hapus_count += 1
    if hapus_count % 400 == 0:
        batch.commit()
        print(f"✅ Menghapus {hapus_count} data...")
        batch = db.batch()

if hapus_count % 400 != 0 and hapus_count > 0:
    batch.commit()

print(f"[OK] {hapus_count} data lama berhasil dibersihkan.\n")

# ==========================================================
# 3. UPLOAD DATA BARU (Batch Write)
# ==========================================================
try:
    with open(DATA_PATH, 'r', encoding='utf-8') as f:
        data_list = json.load(f)
    total_data = len(data_list)
    print(f"[OK] Membaca {total_data} data baru dari JSON.")
except Exception as e:
    print(f"[ERROR] Gagal membaca file JSON baru: {e}")
    exit()

print(f"⏳ Memasukkan {total_data} data baru ke dalam koleksi '{collection_name}'...")

upload_batch = db.batch()
counter = 0

for i, item in enumerate(data_list):
    doc_ref = db.collection(collection_name).document()
    upload_batch.set(doc_ref, item)
    counter += 1

    # Tampilkan progres
    if (i + 1) % 50 == 0:
        print(f"✅ Proses: {i + 1}/{total_data} data terkirim...")

    # Firebase membatasi 500 data per batch
    if counter >= 500:
        upload_batch.commit()
        upload_batch = db.batch()
        counter = 0

# Kirim sisa data
if counter > 0:
    upload_batch.commit()

print("\n" + "=" * 50)
print("🎉 SUKSES! PROSES RESET & UPLOAD SELESAI!")
print("=" * 50)
print(f"✅ Data lama telah dihapus.")
print(f"✅ {total_data} data baru (tersebar) berhasil tersimpan.")
print("=" * 50)