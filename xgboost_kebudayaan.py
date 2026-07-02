import pandas as pd
import numpy as np
import joblib
import firebase_admin
from firebase_admin import credentials, firestore
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from xgboost import XGBClassifier

# ==================================================
# BAGIAN 1: MELATIH MODEL XGBOOST
# ==================================================
print("=" * 60)
print("[PROSES 1] MEMULAI PELATIHAN MODEL XGBOOST")
print("=" * 60)

# 1. Load Dataset dengan perbaikan error
df = pd.read_csv(
    "data_kebudayaandinas_dikbud.csv",
    on_bad_lines="skip",
    quotechar='"',
    encoding="utf-8",
    sep=","
)
print(f"✅ Data dimuat: {len(df)} baris")

# 2. Feature Engineering
np.random.seed(42)
def generate_score(row):
    if row['kondisi'] == 'Terawat':
        return np.random.randint(75, 100)
    elif row['kondisi'] == 'Berkembang':
        return np.random.randint(50, 74)
    else:
        return np.random.randint(10, 49)

df['indeks_kelayakan'] = df.apply(generate_score, axis=1)

# 3. Preprocessing Target
y = df["kondisi"]
le_y = LabelEncoder()
y_encoded = le_y.fit_transform(y)

# 4. Preprocessing Fitur
X = df[["kategori", "subkategori", "etnis", "latitude", "longitude", "indeks_kelayakan"]]
for col in ["kategori", "subkategori", "etnis"]:
    X[col] = X[col].astype("category")

# 5. Split Data
X_train, X_test, y_train, y_test = train_test_split(
    X, y_encoded, test_size=0.2, random_state=42, stratify=y_encoded
)

# 6. Training Model
model = XGBClassifier(
    n_estimators=150,
    max_depth=5,
    learning_rate=0.1,
    enable_categorical=True,
    eval_metric="mlogloss",
    random_state=42
)

print("⏳ Melatih model...")
model.fit(X_train, y_train)

# 7. Evaluasi
acc = model.score(X_test, y_test)
print("-" * 60)
print(f"✅ Akurasi Model: {acc * 100:.2f}%")
print("-" * 60)

# 8. Simpan Model
joblib.dump(model, 'model_xgboost_kebudayaan.pkl')
joblib.dump(le_y, 'label_encoder_kondisi.pkl')
print("✅ Model & Encoder tersimpan!")

# ==================================================
# BAGIAN 2: KLASIFIKASI SEMUA DATA
# ==================================================
print("\n" + "=" * 60)
print("[PROSES 2] MELAKUKAN KLASIFIKASI KESELURUHAN DATA")
print("=" * 60)

# Prediksi untuk seluruh data
X_full = df[["kategori", "subkategori", "etnis", "latitude", "longitude", "indeks_kelayakan"]].copy()
for col in ["kategori", "subkategori", "etnis"]:
    X_full[col] = X_full[col].astype("category")

df["status"] = model.predict(X_full)
df["kondisi_hasil"] = le_y.inverse_transform(df["status"])

# Ubah status menjadi angka standar agar cocok dengan aplikasi Flutter
# 0 = Terawat, 1 = Berkembang, 2 = Tidak Terawat
pemetaan_status = {
    "Terawat": 0,
    "Berkembang": 1,
    "Tidak Terawat": 2
}
df["status_numerik"] = df["kondisi_hasil"].map(pemetaan_status).fillna(2).astype(int)

print("✅ Klasifikasi selesai!")

# ==================================================
# BAGIAN 3: HUBUNGKAN & BERSIHKAN FIREBASE
# ==================================================
print("\n" + "=" * 60)
print("[PROSES 3] MEMBERSIHKAN DAN MENGUNGGAH KE FIREBASE")
print("=" * 60)

# Inisialisasi Firebase
try:
    cred = credentials.Certificate("credentials.json")
    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred)
    db = firestore.client()
    print("✅ Terhubung ke Firebase")
except Exception as e:
    print(f"❌ Gagal terhubung: {e}")
    exit()

collection_name = "cagar_budaya"
collection_ref = db.collection(collection_name)

# Hapus semua data lama
print("⏳ Menghapus data lama...")
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

print(f"✅ {hapus_count} data lama dihapus")

# ==================================================
# BAGIAN 4: UNGGAH DATA BARU HASIL KLASIFIKASI
# ==================================================
print("⏳ Mengunggah data baru...")
batch = db.batch()
unggah_count = 0
batas_batch = 400

for _, baris in df.iterrows():
    doc_ref = collection_ref.document()
    data = {
        "nama": str(baris.get("nama", "")).strip(),
        "kategori": str(baris.get("kategori", "")).strip(),
        "lokasi": str(baris.get("lokasi", "")).strip(),
        "latitude": float(baris["latitude"]),
        "longitude": float(baris["longitude"]),
        "status": int(baris["status_numerik"]),
        "kondisi_teks": str(baris["kondisi_hasil"]),
        "indeks_kelayakan": float(baris["indeks_kelayakan"])
    }

    batch.set(doc_ref, data)
    unggah_count += 1

    if unggah_count % batas_batch == 0:
        batch.commit()
        batch = db.batch()

if unggah_count % batas_batch != 0:
    batch.commit()

print(f"✅ {unggah_count} data baru berhasil diunggah!")

# ==================================================
# SELESAI
# ==================================================
print("\n" + "=" * 60)
print("🎉 SEMUA PROSES SELESAI DENGAN SUKSES!")
print("→ Model terlatih")
print("→ Data terklasifikasi")
print("→ Database bersih dan terbaru")
print("=" * 60)