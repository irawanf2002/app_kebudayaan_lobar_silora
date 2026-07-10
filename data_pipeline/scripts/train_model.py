import json
import pandas as pd
import xgboost as xgb
import joblib
from sklearn.preprocessing import LabelEncoder
import os

print("="*50)
print("MELATIH MODEL XGBOOST UNTUK SILORA")
print("="*50)

# 1. Load Data JSON
json_path = os.path.join('..', 'datasets', 'odcb_2025_tersebar_v2_final.json')
with open(json_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

df = pd.DataFrame(data)

# 2. Pilih Fitur (Features) dan Target (Label)
# Kita latih AI menggunakan 2 fitur utama: Kategori ODCB dan Etnis
# Targetnya adalah Kondisi Aktual
df['target'] = df['kondisi_aktual'].apply(lambda x: 
    0 if x in ['Terawat', 'Berkembang'] else 
    1 if x in ['Kurang Terawat', 'Kurang Berkembang'] else 
    2 if x in ['Tidak Terawat', 'Rusak Berat', 'Punah'] else 0
)

# 3. Encode Teks menjadi Angka
le_kategori = LabelEncoder()
le_etnis = LabelEncoder()

X_kategori = le_kategori.fit_transform(df['kategori_odcb'])
X_etnis = le_etnis.fit_transform(df['etnis'])

# Gabungkan fitur menjadi satu DataFrame untuk XGBoost
import numpy as np
X = np.column_stack((X_kategori, X_etnis))
y = df['target'].values

# 4. Latih Model XGBoost
print("⏳ Melatih model XGBoost...")
model = xgb.XGBClassifier(
    n_estimators=100,
    learning_rate=0.1,
    max_depth=4,
    use_label_encoder=False,
    eval_metric='mlogloss'
)
model.fit(X, y)
print("✅ Model berhasil dilatih!")

# 5. Simpan Model dan Encoder
model_dir = os.path.join('..', 'models')
if not os.path.exists(model_dir):
    os.makedirs(model_dir)

model_path = os.path.join(model_dir, 'model_xgboost_kebudayaan.json')
model.save_model(model_path)
print(f"✅ Model disimpan di: {model_path}")

# Simpan Encoder agar input API nanti bisa diubah ke angka yang sama
joblib.dump(le_kategori, os.path.join(model_dir, 'encoder_kategori.pkl'))
joblib.dump(le_etnis, os.path.join(model_dir, 'encoder_etnis.pkl'))
print("✅ Encoder juga telah disimpan!")

print("\n🎉 PROSES SELESAI! Sekarang Anda bisa menjalankan API dengan AI yang sesungguhnya.")