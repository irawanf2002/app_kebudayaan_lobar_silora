import json
import pandas as pd
import numpy as np
import xgboost as xgb
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
from imblearn.over_sampling import SMOTE # 🔥 Teknik SMOTE
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_PATH = os.path.join(BASE_DIR, '..', 'datasets', 'odcb_2025_tersebar_v2_final.json')

print("=" * 60)
print("EVALUASI MODEL XGBOOST DENGAN SMOTE (UNTUK DATA IMBALANCE)")
print("=" * 60)

# 1. Load Data
try:
    with open(DATA_PATH, 'r', encoding='utf-8') as f:
        data = json.load(f)
    df = pd.DataFrame(data)
    print(f"[OK] Load {len(df)} data.")
except Exception as e:
    print(f"[ERROR] Gagal load dataset: {e}")
    exit()

# 2. Mapping Target
def map_kondisi(x):
    if x in ['Terawat', 'Berkembang']: return 0
    elif x in ['Kurang Terawat', 'Kurang Berkembang']: return 1
    elif x in ['Tidak Terawat', 'Rusak Berat', 'Punah']: return 2
    else: return 0

df['target'] = df['kondisi_aktual'].apply(map_kondisi)

# 3. Encode Fitur
le_kategori = LabelEncoder()
le_etnis = LabelEncoder()
X_kategori = le_kategori.fit_transform(df['kategori_odcb'])
X_etnis = le_etnis.fit_transform(df['etnis'])
X = np.column_stack((X_kategori, X_etnis))
y = df['target'].values

# 4. Split Data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# 5. 🔥 TERAPKAN SMOTE PADA DATA LATIH (Menyetarakan jumlah kelas)
print("[INFO] Menerapkan SMOTE untuk menyeimbangkan data latih...")
smote = SMOTE(random_state=42)
X_resampled, y_resampled = smote.fit_resample(X_train, y_train)
print(f"✅ Data Latih sebelum SMOTE: {len(X_train)} data")
print(f"✅ Data Latih setelah SMOTE: {len(X_resampled)} data (Seimbang)")

# 6. Latih Model XGBoost (Tanpa scale_pos_weight yang error)
model = xgb.XGBClassifier(n_estimators=150, learning_rate=0.1, max_depth=5, eval_metric='mlogloss')
model.fit(X_resampled, y_resampled)

# 7. Prediksi & Evaluasi
y_pred = model.predict(X_test)
accuracy = accuracy_score(y_test, y_pred)

print(f"\n✅ AKURASI GLOBAL MODEL: {accuracy * 100:.2f}%")
print("=" * 60)

print("\n🔍 LAPORAN KLASIFIKASI (Uji Data 20%):")
target_names = ['Terawat', 'Kurang Terawat', 'Tidak Terawat']
print(classification_report(y_test, y_pred, target_names=target_names, zero_division=0))

# 8. Simpan Confusion Matrix
cm = confusion_matrix(y_test, y_pred)
plt.figure(figsize=(8, 6))
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', xticklabels=target_names, yticklabels=target_names)
plt.title(f'Confusion Matrix XGBoost + SMOTE (Akurasi: {accuracy*100:.2f}%)')
plt.ylabel('Kondisi Aktual')
plt.xlabel('Prediksi AI')

output_img = os.path.join(BASE_DIR, '..', 'confusion_matrix_xgboost_smote.png')
plt.savefig(output_img, dpi=300, bbox_inches='tight')
print(f"\n📊 Grafik Confusion Matrix disimpan di: {output_img}")
print("=" * 60)