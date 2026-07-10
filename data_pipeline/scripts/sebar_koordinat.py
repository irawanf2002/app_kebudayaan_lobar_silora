import json
import random

# Path file data Anda (Sesuaikan dengan lokasi Anda)
input_file = "odcb_2025_tersebar_v2_final.json"
output_file = "odcb_2025_tersebar_v2_final.json"

print("📂 Membaca data asli...")
try:
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
except FileNotFoundError:
    print(f"❌ ERROR: File '{input_file}' tidak ditemukan. Pastikan path-nya benar.")
    exit()

# Koordinat dasar Dinas Dikbud Gerung (Titik pusat penumpukan)
base_lat = -8.6645
base_lng = 116.1150

tersebar_count = 0
for item in data:
    # Cek apakah data ini menumpuk di titik Dinas
    if abs(item['latitude'] - base_lat) < 0.0001 and abs(item['longitude'] - base_lng) < 0.0001:
        # Beri jarak acak antara -0.02 sampai 0.02 derajat (sekitar 2-3 kilometer)
        offset_lat = random.uniform(-0.02, 0.02)
        offset_lng = random.uniform(-0.02, 0.02)
        
        item['latitude'] = base_lat + offset_lat
        item['longitude'] = base_lng + offset_lng
        tersebar_count += 1

# Simpan file baru
with open(output_file, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=4)

print(f"✅ Selesai! {tersebar_count} data berhasil disebar secara visual.")
print(f"📁 File baru tersimpan di: {output_file}")