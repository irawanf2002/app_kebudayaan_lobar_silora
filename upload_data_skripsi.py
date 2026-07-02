import pandas as pd
import datetime
import random
import firebase_admin
from firebase_admin import credentials, firestore

print("=" * 60)
print("SILORA - UPLOAD DATA BUDAYA")
print("=" * 60)

# ==========================================================
# 1. KONEKSI KE FIREBASE
# ==========================================================
try:
    cred = credentials.Certificate("credentials.json")
    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred)
    db = firestore.client()
    print("[OK] Terhubung ke Firebase")
except Exception as e:
    print(f"[ERROR] Gagal terhubung ke Firebase: {e}")
    exit()

# ==========================================================
# 2. HAPUS SEMUA DATA LAMA DULU (AGAR TIDAK MENUMPUK)
# ==========================================================
collection_name = "cagar_budaya"
collection_ref = db.collection(collection_name)

print(f"\n[INFO] Menghapus data lama di koleksi '{collection_name}'...")
docs = collection_ref.stream()
batch = db.batch()
hapus_count = 0

for doc in docs:
    batch.delete(doc.reference)
    hapus_count += 1
    if hapus_count % 400 == 0:
        batch.commit()
        batch = db.batch()

if hapus_count % 400 != 0 and hapus_count > 0:
    batch.commit()

print(f"[OK] {hapus_count} data lama berhasil dihapus\n")

# ==========================================================
# 3. BACA FILE CSV
# ==========================================================
csv_file = "data_kebudayaandinas_dikbud.csv"

print(f"Membaca file: {csv_file} ...")
try:
    df = pd.read_csv(
        csv_file,
        encoding="utf-8-sig",
        on_bad_lines="skip"
    )
    print(f"Jumlah data terbaca: {len(df)}")
except Exception as e:
    print(f"[ERROR] Gagal baca file CSV: {e}")
    exit()

# ==========================================================
# 4. SESUAIKAN NAMA KOLOM AGAR SERAGAM
# ==========================================================
df.columns = df.columns.str.strip().str.lower()

rename_map = {
    "nama_budaya": "nama",
    "lintang": "latitude",
    "bujur": "longitude",
    "lokasi_utama": "lokasi",
    "makna_dan_fungsi": "deskripsi"
}
df.rename(columns=rename_map, inplace=True)

# ==========================================================
# 5. TAMBAH KOLOM JIKA BELUM ADA
# ==========================================================
default_values = {
    "subkategori": "",
    "etnis": "Sasak",
    "image_url": "https://images.unsplash.com/photo-1590075865003-e48277afd558?w=500",
    "deskripsi": ""
}

for col, val in default_values.items():
    if col not in df.columns:
        df[col] = val

# ==========================================================
# 6. CEK KOLOM WAJIB
# ==========================================================
required_cols = ["nama", "kategori", "kondisi", "latitude", "longitude"]
for col in required_cols:
    if col not in df.columns:
        print(f"[ERROR] Kolom wajib '{col}' tidak ditemukan di file CSV!")
        exit()

# ==========================================================
# 7. BERSIHKAN DATA KOSONG
# ==========================================================
df = df.dropna(subset=["nama", "kategori", "kondisi"])
print(f"Data valid siap diunggah: {len(df)} baris\n")

# ==========================================================
# 8. PROSES UNGGAH KE FIREBASE
# ==========================================================
print("Memulai proses unggah data baru...")
success = 0
failed = 0

for _, row in df.iterrows():
    kondisi = str(row["kondisi"]).strip().capitalize()
    kondisi_lower = kondisi.lower()

    if kondisi_lower == "terawat":
        status = 0
    elif kondisi_lower == "berkembang":
        status = 1
    elif kondisi_lower in ["kurang terawat", "tidak terawat", "rusak"]:
        status = 2
    else:
        status = 1

    try:
        lat = float(row["latitude"])
        lng = float(row["longitude"])
        if not (-8.93 <= lat <= -8.12 and 115.81 <= lng <= 116.75):
            raise ValueError("Koordinat di luar wilayah")
    except:
        lat = round(random.uniform(-8.93, -8.12), 6)
        lng = round(random.uniform(115.81, 116.75), 6)

    gambar = str(row.get("image_url", default_values["image_url"])).strip()
    deskripsi = str(row.get("deskripsi", "")).strip()
    if deskripsi == "":
        deskripsi = f"{row['nama']} merupakan warisan budaya yang berada di wilayah Lombok."

    data = {
        "nama": str(row["nama"]).strip(),
        "kategori": str(row["kategori"]).strip(),
        "subkategori": str(row["subkategori"]).strip(),
        "lokasi": str(row.get("lokasi", "Lombok")).strip(),
        "etnis": str(row["etnis"]).strip(),
        "kondisi_teks": kondisi,
        "status": status,
        "latitude": lat,
        "longitude": lng,
        "gambarUrl": gambar,
        "images": [gambar],
        "deskripsi": deskripsi,
        "updatedAt": datetime.datetime.utcnow()
    }

    try:
        collection_ref.add(data)
        success += 1
        print(f"✅ {success}. {data['nama']} | Status: {kondisi}")
    except Exception as e:
        failed += 1
        print(f"❌ Gagal: {row['nama']} | Error: {e}")

# ==========================================================
# RINGKASAN AKHIR
# ==========================================================
print("\n" + "=" * 60)
print("PROSES SELESAI")
print("=" * 60)
print(f"✅ Berhasil diunggah: {success} data")
print(f"❌ Gagal diunggah  : {failed} data")
print("=" * 60)
print("Data siap dibaca langsung oleh aplikasi Flutter! 🚀")