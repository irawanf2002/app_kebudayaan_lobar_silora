import json
import random
import os

# Ambil lokasi folder skrip saat ini
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

INPUT_FILE = os.path.join(BASE_DIR, '..', 'datasets', 'odcb_2025_tersebar_v2_final.json')
# ⚠️ PERBAIKAN: Simpan output di folder scripts (bukan datasets) agar tidak error penuh
OUTPUT_FILE = os.path.join(BASE_DIR, 'odcb_2025_tersebar_v2_seimbang.json')

print("📂 Membaca data...")
with open(INPUT_FILE, 'r', encoding='utf-8') as f:
    data = json.load(f)

# Pisahkan data
cagar_list = [item for item in data if item['kategori_odcb'] == 'Cagar Budaya']
non_cagar_list = [item for item in data if item['kategori_odcb'] != 'Cagar Budaya']

print(f"Total Cagar Budaya ditemukan: {len(cagar_list)} data")

# Target distribusi visual: 50 Terawat, 25 Ringan, 17 Berat
target_terawat = 50
target_ringan = 25
target_berat = 17

# Acak urutan data agar variasi menyebar
random.shuffle(cagar_list)

# 1. Ubah menjadi Rusak Berat (17 data)
for i in range(min(target_berat, len(cagar_list))):
    cagar_list[i]['kondisi_aktual'] = 'Rusak Berat'

# 2. Ubah menjadi Rusak Ringan (25 data, mulai dari data yang belum diubah)
for i in range(target_berat, min(target_berat + target_ringan, len(cagar_list))):
    cagar_list[i]['kondisi_aktual'] = 'Kurang Terawat'

# 3. Sisanya tetap Terawat

# Gabungkan kembali
data_seimbang = non_cagar_list + cagar_list

# Simpan file di folder scripts
try:
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(data_seimbang, f, indent=4)
    print(f"✅ Data berhasil disimpan ke folder 'scripts': {OUTPUT_FILE}")
    print("\n📌 LANGKAH SELANJUTNYA:")
    print("1. Buka Windows Explorer, lalu pindahkan file:")
    print("   'odcb_2025_tersebar_v2_seimbang.json'")
    print("   dari folder 'scripts' ke folder 'datasets'.")
    print("2. Buka file 'reset_upload.py', ubah path DATA_PATH menjadi:")
    print("   DATA_PATH = os.path.join(BASE_DIR, '..', 'datasets', 'odcb_2025_tersebar_v2_seimbang.json')")
    print("3. Jalankan ulang python reset_upload.py")
except OSError as e:
    print(f"❌ ERROR: Gagal menyimpan file. Kemungkinan hard disk laptop Anda sudah penuh. Error: {e}")