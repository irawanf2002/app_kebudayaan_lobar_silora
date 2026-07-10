import json
import random
import os

# Ambil lokasi folder skrip saat ini
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Input: Baca data dari datasets
input_file = os.path.join(BASE_DIR, '..', 'datasets', 'odcb_2025_dengan_koordinat.json')

# Output: Simpan langsung ke datasets (TANPA perlu dipindah manual lagi!)
output_file = os.path.join(BASE_DIR, '..', 'datasets', 'odcb_2025_tersebar_v2_final.json')

print("📂 Membaca data asli...")
try:
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
except FileNotFoundError:
    print(f"❌ ERROR: File '{input_file}' tidak ditemukan. Pastikan file ada di folder datasets.")
    exit()

# Koordinat dasar Dinas Dikbud Gerung
base_lat = -8.6645
base_lng = 116.1150

# 0.06 derajat = sekitar 6-7 kilometer
OFFSET_RANGE = 0.06 

tersebar_count = 0
for item in data:
    # Cek apakah data ini menumpuk di titik Dinas
    if abs(item['latitude'] - base_lat) < 0.0001 and abs(item['longitude'] - base_lng) < 0.0001:
        offset_lat = random.uniform(-OFFSET_RANGE, OFFSET_RANGE)
        offset_lng = random.uniform(-OFFSET_RANGE, OFFSET_RANGE)
        
        item['latitude'] = base_lat + offset_lat
        item['longitude'] = base_lng + offset_lng
        tersebar_count += 1

# Simpan file baru langsung ke folder datasets
try:
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4)
    print(f"✅ Selesai! {tersebar_count} data berhasil disebar ke radius ~5-7 km.")
    print(f"📁 File baru tersimpan di: {output_file}")
except OSError as e:
    print(f"❌ ERROR: Gagal menyimpan file baru. Kemungkinan hard disk laptop Anda sudah penuh. Error: {e}")