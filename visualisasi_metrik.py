import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import confusion_matrix, classification_report
import joblib
import pandas as pd
import numpy as np
from xgboost import plot_importance

def visualisasi_hasil():
    # 1. Load Model & Data
    model = joblib.load('model_xgboost_kebudayaan.pkl')
    # Catatan: Pastikan Anda memiliki X_test dan y_test yang disimpan saat training
    # Jika tidak, Anda bisa memuat ulang data dan melakukan split seperti di xgboost_kebudayaan.py
    
    print("--- Membuat Visualisasi Metrik ---")

    # 2. Confusion Matrix
    # Contoh penggunaan jika X_test dan y_test tersedia
    # cm = confusion_matrix(y_test, y_pred)
    # plt.figure(figsize=(8,6))
    # sns.heatmap(cm, annot=True, fmt='d', cmap='Blues')
    # plt.title('Confusion Matrix')
    # plt.savefig('confusion_matrix_xgboost.png')
    # print("✅ Grafik Confusion Matrix disimpan!")

    # 3. Feature Importance
    plt.figure(figsize=(10,6))
    plot_importance(model, max_num_features=10)
    plt.title('Pentingnya Fitur dalam Klasifikasi Aset Budaya')
    plt.savefig('feature_importance_kebudayaan.png')
    print("✅ Grafik Feature Importance disimpan!")

    plt.show()

if __name__ == "__main__":
    visualisasi_hasil()