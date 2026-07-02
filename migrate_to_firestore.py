import pandas as pd
import firebase_admin
from firebase_admin import credentials, firestore

# 1. Inisialisasi Firebase
# Menggunakan 'credentials.json' yang tersedia di folder Anda
cred = credentials.Certificate("credentials.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

def upload_csv_to_firestore(csv_file):
    # Membaca data CSV
    df = pd.read_csv(csv_file)
    
    collection_ref = db.collection('cagar_budaya')
    
    for _, row in df.iterrows():
        # Memetakan kolom CSV ke dokumen Firestore
        # Pastikan nama kolom di CSV ('nama_budaya', 'kategori', dll) sudah sesuai
        data = {
            'nama': row['nama_budaya'],
            'kategori': row['kategori'],
            'deskripsi': row['deskripsi_singkat'],
            'lokasi': row['lokasi_utama'],
            'latitude': float(row['lintang']),
            'longitude': float(row['bujur']),
            'kondisi': row['kondisi'],
            'status': 0  # 0 untuk belum diproses AI
        }
        
        # Simpan ke Firestore
        collection_ref.add(data)
        print(f"Berhasil mengunggah: {row['nama_budaya']}")

if __name__ == "__main__":
    # Menggunakan file CSV yang ada di folder Anda
    upload_csv_to_firestore('data_kebudayaandinas_dikbud.csv')