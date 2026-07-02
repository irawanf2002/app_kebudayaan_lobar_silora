import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

print("=======================================================")
print("[*] Menghubungkan ke Firebase untuk Pembersihan Data...")
print("=======================================================")

try:
    cred = credentials.Certificate('credentials.json')
    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred)
    db = firestore.client()
    print("--- [SUKSES] Terhubung ke Firebase --- \n")
except Exception as e:
    print(f"--- [ERROR] Gagal inisialisasi Firebase: {e} ---")
    exit()

# Target koleksi SIBUD LOBAR
collection_name = 'cagar_budaya'
collection_ref = db.collection(collection_name)

print(f"[*] Memulai proses penghapusan seluruh data di koleksi '{collection_name}'...")

# Ambil semua dokumen menggunakan stream
docs = collection_ref.stream()
deleted_count = 0

# Menggunakan batch untuk performa penghapusan massal yang cepat dan aman
batch = db.batch()

for doc in docs:
    try:
        batch.delete(doc.reference)
        deleted_count += 1
        
        # Batasan maksimal operasi per batch di Firestore adalah 500 dokumen
        if deleted_count % 400 == 0:
            batch.commit()
            print(f"[>] Berhasil menghapus {deleted_count} dokumen lama...")
            batch = db.batch() # Buka batch baru untuk dokumen berikutnya
            
    except Exception as e:
        print(f"[-] Gagal mendaftarkan penghapusan dokumen {doc.id}: {e}")

# Eksekusi sisa dokumen yang ada di batch terakhir
if deleted_count % 400 != 0 and deleted_count > 0:
    batch.commit()

print("=======================================================")
print(f"[SUKSES TOTAL] {deleted_count} Data Budaya Lama Berhasil Dibersihkan!")
print("=======================================================")
print("Database 'cagar_budaya' sekarang kosong murni. ✨")
print("Anda siap menjalankan 'upload_data_skripsi.py' yang berbasis pandas.")
print("=======================================================")