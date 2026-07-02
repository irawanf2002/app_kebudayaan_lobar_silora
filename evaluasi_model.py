import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import xgboost as xgb
from sklearn.metrics import confusion_matrix, classification_report, accuracy_score

print("=======================================================")
print("[*] Evaluasi Model XGBoost")
print("=======================================================\n")

# =========================
# 1. LOAD MODEL
# =========================
model = xgb.XGBClassifier()

try:
    model.load_model("model_xgboost_kebudayaan.json")
    print("[OK] Model berhasil dimuat")
except Exception as e:
    print(f"[ERROR] {e}")
    exit()

# =========================
# 2. LOAD DATA (HARUS SAMA DENGAN TRAINING)
# =========================
df = pd.read_csv("data_kebudayaandinas_dikbud.csv")
df = df.dropna()

# pastikan sama dengan training
features = ["aksesibilitas", "nilai_sejarah", "jumlah_pengunjung"]

X = df[features]

# label asli
df["label"] = df["kondisi"].map({
    "terawat": 0,
    "kurang terawat": 1,
    "tidak terawat": 2
})

y_true = df["label"]

# =========================
# 3. PREDIKSI
# =========================
y_pred = model.predict(X)

print("[OK] Prediksi selesai")

# =========================
# 4. CONFUSION MATRIX
# =========================
cm = confusion_matrix(y_true, y_pred)

print("\nCONFUSION MATRIX:")
print(cm)

# =========================
# 5. AKURASI
# =========================
acc = accuracy_score(y_true, y_pred)
print(f"\nAccuracy: {acc * 100:.2f}%")

print("\nClassification Report:")
print(classification_report(
    y_true, y_pred,
    target_names=["Terawat", "Kurang Terawat", "Tidak Terawat"]
))

# =========================
# 6. HEATMAP
# =========================
plt.figure(figsize=(6,5))
sns.heatmap(
    cm,
    annot=True,
    fmt="d",
    cmap="Blues",
    xticklabels=["Terawat", "Kurang", "Tidak"],
    yticklabels=["Terawat", "Kurang", "Tidak"]
)

plt.title("Confusion Matrix XGBoost")
plt.xlabel("Prediksi")
plt.ylabel("Aktual")
plt.tight_layout()

plt.savefig("confusion_matrix.png", dpi=300)
plt.show()

print("\n[OK] Grafik disimpan: confusion_matrix.png")